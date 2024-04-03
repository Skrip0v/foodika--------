// import 'dart:io';

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:excel/excel.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:foodika/core/models/category_model.dart';
import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/repos/top_picks_rep.dart';
// import 'package:get/get.dart';
// import 'package:uuid/uuid.dart';

class CategoriesRep {
  // Future<void> readFile() async {
  //   // var result = await FilePicker.platform.pickFiles(allowMultiple: false);

  //   // if (result == null) return;
  //   // var file = result.files.first;

  //   // var bytes = await File(file.path!).readAsBytes();
  //   // var excel = Excel.decodeBytes(bytes);

  //   // List<CategoryModel> categories = [];

  //   // for (var i = 0; i < excel.tables['Sheet1']!.rows.length; i++) {
  //   //   var row = excel.tables['Sheet1']!.rows[i];
  //   //   if (row[0]!.value.toString() == 'GPC Class Code') continue;

  //   //   var code = row[0]!.value.toString();
  //   //   var classDescription = row[1]!.value.toString();
  //   //   var en = row[2]!.value.toString();
  //   //   var ru = row[3]!.value.toString();
  //   //   var lv = row[4]!.value.toString();
  //   //   var lt = row[5]!.value.toString();
  //   //   var et = row[6]!.value.toString();

  //   //   //check is already exists

  //   //   var isExist = categories.firstWhereOrNull(
  //   //     (e) => e.name['en'] == en,
  //   //   );
  //   //   if (isExist == null) {
  //   //     categories.add(
  //   //       CategoryModel(
  //   //         sort: i,
  //   //         id: const Uuid().v4(),
  //   //         name: {
  //   //           'en': en,
  //   //           'ru': ru,
  //   //           'lv': lv,
  //   //           'lt': lt,
  //   //           'et': et,
  //   //         },
  //   //         codes: [code],
  //   //         classDescription: [
  //   //           classDescription,
  //   //         ],
  //   //         photoUrl: '',
  //   //       ),
  //   //     );
  //   //   } else {
  //   //     var index = categories.indexOf(isExist);
  //   //     categories[index].codes.add(code);
  //   //     categories[index].classDescription.add(classDescription);
  //   //   }
  //   // }

  //   // for (var category in categories) {
  //   //   var cloud = FirebaseFirestore.instance;
  //   //   await cloud.doc('categories/${category.id}').set(category.toMap());
  //   // }
  // }

  Future<List<CategoryModel>> getCategories() async {
    var cloud = FirebaseFirestore.instance;
    var res = await cloud.collection('categories').get();
    List<CategoryModel> categories = [];
    for (var doc in res.docs) {
      categories.add(CategoryModel.fromMap(doc.data()));
    }

    categories.sort(
      (b, a) => a.countRateProductsFromThisCategory.compareTo(
        b.countRateProductsFromThisCategory,
      ),
    );

    return [...categories];
  }

  Future<GetProductsRes> getBestProductsFromCategory({
    required String categoryId,
    required int count,
    DocumentSnapshot? startAfter,
    String? q,
  }) async {
    List<ProductModel> products = [];

    var cloud = FirebaseFirestore.instance;
    late QuerySnapshot<Map<String, dynamic>> res;

    if (startAfter == null) {
      if (q == null) {
        res = await cloud
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
            .orderBy('rating', descending: true)
            .limit(count)
            .get();
      } else {
        res = await cloud
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
            .where('q', arrayContains: q)
            .orderBy('rating', descending: true)
            .limit(count)
            .get();
      }
    } else {
      if (q == null) {
        res = await cloud
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
            .orderBy('rating', descending: true)
            .startAfterDocument(startAfter)
            .limit(count)
            .get();
      } else {
        res = await cloud
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
            .where('q', arrayContains: q)
            .orderBy('rating', descending: true)
            .startAfterDocument(startAfter)
            .limit(count)
            .get();
      }
    }

    for (var doc in res.docs) {
      try {
        products.add(ProductModel.fromMap(doc.data()));
      } catch (e) {
        log(
          e.toString(),
          name: 'error get product `getBestProductsFromCategory`',
        );
      }
    }

    return GetProductsRes(
      lastDoc: res.docs.isEmpty ? null : res.docs.last,
      products: products,
    );
  }

  Future<GetProductsRes> getProductsForCategory({
    required String categoryId,
    required int count,
    DocumentSnapshot? startAfter,
    String? q,
  }) async {
    var cloud = FirebaseFirestore.instance;

    late QuerySnapshot<Map<String, dynamic>> res;
    if (startAfter == null) {
      if (q == null) {
        res = await cloud
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
            .orderBy('rating', descending: true)
            .limit(count)
            .get();
      } else {
        res = await cloud
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
            .where('q', arrayContains: q)
            .orderBy('rating', descending: true)
            .limit(count)
            .get();
      }
    } else {
      if (q == null) {
        res = await cloud
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
            .orderBy('rating', descending: true)
            .startAfterDocument(startAfter)
            .limit(count)
            .get();
      } else {
        res = await cloud
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
            .where('q', arrayContains: q)
            .orderBy('rating', descending: true)
            .startAfterDocument(startAfter)
            .limit(count)
            .get();
      }
    }

    List<ProductModel> products = [];
    for (var doc in res.docs) {
      try {
        products.add(ProductModel.fromMap(doc.data()));
      } catch (e) {
        log(
          e.toString(),
          name: 'error get product `getBestProductsFromCategory`',
        );
      }
    }

    return GetProductsRes(
      lastDoc: res.docs.isEmpty ? null : res.docs.last,
      products: products,
    );
  }

  Future<void> onCreateReview(String categoryId) async {
    await FirebaseFirestore.instance
        .doc(
      'categories/$categoryId',
    )
        .update({
      'countRateProductsFromThisCategory': FieldValue.increment(1),
    });
  }

  Future<void> onDeleteReview(String categoryId) async {
    await FirebaseFirestore.instance
        .doc(
      'categories/$categoryId',
    )
        .update({
      'countRateProductsFromThisCategory': FieldValue.increment(-1),
    });
  }
}
