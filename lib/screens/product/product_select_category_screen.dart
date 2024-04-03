import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodika/core/models/category_model.dart';
import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/services/categories_service.dart';
import 'package:foodika/core/services/products_service.dart';
import 'package:foodika/functions/get_language_value_from_map.dart';
import 'package:foodika/functions/show_custom_dialog.dart';
import 'package:foodika/functions/show_loading_dialog.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/widget/app_bar_widget.dart';
import 'package:foodika/widget/cached_image_widget.dart';
import 'package:get/get.dart';

class ProductSelectCategoryScreen extends StatefulWidget {
  const ProductSelectCategoryScreen({
    super.key,
    required this.barcode,
    required this.onSet,
  });
  final String barcode;
  final void Function(ProductModel) onSet;
  @override
  State<ProductSelectCategoryScreen> createState() =>
      _ProductSelectCategoryScreenState();
}

class _ProductSelectCategoryScreenState
    extends State<ProductSelectCategoryScreen> {
  final searchController = TextEditingController();
  var focus = FocusNode();

  List<CategoryModel> allCategories = [];
  List<CategoryModel> foundedCategories = [];

  @override
  void initState() {
    allCategories = [...Get.find<CategoriesService>().categories];
    foundedCategories = [...allCategories];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.titleAndBack('Choosing a category'.tr),
      body: Column(
        children: [
          Container(
            margin:
                const EdgeInsets.only(left: 15, right: 15, bottom: 20, top: 15),
            child: Text(
              'Select the category that corresponds to this product'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B6770),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 50),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 5,
                mainAxisSpacing: 20,
              ),
              itemCount: foundedCategories.length,
              itemBuilder: (context, index) {
                var category = foundedCategories[index];
                return _buildCategory(category);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(CategoryModel category) {
    return GestureDetector(
      onTap: () {
        showOkCancelDialog(
          context,
          title:
              '${'Select the category'.tr} "${getLanguageValue(category.name)}"?',
          content: null,
          leftButtonText: 'Yes'.tr,
          rightButtonText: 'Cancel'.tr,
          leftButtonStyle: TextStyle(
            color: AppColors.orange,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          onLeftButtonPress: () async {
            Get.back();
            showLoadingDialog();
            var service = Get.find<ProductsService>();
            var product = await service.setCategoryForProduct(
              barcode: widget.barcode,
              categoryId: category.id,
            );
            widget.onSet(product);
            Get.back();
            Get.back();
          },
        );
      },
      child: Column(
        children: [
          Container(
            height: 102,
            width: 102,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: const Color(0xFFA19CA9),
                width: 0,
              ),
            ),
            child: Center(
              child: category.photoUrl.isEmpty
                  ? const SizedBox(height: 0, width: 0)
                  : Container(
                      margin: const EdgeInsets.all(16.5),
                      child: CachedImageWidget(
                        imageUrl: category.photoUrl,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            getLanguageValue(category.name),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B6770),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
          )
        ],
      ),
    );
  }

  void search(String q) {
    foundedCategories = [];

    for (var category in allCategories) {
      List<String> keys = [];
      try {
        for (var desc in category.classDescription) {
          keys.addAll(desc.split(" "));
          for (var i = 0; i < desc.length + 1; i++) {
            keys.add(desc.substring(0, i).toLowerCase());
          }
        }
        category.name.forEach(
          (key, value) {
            keys.addAll(value.split(" "));
            for (var i = 0; i < value.length + 1; i++) {
              keys.add(value.substring(0, i).toLowerCase());
            }
          },
        );
      } catch (e) {
        log(e.toString());
      }

      if (keys.contains(q)) {
        foundedCategories.add(category);
      }
    }

    setState(() {});
  }
}
