import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/functions/chunk_list.dart';

class MyScansRep {
  Future<List<ProductModel>> getMyScans(
    String userId,
    List<String> barcodes,
  ) async {
    if (barcodes.isEmpty) return [];

    List<ProductModel> products = [];
    var chunks = barcodes.chunk(12);
    // for (var chunk in chunks) {
    var res = await FirebaseFirestore.instance
        .collection('products')
        .where('barcode', whereIn: chunks.last)
        .where('productDescription', isNull: false)
        .limit(12)
        .get();
    for (var doc in res.docs) {
      try {
        products.add(ProductModel.fromMap(doc.data()));
      } catch (e) {
        log(e.toString());
      }
    }
    // }

    return products;
  }

  Future<void> saveProductsIdsToMyScans({
    required String userId,
    required List<String> ids,
  }) async {
    await FirebaseFirestore.instance.doc('users/$userId').update({
      'myScansIds': ids,
    });
  }

  Future<ProductModel> getProduct(String barcode) async {
    var cloud = FirebaseFirestore.instance;
    var res = await cloud.doc('products/$barcode').get();
    return ProductModel.fromMap(res.data()!);
  }
}
