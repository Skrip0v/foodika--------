import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:foodika/core/models/category_model.dart';
import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/services/categories_service.dart';
import 'package:get/get.dart';

Future<List<ProductModel>> gs1Info(List<ProductModel> p) async {
  log('${p.length} product');
  log('start get info from gs1');
  var products = [...p];

  List<List<ProductModel>> chunks = [];
  for (var i = 0; i < products.length; i += 500) {
    chunks.add(
      products.sublist(
        i,
        i + 500 > products.length ? products.length : i + 500,
      ),
    );
  }

  int requestCount = 0;
  int countProductDescriptionSet = 0;
  int countBrandNameSet = 0;
  int countLicenseeName = 0;
  int countDateCreated = 0;
  int countCountryOfSaleCode = 0;

  for (var chunk in chunks) {
    requestCount++;
    var res = await Dio().post(
      'https://www.verified-by-gs1.de/api/verified_service/v1/verify_ids',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer eyJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJodHRwczovL3Byb2Quc2ltYmEuZWVjYy5kZS90ZXN0Iiwic3ViIjoiMjg2NDI0IiwiaWF0IjoxNzEwMTAyODg1LCJleHAiOjQ4NjM3MDI4ODUsInBlcm1pc3Npb25zIjoiVkJHRiIsImdsbiI6IiIsIm5hbWUiOiJPbGVncyBWb2xrb3ZzIiwiY29tcGFueSI6IlNtYXJ0ZW8iLCJsYW5ndWFnZSI6IkRFIiwicHJldmlvdXNfZ2xuIjoiIiwicHJldmlvdXNfY29nbG5BY2NvdW50SWQiOiIiLCJlbWFpbCI6Im9sZWdzLnZvbGtvdnNAZ21haWwuY29tIiwiY29nbG5BY2NvdW50SWQiOiIifQ.H6vi_GPVWaYwcaCrrho35YfkFGbJSjZc_hAb7iXOAhJF1ZqmWAk1sOqgoNM1qGaF3FTaBYjeLvBqVYVyUrbb0w',
        },
        validateStatus: (status) {
          return status! <= 500;
        },
      ),
      data: chunk.map((e) => e.barcode).toList(),
    );

    if (res.data == null) continue;
    if (res.data['gtins'].isEmpty) continue;
    if (res.data['gtins']?[0] == null) continue;

    var gtins = res.data['gtins'];

    var status = '';
    int countCategoriesSet = 0;

    for (var data in gtins) {
      var gtin = data['gtin'].toString();
      var check = products.where((e) {
        var barcode = e.barcode;
        var testGtin = barcode.padLeft(14, '0');
        if (gtin == testGtin) return true;
        return false;
      });
      if (check.length > 1) status += 'more then 1; ';
      if (check.isEmpty) status += 'zero; ';

      if (check.length == 1) {
        var index = products.indexOf(check.first);
        var categoryId = data?['gpcCategoryCode'];
        if (categoryId != null) {
          var category = _getCategoryForProduct(categoryId);
          if (category != null) {
            products[index].categoryId = category.id;
            countCategoriesSet++;
          }
        }

        var productDescription = data?['productDescription'];
        if (productDescription != null) {
          products[index].productDescription = List<ProductInfoModel>.from(
            (productDescription as List<dynamic>).map<ProductInfoModel>(
              (x) => ProductInfoModel.fromMap(x as Map<String, dynamic>),
            ),
          );
          countProductDescriptionSet++;
        }

        var brandName = data?['brandName'];
        if (brandName != null) {
          products[index].brandName = List<ProductInfoModel>.from(
            (brandName as List<dynamic>).map<ProductInfoModel>(
              (x) => ProductInfoModel.fromMap(x as Map<String, dynamic>),
            ),
          );
          countBrandNameSet++;
        }

        var licenseeName = data?['licenseeName'];
        if (licenseeName != null) {
          products[index].licenseeName = licenseeName;
          countLicenseeName++;
        }

        var dateCreated = data?['dateCreated'];
        if (dateCreated != null) {
          products[index].dateCreated = dateCreated;
          countDateCreated++;
        }

        var countryOfSaleCode = data?['countryOfSaleCode'];
        if (countryOfSaleCode != null) {
          products[index].countryOfSaleCode =
              List<ProductCountryOfSaleModel>.from(
            (countryOfSaleCode as List<dynamic>).map<ProductCountryOfSaleModel>(
              (x) => ProductCountryOfSaleModel.fromMap(
                x as Map<String, dynamic>,
              ),
            ),
          );
          countCountryOfSaleCode++;
        }
      }
    }

    log('$requestCount: ${status.isEmpty ? 'all ok' : status}');
    log('$requestCount: set category $countCategoriesSet');
  }

  int y = 0;
  int n = 0;

  for (var product in products) {
    if (product.categoryId != null) {
      y++;
    } else {
      n++;
    }
  }

  log('total set: $y $n');
  log('countProductDescriptionSet $countProductDescriptionSet');
  log('countBrandNameSet $countBrandNameSet');
  log('countLicenseeName $countLicenseeName');
  log('countDateCreated $countDateCreated');
  log('countCountryOfSaleCode $countCountryOfSaleCode');

  return products;
}

CategoryModel? _getCategoryForProduct(String categoryId) {
  var categories = Get.find<CategoriesService>().categories;
  var category = categories.firstWhereOrNull(
    (e) =>
        e.gpcBrickCodes.contains(categoryId) ||
        e.gpcClassCodes.contains(categoryId),
  );

  return category;
}
