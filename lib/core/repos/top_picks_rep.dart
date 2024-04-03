// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:foodika/core/models/product_model.dart';

class TopPicksRep {
  Future<GetProductsRes> getTopPicks({String? q}) async {
    late QuerySnapshot<Map<String, dynamic>> res;
    if (q == null) {
      res = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('rating', descending: true)
          .limit(24)
          .get();
    } else {
      res = await FirebaseFirestore.instance
          .collection('products')
          .where('q', arrayContains: q)
          .orderBy('rating', descending: true)
          .limit(24)
          .get();
    }

    List<ProductModel> products = [];

    for (var doc in res.docs) {
      products.add(ProductModel.fromMap(doc.data()));
    }

    return GetProductsRes(
      lastDoc: res.docs.isEmpty ? null : res.docs.last,
      products: products,
    );
  }

  Future<GetProductsRes> loadMoreTopPicks(
    DocumentSnapshot lastDoc, {
    String? q,
  }) async {
    QuerySnapshot<Map<String, dynamic>> res;

    if (q == null) {
      res = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('rating', descending: true)
          .startAfterDocument(lastDoc)
          .limit(24)
          .get();
    } else {
      res = await FirebaseFirestore.instance
          .collection('products')
          .where('q', arrayContains: q)
          .orderBy('rating', descending: true)
          .startAfterDocument(lastDoc)
          .limit(24)
          .get();
    }

    List<ProductModel> products = [];

    for (var doc in res.docs) {
      products.add(ProductModel.fromMap(doc.data()));
    }

    return GetProductsRes(
      lastDoc: res.docs.isEmpty ? null : res.docs.last,
      products: products,
    );
  }
}

class GetProductsRes {
  DocumentSnapshot? lastDoc;
  List<ProductModel> products;

  GetProductsRes({
    required this.lastDoc,
    required this.products,
  });
}
