import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/functions/get_language_value_from_map.dart';
import 'package:foodika/screens/product/product_screen.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/widget/cached_image_widget.dart';
import 'package:get/get.dart';

class ProductWidget extends StatelessWidget {
  const ProductWidget({
    super.key,
    required this.product,
  });
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ProductScreen(product: product),
          preventDuplicates: false,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEE1),
          borderRadius: BorderRadius.circular(10.54),
        ),
        padding: const EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 75,
              width: Get.width,
              child: product.photoUrls.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7.03),
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.photo,
                        color: AppColors.middleGrey,
                        size: 36,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(7.03),
                      child: CachedImageWidget(
                        imageUrl: product.photoUrls.first.value,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 4.75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      product.productDescription == null
                          ? 'Unknown'.tr
                          : getLanguageValue(product.productDescriptionToMap()),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF252525),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 5),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/star.svg'),
                        const SizedBox(width: 2.5),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12.3,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B6770),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
