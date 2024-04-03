import 'package:flutter/material.dart';
import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/services/fav_service.dart';
import 'package:foodika/widget/app_bar_widget.dart';
import 'package:foodika/widget/build_products_grid.dart';
import 'package:get/get.dart';

class ProfileFavScreen extends StatefulWidget {
  const ProfileFavScreen({super.key});

  @override
  State<ProfileFavScreen> createState() => _ProfileFavScreenState();
}

class _ProfileFavScreenState extends State<ProfileFavScreen> {
  String? lastSearch;
  List<ProductModel> searchProducts = [];
  bool isLoadingSearch = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.titleAndBack('Favorite'.tr),
      body: GetBuilder<FavService>(builder: (service) {
        var products = service.fav;
        return BuildProductsGrid(
          products: lastSearch == null ? products : searchProducts,
          isLoading: isLoadingSearch,
          onSearch: search,
        );
      }),
    );
  }

  Future<void> search(q) async {
    if (q.isEmpty) {
      setState(() {
        lastSearch = null;
        searchProducts = [];
        isLoadingSearch = false;
      });
      return;
    }

    setState(() {
      isLoadingSearch = true;
      searchProducts = [];
      lastSearch = q;
    });

    await Future.delayed(250.milliseconds);

    var allProducts = Get.find<FavService>().fav;
    for (var product in allProducts) {
      if (product.q.contains(q)) {
        searchProducts.add(product);
      }
    }

    setState(() => isLoadingSearch = false);
  }
}
