import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/functions/chunk_list.dart';

class FavRep {
  Future<List<ProductModel>> getProducts(List<String> barcodes) async {
    if (barcodes.isEmpty) return [];
    List<ProductModel> products = [];

    var chunks = barcodes.chunk(30);
    for (var chunk in chunks) {
      var res = await FirebaseFirestore.instance
          .collection('products')
          .where('barcode', whereIn: chunk)
          .limit(30)
          .get();
      for (var doc in res.docs) {
        try {
          products.add(ProductModel.fromMap(doc.data()));
        } catch (e) {
          log(e.toString());
        }
      }
    }

    return products;
  }

  Future<void> saveFav({
    required String userId,
    required List<String> ids,
  }) async {
    await FirebaseFirestore.instance.doc('users/$userId').update({
      'favIds': ids,
    });
  }
}
