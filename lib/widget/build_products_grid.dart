import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/style/app_text_style.dart';
import 'package:foodika/widget/product_widget.dart';
import 'package:get/get.dart';

class BuildProductsGrid extends StatefulWidget {
  const BuildProductsGrid({
    super.key,
    required this.products,
    this.bottomPaddingBetweenSeeAllAndGrid = 10,
    this.colorSeeAllButton,
    this.isNoMore = true,
    this.isLoading = false,
    this.loadMore,
    this.onSearch,
  });

  final List<ProductModel> products;
  final double bottomPaddingBetweenSeeAllAndGrid;
  final Color? colorSeeAllButton;
  final bool isNoMore;
  final bool isLoading;
  final Future<void> Function()? loadMore;
  final Future<void> Function(String)? onSearch;

  @override
  State<BuildProductsGrid> createState() => _BuildProductsGridState();
}

class _BuildProductsGridState extends State<BuildProductsGrid> {
  bool isSeeAllPressed = false;
  final searchController = TextEditingController();
  var focus = FocusNode();

  var scrollController = ScrollController();
  var _isLoading = false;

  Timer? _debounceTimer;

  @override
  void initState() {
    scrollController = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty && isSeeAllPressed == false) {
      return Center(
        child: Text(
          'Empty'.tr,
          style: AppTextStyle.bodyText.copyWith(color: AppColors.middleGrey),
        ),
      );
    }
    if (widget.products.length <= 9 && widget.onSearch == null) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.97,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          return ProductWidget(
            product: widget.products[index],
          );
        },
      );
    }

    return Column(
      children: [
        Builder(builder: (context) {
          if (isSeeAllPressed == false) {
            return Container(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                padding: EdgeInsets.only(
                  bottom: widget.bottomPaddingBetweenSeeAllAndGrid,
                  right: 15,
                  top: 15,
                ),
                minSize: 0,
                child: Text(
                  'See all'.tr,
                  style: TextStyle(
                    color: widget.colorSeeAllButton ?? const Color(0xFF6B6770),
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
        Builder(builder: (context) {
          if (widget.isLoading == true) {
            return Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: Get.height * 0.1),
              child: CupertinoActivityIndicator(
                color: AppColors.orange,
                radius: 13,
              ),
            );
          }
          return Flexible(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 50),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.97,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: widget.products.length,
                  itemBuilder: (context, index) {
                    return ProductWidget(
                      product: widget.products[index],
                    );
                  },
                ),
                widget.isNoMore == false && widget.isLoading != true
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 60),
                        child: CupertinoActivityIndicator(
                          color: AppColors.orange,
                          radius: 12,
                        ),
                      )
                    : const SizedBox(height: 0, width: 0),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _scrollListener() async {
    if (widget.loadMore == null) return;
    if (widget.isNoMore == true) return;
    if (_isLoading) return;

    if (scrollController.position.extentAfter < 100) {
      setState(() => _isLoading = true);
      await widget.loadMore!();
      setState(() => _isLoading = false);
    }
  }

  void _onTypingFinished(String text) {
    if (widget.onSearch == null) return;
    if (_debounceTimer != null) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch!(text);
    });
  }
}
