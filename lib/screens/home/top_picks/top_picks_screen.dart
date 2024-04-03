import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/services/top_picks_service.dart';
import 'package:foodika/widget/app_bar_widget.dart';
import 'package:foodika/widget/build_products_grid.dart';
import 'package:get/get.dart';

class TopPicksScreen extends StatefulWidget {
  const TopPicksScreen({super.key});

  @override
  State<TopPicksScreen> createState() => _TopPicksScreenState();
}

class _TopPicksScreenState extends State<TopPicksScreen>
    with AutomaticKeepAliveClientMixin<TopPicksScreen> {
  String? lastSearch;
  bool _isLoadingSearch = false;
  bool isNoreMoreSearch = false;
  List<ProductModel> searchProducts = [];
  DocumentSnapshot<Object?>? searchLastDoc;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GetBuilder<TopPicksService>(builder: (service) {
      return Scaffold(
        appBar: AppBarWidget.home('Top Picks'.tr),
        body: BuildProductsGrid(
          products: lastSearch == null ? service.products : searchProducts,
          isNoMore: lastSearch == null ? service.isNoMore : isNoreMoreSearch,
          isLoading: _isLoadingSearch,
          loadMore: () async {
            if (lastSearch == null) {
              await service.loadMore();
            } else {
              if (lastSearch == null) return;
              if (searchLastDoc == null) return;

              var res = await service.searchLoadMore(
                q: lastSearch!,
                lastDoc: searchLastDoc!,
              );
              var newProducts = [...res.products];

              searchLastDoc = res.lastDoc;
              searchProducts.addAll(newProducts);
              if (newProducts.length < 24) isNoreMoreSearch = true;
              setState(() {});
            }
          },
          onSearch: (q) async {
            if (q.isEmpty) {
              setState(() {
                lastSearch = null;
                _isLoadingSearch = false;
                isNoreMoreSearch = false;
                searchProducts = [];
                searchLastDoc = null;
              });
              return;
            }

            isNoreMoreSearch = false;
            lastSearch = q;
            setState(() => _isLoadingSearch = true);

            var res = await service.search(q: q);
            searchProducts = [...res.products];
            searchLastDoc = res.lastDoc;
            if (searchProducts.length < 24) isNoreMoreSearch = true;

            setState(() => _isLoadingSearch = false);
          },
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
