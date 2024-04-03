import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/services/my_scans_service.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/style/app_text_style.dart';
import 'package:foodika/widget/build_products_grid.dart';
import 'package:foodika/widget/categories_widget.dart';
import 'package:foodika/widget/product_widget.dart';
import 'package:get/get.dart';

class MyScansFullScreen extends StatefulWidget {
  const MyScansFullScreen({super.key});

  @override
  State<MyScansFullScreen> createState() => _MyScansFullScreenState();
}

class _MyScansFullScreenState extends State<MyScansFullScreen> {
  bool isSeeAllPressed = false;
  final searchController = TextEditingController();
  var focus = FocusNode();

  Timer? _debounceTimer;
  String? lastSearch;
  List<ProductModel> searchProducts = [];
  bool isLoadingSearch = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              Builder(builder: (context) {
                if (isSeeAllPressed == false) {
                  return Container(
                    alignment: Alignment.centerRight,
                    child: CupertinoButton(
                      padding:
                          const EdgeInsets.only(bottom: 5, right: 15, top: 15),
                      minSize: 0,
                      child: Text(
                        'See all'.tr,
                        style: const TextStyle(
                          color: Color(0xFF6B6770),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          isSeeAllPressed = true;
                        });
                      },
                    ),
                  );
                }
                return Container(
                  margin: const EdgeInsets.fromLTRB(15, 7.5, 15, 18),
                  child: TextField(
                    focusNode: focus,
                    controller: searchController,
                    cursorColor: const Color(0xFF6B6770),
                    onTapOutside: (event) {
                      focus.unfocus();
                    },
                    onChanged: _onTypingFinished,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 13.5,
                        bottom: 13.5,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.orange,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.orange,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.orange,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Search'.tr,
                      hintStyle: const TextStyle(
                        color: Color(0xFFA19CA9),
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIconConstraints: const BoxConstraints(maxWidth: 50),
                      prefixIcon: Container(
                        height: 22,
                        width: 22,
                        margin: const EdgeInsets.only(left: 15, right: 5),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/search.svg',
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              GetBuilder<MyScansService>(builder: (service) {
                List<ProductModel> products = [];
                if (lastSearch == null) {
                  products = service.myScans;
                } else {
                  products = searchProducts;
                }
                if (isLoadingSearch == true) {
                  return Container(
                    height: Get.height * 0.42,
                    alignment: Alignment.center,
                    child: CupertinoActivityIndicator(
                      color: AppColors.orange,
                      radius: 12,
                    ),
                  );
                }

                if (products.isEmpty) {
                  return Container(
                    height: Get.height * 0.42,
                    alignment: Alignment.center,
                    child: Text(
                      'Empty'.tr,
                      style: AppTextStyle.bodyText.copyWith(
                        color: AppColors.middleGrey,
                      ),
                    ),
                  );
                }

                return Container(
                  constraints: BoxConstraints(
                    minHeight: Get.height * 0.42,
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.97,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      return ProductWidget(product: product);
                    },
                  ),
                );
              }),
              const SizedBox(height: 15),
            ],
          ),
        ),
        const CategoriesWidget(),
      ],
    );
  }

  void _onTypingFinished(String text) {
    if (_debounceTimer != null) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      onSearch(text);
    });
  }

  Future<void> onSearch(String q) async {
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

    var allProducts = Get.find<MyScansService>().myScans;
    for (var product in allProducts) {
      if (product.q.contains(q)) {
        searchProducts.add(product);
      }
    }

    setState(() => isLoadingSearch = false);
  }
}
