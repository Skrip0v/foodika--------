import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodika/core/models/review_model.dart';
import 'package:foodika/core/services/products_service.dart';
import 'package:foodika/core/services/users_service.dart';
import 'package:foodika/functions/get_language_value_from_map.dart';
import 'package:foodika/functions/show_custom_dialog.dart';
import 'package:foodika/functions/show_error_dialog.dart';
import 'package:foodika/functions/show_loading_dialog.dart';
import 'package:foodika/screens/my_reviews/widgets/edit_rate_dialog.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/style/app_text_style.dart';
import 'package:foodika/widget/cached_image_widget.dart';
import 'package:get/get.dart';

class MyReviewWidget extends StatelessWidget {
  const MyReviewWidget({
    super.key,
    required this.review,
    required this.onDelete,
    required this.onRateEdit,
  });
  final ReviewModel review;
  final void Function() onDelete;
  final Future<void> Function() onRateEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (review.product?.photoUrls.isEmpty ?? true)
                        ? Container(color: AppColors.orange)
                        : CachedImageWidget(
                            imageUrl: review.product!.photoUrls.first.value,
                            height: 70,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 20),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (review.product?.productDescription == null)
                              ? 'Error'.tr
                              : getLanguageValue(
                                  review.product!.productDescriptionToMap(),
                                ),
                          style: AppTextStyle.header2.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Builder(builder: (context) {
          var service = Get.find<UsersService>();
          var user = service.getUser(review.authorId);

          return Container(
            margin: const EdgeInsets.fromLTRB(20, 15, 20, 5),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      width: 2,
                      color: AppColors.orange,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: user?.photoUrl == null
                        ? SizedBox(
                            height: 36,
                            width: 36,
                            child: Icon(
                              Icons.person,
                              color: AppColors.orange,
                            ),
                          )
                        : CachedImageWidget(
                            imageUrl: user!.photoUrl!,
                            fit: BoxFit.cover,
                            height: 36,
                            width: 36,
                          ),
                  ),
                ),
                const SizedBox(width: 15),
                Row(
                  children: [
                    SvgPicture.asset('assets/star.svg'),
                    const SizedBox(width: 10),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: AppTextStyle.header2.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: TextField(
            readOnly: true,
            controller: TextEditingController(
              text: review.text,
            ),
            style: AppTextStyle.bodyText.copyWith(
              color: AppColors.darkGrey,
            ),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.darkGrey,
                  style: BorderStyle.solid,
                  width: 0.25,
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: () {
                  showOkCancelDialog(
                    context,
                    title: 'Are you sure you want to delete the review?'.tr,
                    content: null,
                    leftButtonText: 'Delete'.tr,
                    rightButtonText: 'Cancel'.tr,
                    onLeftButtonPress: () async {
                      Get.back();
                      showLoadingDialog();
                      try {
                        await Get.find<ProductsService>().deleteReview(
                          productId: review.productBarcode,
                          reviewId: review.id,
                          rating: review.rating,
                          categoryId: review.product?.categoryId,
                        );
                        onDelete();
                        Get.back();
                      } catch (e) {
                        log(e.toString());
                        Get.back();
                        showErrorDialog(
                          Get.context!,
                          title: 'Error'.tr,
                          content: null,
                          okButtonText: 'Ok',
                        );
                      }
                    },
                  );
                },
                child: SvgPicture.asset(
                  'assets/delete.svg',
                ),
              ),
              CupertinoButton(
                minSize: 0,
                padding: EdgeInsets.zero,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        contentPadding: EdgeInsets.zero,
                        content: EditRateDialog(
                            review: review, onRateEdit: onRateEdit),
                      );
                    },
                  );
                },
                child: SvgPicture.asset(
                  'assets/edit.svg',
                ),
              ),
            ],
          ),
        ),
        Container(
          width: Get.width,
          margin: const EdgeInsets.only(top: 25, bottom: 20),
          height: 0.5,
          color: AppColors.main,
        )
      ],
    );
  }
}
