import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/repos/top_picks_rep.dart';
import 'package:get/get.dart';

class TopPicksService extends GetxController {
  List<ProductModel> products = [];
  final _topPicksRep = TopPicksRep();
  var isNoMore = false;
  DocumentSnapshot? _lastDoc;

  Future<void> init() async {
    var res = await _topPicksRep.getTopPicks();
    products = res.products;
    _lastDoc = res.lastDoc;

    if (products.length < 24) isNoMore = true;
    update();
  }

  Future<void> loadMore() async {
    if (isNoMore == true) return;
    if (_lastDoc == null) {
      isNoMore = true;
      update();
      return;
    }

    var res = await _topPicksRep.loadMoreTopPicks(_lastDoc!);
    var newProducts = res.products;
    if (newProducts.length < 24) isNoMore = true;

    products.addAll(newProducts);
    products = [...products];
    _lastDoc = res.lastDoc;
    update();
  }

  Future<GetProductsRes> search({
    required String q,
  }) async {
    var res = await _topPicksRep.getTopPicks(q: q);
    return res;
  }

  Future<GetProductsRes> searchLoadMore({
    required String q,
    required DocumentSnapshot<Object?> lastDoc,
  }) async {
    var res = await _topPicksRep.loadMoreTopPicks(lastDoc, q: q);
    return res;
  }

  void updateProducts(List<ProductModel> newProducts) {
    var isHasChanges = false;

    for (var product in newProducts) {
      var inMyScan =
          products.firstWhereOrNull((e) => e.barcode == product.barcode);
      if (inMyScan == null) continue;
      isHasChanges = true;
      var index = products.indexOf(inMyScan);
      products[index] = product;
    }
    if (isHasChanges == false) return;

    update();
  }
}
