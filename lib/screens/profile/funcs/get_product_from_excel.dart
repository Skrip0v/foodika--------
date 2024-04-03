import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:foodika/core/models/product_model.dart';

Future<List<ProductModel>> getProductsFromExcel() async {
  var pickExcel = await FilePicker.platform.pickFiles(
    allowMultiple: false,
  );

  if (pickExcel == null) return [];
  var excelFile = pickExcel.files.first;

  var bytes = await File(excelFile.path!).readAsBytes();
  var e = Excel.decodeBytes(bytes);

  List<ProductModel> products = [];

  //convert
  for (var i = 1; i < e.tables['Лист 1']!.rows.length; i++) {
    var row = e.tables['Лист 1']!.rows[i];
    if (row[2] == null) continue;
    if (row[1] == null) continue;

    var code = row[2]!.value.toString();
    var photo = row[3]?.value;

    //   var product = ProductModel(
    //     gtin: code,
    //     barcode: code,
    //     q: [],
    //     photoUrls: photo == null
    //         ? []
    //         : [
    //             'https://firebasestorage.googleapis.com/v0/b/foodika-fe6ef.appspot.com/o/product_images%2F$code.png?alt=media&token=fcfd1d62-133f-40f1-bd4e-13ea2b5e1fd2',
    //           ],
    //     productDescription: [
    //       ProductInfoModel(language: 'lt', value: row[1]!.value.toString()),
    //     ],
    //     brandName: [],
    //     licenseeName: '',
    //     dateCreated: '0',
    //     rate: ProductRateModel(
    //       count1: 0,
    //       count2: 0,
    //       count3: 0,
    //       count4: 0,
    //       count5: 0,
    //     ),
    //     categoryId: null,
    //     countryOfSaleCode: [],
    //     rating: 0,
    //   );
    //   products.add(product);
    // }
  }
  return products;
}
