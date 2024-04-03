import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodika/core/models/category_model.dart';
import 'package:foodika/core/services/categories_service.dart';
import 'package:foodika/functions/get_language_value_from_map.dart';
import 'package:foodika/screens/products/products_from_category_screen.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/widget/app_bar_widget.dart';
import 'package:foodika/widget/cached_image_widget.dart';
import 'package:get/get.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
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
      appBar: AppBarWidget.titleAndBack('Categories'.tr),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(15, 7.5, 15, 18),
            child: TextField(
              focusNode: focus,
              controller: searchController,
              cursorColor: const Color(0xFF6B6770),
              onTapOutside: (event) {
                focus.unfocus();
              },
              onChanged: search,
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
        Get.to(() => ProductsFromCategoryScreen(category: category));
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
