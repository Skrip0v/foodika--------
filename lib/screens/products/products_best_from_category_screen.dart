import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/services/categories_service.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/widget/app_bar_widget.dart';
import 'package:foodika/widget/build_products_grid.dart';
import 'package:get/get.dart';

class ProductsBestFromCategoryScreen extends StatefulWidget {
  const ProductsBestFromCategoryScreen({
    super.key,
    required this.categoryId,
    required this.productBarcode,
  });
  final String productBarcode;
  final String categoryId;
  @override
  State<ProductsBestFromCategoryScreen> createState() =>
      _ProductsBestFromCategoryScreenState();
}

class _ProductsBestFromCategoryScreenState
    extends State<ProductsBestFromCategoryScreen> {
  bool isInitLoading = true;

  List<ProductModel> products = [];
  var count = 27;
  var isNoMore = false;
  DocumentSnapshot? lastDoc;

  //Search
  String? lastSearch;
  bool _isLoadingSearch = false;
  bool isNoreMoreSearch = false;
  List<ProductModel> searchProducts = [];
  DocumentSnapshot<Object?>? lastSearchDoc;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    var res = await Get.find<CategoriesService>().getBestProductsFromCategory(
      productBarcode: widget.productBarcode,
      categoryId: widget.categoryId,
      count: count,
    );
    if (res.products.length < count) isNoMore = true;
    products = [...res.products];
    lastDoc = res.lastDoc;

    isInitLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.titleAndBack('Best Products'.tr),
      body: Builder(builder: (context) {
        if (isInitLoading == true) {
          return Center(
            child: CupertinoActivityIndicator(
              color: AppColors.orange,
            ),
          );
        }
        return BuildProductsGrid(
          products: lastSearch == null ? products : searchProducts,
          isNoMore: lastSearch == null ? isNoMore : isNoreMoreSearch,
          loadMore: loadMore,
          isLoading: _isLoadingSearch,
          onSearch: search,
        );
      }),
    );
  }

  Future<void> loadMore() async {
    if (lastSearch == null) {
      if (lastDoc == null) return;

      var res = await Get.find<CategoriesService>().getBestProductsFromCategory(
        productBarcode: widget.productBarcode,
        categoryId: widget.categoryId,
        count: count,
        startAfter: lastDoc,
      );
      if (res.products.length < count) isNoMore = true;
      lastDoc = res.lastDoc;
      products.addAll([...res.products]);
      setState(() {});
    } else {
      if (lastSearch == null) return;
      if (lastSearchDoc == null) return;
      var service = Get.find<CategoriesService>();
      var res = await service.searchBestLoadMore(
        q: lastSearch!,
        lastDoc: lastSearchDoc!,
        count: count,
        categoryId: widget.categoryId,
      );

      var newProducts = [...res.products];

      lastSearchDoc = res.lastDoc;
      searchProducts.addAll(newProducts);
      if (newProducts.length < count) isNoreMoreSearch = true;
      setState(() {});
    }
  }

  Future<void> search(String q) async {
    if (q.isEmpty) {
      setState(() {
        lastSearch = null;
        _isLoadingSearch = false;
        isNoreMoreSearch = false;
        searchProducts = [];
        lastSearchDoc = null;
      });
      return;
    }

    isNoreMoreSearch = false;
    lastSearch = q;
    setState(() => _isLoadingSearch = true);

    var service = Get.find<CategoriesService>();
    var res = await service.searchBest(
      q: q,
      categoryId: widget.categoryId,
      count: count,
    );
    searchProducts = [...res.products];
    lastSearchDoc = res.lastDoc;
    if (searchProducts.length < count) isNoreMoreSearch = true;

    setState(() => _isLoadingSearch = false);
  }
}
