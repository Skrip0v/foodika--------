import 'dart:developer';

import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/models/review_model.dart';
import 'package:foodika/core/repos/products_rep.dart';
import 'package:foodika/core/services/auth_service.dart';
import 'package:foodika/core/services/categories_service.dart';
import 'package:foodika/core/services/fav_service.dart';
import 'package:foodika/core/services/my_scans_service.dart';
import 'package:foodika/core/services/top_picks_service.dart';
import 'package:foodika/core/services/users_service.dart';
import 'package:foodika/screens/product/product_screen.dart';
import 'package:get/get.dart';

class ProductsService extends GetxService {
  final _productsRep = ProductsRep();

  Future<void> scan(String barcode) async {
    var product = await _productsRep.getProductFromGS1(barcode);
    if (product == null) return;
    await Get.find<MyScansService>().addProductToMyScans(product.barcode);
    Get.back();
    Get.to(() => ProductScreen(product: product));
    sendNewProductToOtherServices([product]);
  }

  Future<ProductModel> savePhotosToProduct(
    List<String> filePaths,
    String barcode,
  ) async {
    await _productsRep.savePhotosToProduct(filePaths, barcode);
    var product = await _productsRep.getProduct(barcode);

    sendNewProductToOtherServices([product]);

    return product;
  }

  void sendNewProductToOtherServices(List<ProductModel> products) {
    Get.find<MyScansService>().updateProducts(products);
    Get.find<FavService>().updateProducts(products);
    Get.find<TopPicksService>().updateProducts(products);
  }

  Future<List<ReviewModel>> getReviews(String id) async {
    var reviews = await _productsRep.getReviewsForProduct(id);

    var ids = reviews.map((e) => e.authorId).toList();
    await Get.find<UsersService>().getInfoAboutUsers(ids);

    return reviews;
  }

  Future<List<ReviewModel>> createReview({
    required String barcode,
    required String? categoryId,
    required String text,
    required double rating,
  }) async {
    var userId = Get.find<AuthService>().user?.id;
    if (userId != null) {
      await _productsRep.createReview(
        authorId: userId,
        barcode: barcode,
        text: text,
        rating: rating,
      );
    }

    var product = await _productsRep.getProduct(barcode);
    sendNewProductToOtherServices([product]);

    if (categoryId != null) {
      await Get.find<CategoriesService>().onCreateReview(categoryId);
    }

    return _productsRep.getReviewsForProduct(barcode);
  }

  Future<ProductModel> getProduct(String id) async {
    var product = await _productsRep.getProduct(id);
    sendNewProductToOtherServices([product]);
    return product;
  }

  Future<void> updateReview(
    ReviewModel review,
  ) async {
    await _productsRep.updateReview(review);
  }

  Future<void> deleteReview({
    required String productId,
    required String reviewId,
    required String? categoryId,
    required double rating,
  }) async {
    var product = await _productsRep.deleteReview(productId, reviewId, rating);
    sendNewProductToOtherServices([product]);

    if (categoryId != null) {
      await Get.find<CategoriesService>().onDeleteReview(categoryId);
    }
  }

  Future<void> editReview({
    required String productId,
    required String reviewId,
    required String newText,
    required double newRating,
    required double oldRating,
  }) async {
    var product = await _productsRep.editReview(
      productId: productId,
      reviewId: reviewId,
      newText: newText,
      newRating: newRating,
      oldRating: oldRating,
    );

    sendNewProductToOtherServices([product]);
  }

  Future<ProductModel> setCategoryForProduct({
    required String barcode,
    required String categoryId,
  }) async {
    await _productsRep.setCategoryForProduct(
      barcode: barcode,
      categoryId: categoryId,
    );

    var product = await _productsRep.getProduct(barcode);
    sendNewProductToOtherServices([product]);

    return product;
  }

  Future<ProductModel> updateProductName({
    required String barcode,
    required String name,
  }) async {
    await _productsRep.updateProductName(barcode: barcode, name: name);

    var product = await _productsRep.getProduct(barcode);
    sendNewProductToOtherServices([product]);

    return product;
  }
}
