import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/models/user_model.dart';

class UsersRep {
  Future<List<UserModel>> getUsers(List<String> ids) async {
    List<UserModel> users = [];

    var cloud = FirebaseFirestore.instance;
    var res = await cloud
        .collection('users')
        .where('id', whereIn: ids)
        .limit(ids.length)
        .get();

    for (var doc in res.docs) {
      users.add(UserModel.fromMap(doc.data()));
    }

    return users;
  }

  Future<List<ProductModel>> getFavProductForUser(List<String> barcodes) async {
    List<ProductModel> products = [];
    if (barcodes.isEmpty) return [];

    var res = await FirebaseFirestore.instance
        .collection('products')
        .where('barcode', whereIn: barcodes)
        .limit(33)
        .get();

    for (var doc in res.docs) {
      products.add(ProductModel.fromMap(doc.data()));
    }

    return products;
  }
}
