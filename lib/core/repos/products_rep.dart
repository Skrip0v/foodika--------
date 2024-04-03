import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:foodika/core/services/language_service.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'package:foodika/core/models/category_model.dart';
import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/models/review_model.dart';
import 'package:foodika/core/services/auth_service.dart';
import 'package:foodika/core/services/categories_service.dart';
import 'package:foodika/functions/show_error_dialog.dart';

class ProductsRep {
  Future<ProductModel?> getProductFromGS1(String barcode) async {
    var product = await _checkIsProductInDatabase(barcode);
    if (product != null) return product;

    //try to get product info from gs1
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
      data: [barcode],
    );
    log(res.data.toString(), name: 'res');

    var gtins = res.data?['gtins'];

    //if is not have info in GS1
    if (gtins == null || (gtins?.isEmpty ?? true)) {
      var product = await getInfoFromFoodFacts(barcode);
      if (product == null) {
        Get.back();
        showErrorDialog(
          Get.context!,
          title: 'Error'.tr,
          content: 'It was not possible to get information about the product',
          okButtonText: 'Ok',
        );
        return null;
      } else {
        await createNewProduct(product);
        return await getProduct(barcode);
      }
    }

    //save product
    try {
      await _addNewProductFromGtin(gtins, barcode);
    } catch (e) {
      log(e.toString());
      Get.back();
      showErrorDialog(
        Get.context!,
        title: 'Error',
        content: 'Failed to save product information',
        okButtonText: 'Ok',
      );

      return null;
    }

    return await getProduct(barcode);
  }

  Future<ProductModel?> _checkIsProductInDatabase(String barcode) async {
    var cloud = FirebaseFirestore.instance;
    var res = await cloud.doc('products/$barcode').get();
    if (res.data() == null) return null;

    return ProductModel.fromMap(res.data()!);
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

  Future<void> _addNewProductFromGtin(
    dynamic gtins,
    String barcode,
  ) async {
    var gtin = gtins[0];
    List<ProductInfoModel> photoUrls = [];
    if (gtin?['productImageUrl'] != null) {
      for (var item in gtin['productImageUrl']) {
        var isValidURL = Uri.parse(item['value']).isAbsolute;
        if (isValidURL) {
          photoUrls.add(
            ProductInfoModel(
              language: 'en',
              value: item['value'],
            ),
          );
        }
      }
    }

    String? categoryId = gtins[0]?['gpcCategoryCode'];

    if (categoryId != null) {
      var category = _getCategoryForProduct(categoryId);
      if (category == null) {
        categoryId = null;
      } else {
        categoryId = category.id;
      }
    }

    var product = ProductModel(
      gtin: gtin['gtin']?.toString() ?? barcode,
      photoUrls: photoUrls,
      barcode: barcode,
      q: [],
      productDescription: gtin['productDescription'] == null
          ? null
          : List<ProductInfoModel>.from(
              (gtin['productDescription'] as List<dynamic>)
                  .map<ProductInfoModel>(
                (x) => ProductInfoModel.fromMap(x as Map<String, dynamic>),
              ),
            ),
      brandName: gtin['brandName'] == null
          ? []
          : List<ProductInfoModel>.from(
              (gtin['brandName'] as List<dynamic>).map<ProductInfoModel>(
                (x) => ProductInfoModel.fromMap(x as Map<String, dynamic>),
              ),
            ),
      licenseeName: gtin['licenseeName']?.toString(),
      dateCreated: gtin['dateCreated']?.toString(),
      rating: 0.0,
      rate: ProductRateModel(
        count1: 0,
        count2: 0,
        count3: 0,
        count4: 0,
        count5: 0,
      ),
      categoryId: categoryId,
      countryOfSaleCode: gtin['countryOfSaleCode'] == null
          ? null
          : List<ProductCountryOfSaleModel>.from(
              (gtin['countryOfSaleCode'] as List<dynamic>)
                  .map<ProductCountryOfSaleModel>(
                (x) => ProductCountryOfSaleModel.fromMap(
                    x as Map<String, dynamic>),
              ),
            ),
    );

    await FirebaseFirestore.instance
        .doc('products/${product.barcode}')
        .set(product.toMap());
  }

  Future<ProductModel> getProduct(String barcode) async {
    var cloud = FirebaseFirestore.instance;
    var res = await cloud.doc('products/$barcode').get();
    return ProductModel.fromMap(res.data()!);
  }

  Future<void> savePhotosToProduct(
    List<String> filePaths,
    String barcode,
  ) async {
    List<String> urls = [];

    var storage = FirebaseStorage.instance;

    for (var i = 0; i < filePaths.length; i++) {
      var path = filePaths[i];
      var reference = storage.ref().child("product_images/${barcode}_$i.png");
      var res = await reference.putFile(File(path));
      var url = await res.ref.getDownloadURL();
      urls.add(url);
    }

    var cloud = FirebaseFirestore.instance;
    await cloud.doc('products/$barcode').update({
      'photoUrls': FieldValue.arrayUnion(urls),
    });
  }

  Future<List<ReviewModel>> getReviewsForProduct(String id) async {
    List<ReviewModel> reviews = [];
    var blockedUsersIds = Get.find<AuthService>().user?.blockedUsers ?? [];

    log('wtf');

    if (blockedUsersIds.isEmpty) {
      log('kek');
      var cloud = FirebaseFirestore.instance;
      var res = await cloud
          .collection('reviews')
          .where('productBarcode', isEqualTo: id)
          .orderBy('createDate', descending: true)
          .limit(10)
          .get();

      for (var doc in res.docs) {
        reviews.add(ReviewModel.fromMap(doc.data()));
      }

      return reviews;
    } else {
      var cloud = FirebaseFirestore.instance;
      var res = await cloud
          .collection('reviews')
          .where('productBarcode', isEqualTo: id)
          .where('authorId', isNotEqualTo: blockedUsersIds)
          .orderBy('authorId')
          .orderBy('createDate', descending: true)
          .limit(10)
          .get();

      for (var doc in res.docs) {
        reviews.add(ReviewModel.fromMap(doc.data()));
      }

      return reviews;
    }
  }

  Future<void> createReview({
    required String authorId,
    required String barcode,
    required String text,
    required double rating,
  }) async {
    var cloud = FirebaseFirestore.instance;

    var review = ReviewModel(
      id: const Uuid().v4(),
      authorId: authorId,
      createDate: DateTime.now().toUtc().millisecondsSinceEpoch,
      countLikes: 0,
      whoLikeIds: [],
      productBarcode: barcode,
      text: text,
      rating: rating,
    );

    await cloud.doc('reviews/${review.id}').set(review.toMap());

    var product = await getProduct(barcode);
    if (rating == 1) {
      product.rate.count1 += 1;
    } else if (rating == 2) {
      product.rate.count2 += 1;
    } else if (rating == 3) {
      product.rate.count3 += 1;
    } else if (rating == 4) {
      product.rate.count4 += 1;
    } else if (rating == 5) {
      product.rate.count5 += 1;
    }

    product.rating = product.rate.sum / product.rate.allCount;

    await cloud.doc('products/${product.barcode}').update({
      'rate': product.rate.toMap(),
      'rating': product.rating,
    });

    await Get.find<AuthService>().addProductIdReviewForUser(
      productId: barcode,
    );
  }

  Future<void> updateReview(ReviewModel review) async {
    var cloud = FirebaseFirestore.instance;
    await cloud.doc('reviews/${review.id}').update(review.toMap());
  }

  Future<ProductModel> deleteReview(
    String productId,
    String reviewId,
    double rating,
  ) async {
    var product = await getProduct(productId);

    if (rating == 1) {
      product.rate.count1 -= 1;
    } else if (rating == 2) {
      product.rate.count2 -= 1;
    } else if (rating == 3) {
      product.rate.count3 -= 1;
    } else if (rating == 4) {
      product.rate.count4 -= 1;
    } else if (rating == 5) {
      product.rate.count5 -= 1;
    }

    if (product.rate.sum == 0 || product.rate.allCount == 0) {
      product.rating = 0;
    } else {
      product.rating = product.rate.sum / product.rate.allCount;
    }
    await FirebaseFirestore.instance.doc('products/${product.barcode}').update({
      'rate': product.rate.toMap(),
      'rating': product.rating,
    });

    await FirebaseFirestore.instance.doc('reviews/$reviewId').delete();

    await Get.find<AuthService>().deleteReview(productId);

    return product;
  }

  Future<ProductModel> editReview({
    required String productId,
    required String reviewId,
    required String newText,
    required double newRating,
    required double oldRating,
  }) async {
    var product = await getProduct(productId);

    if (oldRating == 1) {
      product.rate.count1 -= 1;
    } else if (oldRating == 2) {
      product.rate.count2 -= 1;
    } else if (oldRating == 3) {
      product.rate.count3 -= 1;
    } else if (oldRating == 4) {
      product.rate.count4 -= 1;
    } else if (oldRating == 5) {
      product.rate.count5 -= 1;
    }

    if (newRating == 1) {
      product.rate.count1 += 1;
    } else if (newRating == 2) {
      product.rate.count2 += 1;
    } else if (newRating == 3) {
      product.rate.count3 += 1;
    } else if (newRating == 4) {
      product.rate.count4 += 1;
    } else if (newRating == 5) {
      product.rate.count5 += 1;
    }

    if (product.rate.sum == 0 || product.rate.allCount == 0) {
      product.rating = 0;
    } else {
      product.rating = product.rate.sum / product.rate.allCount;
    }

    await FirebaseFirestore.instance.doc('products/${product.barcode}').update({
      'rate': product.rate.toMap(),
      'rating': product.rating,
    });

    await FirebaseFirestore.instance.doc('reviews/$reviewId').update({
      'text': newText,
      'rating': newRating,
    });

    return product;
  }

  Future<void> setCategoryForProduct({
    required String barcode,
    required String categoryId,
  }) async {
    await FirebaseFirestore.instance.doc('products/$barcode').update({
      'categoryId': categoryId,
    });
  }

  Future<void> updateProductName({
    required String barcode,
    required String name,
  }) async {
    var productDescription = [
      ProductInfoModel(
        language: Get.find<LanguageService>().locale.languageCode.toLowerCase(),
        value: name,
      ),
    ];

    await FirebaseFirestore.instance.doc('products/$barcode').update({
      'productDescription': productDescription.map((x) => x.toMap()).toList(),
    });
  }

  Future<ProductModel?> getInfoFromFoodFacts(String barcode) async {
    try {
      var res = await Dio().post(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) {
            return status! <= 500;
          },
        ),
      );
      var data = res.data['product'];

      List<ProductInfoModel> photoUrls = [];
      if (data?['selected_images']?['front']?['display'] != null) {
        var display = data['selected_images']['front']['display'];
        display.forEach((key, value) {
          photoUrls.add(
            ProductInfoModel(language: key, value: value),
          );
        });
      }

      List<ProductInfoModel> productDescription = [];
      if (data?['product_name_en'] != null) {
        productDescription.add(
          ProductInfoModel(language: 'en', value: data?['product_name_en']),
        );
      } else if (data?['product_name_es'] != null) {
        productDescription.add(
          ProductInfoModel(language: 'es', value: data?['product_name_es']),
        );
      } else if (data?['product_name_fr'] != null) {
        productDescription.add(
          ProductInfoModel(language: 'fr', value: data?['product_name_fr']),
        );
      } else if (data?['product_name_hu'] != null) {
        productDescription.add(
          ProductInfoModel(language: 'hu', value: data?['product_name_hu']),
        );
      } else if (data?['product_name_it'] != null) {
        productDescription.add(
          ProductInfoModel(language: 'it', value: data?['product_name_it']),
        );
      } else if (data?['product_name_pl'] != null) {
        productDescription.add(
          ProductInfoModel(language: 'pl', value: data?['product_name_pl']),
        );
      } else if (data?['product_name_de'] != null) {
        productDescription.add(
          ProductInfoModel(language: 'de', value: data?['product_name_de']),
        );
      }

      List<ProductInfoModel> brandName = [];
      if (data?['brands'] != null && data?['brands'] is String) {
        brandName.add(
          ProductInfoModel(
            language: 'en',
            value: data['brands'].toString(),
          ),
        );
      }

      List<ProductCountryOfSaleModel> countryOfSaleCode = [];
      if (data?['countries'] != null && data?['countries'] is String) {
        countryOfSaleCode.add(
          ProductCountryOfSaleModel(
            numeric: data['countries'].toString(),
            alpha2: data['countries'].toString(),
            alpha3: data['countries'].toString(),
          ),
        );
      }

      var product = ProductModel(
        gtin: barcode,
        photoUrls: photoUrls,
        productDescription:
            productDescription.isEmpty ? null : productDescription,
        brandName: brandName.isEmpty ? null : brandName,
        licenseeName: null,
        dateCreated: null,
        rate: ProductRateModel(
          count1: 0,
          count2: 0,
          count3: 0,
          count4: 0,
          count5: 0,
        ),
        categoryId: null,
        countryOfSaleCode: countryOfSaleCode.isEmpty ? null : countryOfSaleCode,
        rating: 0,
        barcode: barcode,
        q: [],
      );

      return product;
    } catch (e) {
      log(e.toString(), name: 'error getInfoFromFoodFacts');
      return null;
    }
  }

  Future<void> createNewProduct(ProductModel product) async {
    await FirebaseFirestore.instance.doc('products/${product.barcode}').set(
          product.toMap(),
        );
  }
}
