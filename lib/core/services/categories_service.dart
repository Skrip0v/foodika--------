import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:foodika/core/models/category_model.dart';
import 'package:foodika/core/repos/categories_rep.dart';
import 'package:foodika/core/repos/top_picks_rep.dart';

class CategoriesService extends GetxController {
  List<CategoryModel> categories = [];
  final _categoriesRep = CategoriesRep();

  Future<void> init() async {
    categories = await _categoriesRep.getCategories();
    update();
  }

  Future<GetProductsRes> getBestProductsFromCategory({
    required String categoryId,
    required int count,
    required String productBarcode,
    DocumentSnapshot? startAfter,
  }) async {
    var res = await _categoriesRep.getBestProductsFromCategory(
      categoryId: categoryId,
      count: count,
      startAfter: startAfter,
    );

    var product = res.products;
    product.removeWhere((e) => e.barcode == productBarcode);

    return GetProductsRes(
      lastDoc: res.lastDoc,
      products: product,
    );
  }

  Future<GetProductsRes> getProductsForCategory({
    required String categoryId,
    required int count,
    DocumentSnapshot? startAfter,
  }) async {
    return await _categoriesRep.getProductsForCategory(
      categoryId: categoryId,
      count: count,
      startAfter: startAfter,
    );
  }

  Future<GetProductsRes> search({
    required String categoryId,
    required String q,
    required int count,
  }) async {
    var res = await _categoriesRep.getProductsForCategory(
      categoryId: categoryId,
      count: count,
      q: q,
    );
    return res;
  }

  Future<GetProductsRes> searchLoadMore({
    required String q,
    required DocumentSnapshot<Object?> lastDoc,
    required String categoryId,
    required int count,
  }) async {
    var res = await _categoriesRep.getProductsForCategory(
      categoryId: categoryId,
      count: count,
      startAfter: lastDoc,
      q: q,
    );
    return res;
  }

  Future<GetProductsRes> searchBest({
    required String categoryId,
    required String q,
    required int count,
  }) async {
    var res = await _categoriesRep.getBestProductsFromCategory(
      categoryId: categoryId,
      count: count,
      q: q,
    );
    return res;
  }

  Future<GetProductsRes> searchBestLoadMore({
    required String q,
    required DocumentSnapshot<Object?> lastDoc,
    required String categoryId,
    required int count,
  }) async {
    var res = await _categoriesRep.getBestProductsFromCategory(
      categoryId: categoryId,
      count: count,
      startAfter: lastDoc,
      q: q,
    );
    return res;
  }

  Future<void> onCreateReview(String categoryId) async {
    await _categoriesRep.onCreateReview(categoryId);
  }

  Future<void> onDeleteReview(String categoryId) async {
    await _categoriesRep.onDeleteReview(categoryId);
  }
}
