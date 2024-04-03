import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodika/widget/cached_image_widget.dart';
import 'package:get/get.dart';

import 'package:foodika/core/models/category_model.dart';
import 'package:foodika/core/services/categories_service.dart';
import 'package:foodika/functions/get_language_value_from_map.dart';
import 'package:foodika/screens/categories/categories_screen.dart';
import 'package:foodika/screens/products/products_from_category_screen.dart';

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.only(left: 20, bottom: 10),
            onPressed: () {
              Get.to(() => const CategoriesScreen());
            },
            child: Text(
              'Categories'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF252525),
              ),
            ),
          ),
          GetBuilder<CategoriesService>(builder: (service) {
            var categories = service.categories;
            return Container(
              height: 129,
              margin: const EdgeInsets.only(bottom: 22.5),
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 20),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var category = categories[index];
                  return _buildCategory(category);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategory(CategoryModel category) {
    return GestureDetector(
      onTap: () {
        log(category.id.toString());
        Get.to(() => ProductsFromCategoryScreen(category: category));
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Container(
              height: 100,
              width: 100,
              padding: const EdgeInsets.all(5),
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
                        margin: const EdgeInsets.all(10),
                        child: CachedImageWidget(
                          imageUrl: category.photoUrl,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
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
      ),
    );
  }
}
