import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/models/review_model.dart';
import 'package:foodika/core/services/auth_service.dart';
import 'package:foodika/core/services/products_service.dart';
import 'package:foodika/core/services/users_service.dart';
import 'package:foodika/functions/show_custom_dialog.dart';
import 'package:foodika/functions/show_error_dialog.dart';
import 'package:foodika/functions/show_loading_dialog.dart';
import 'package:foodika/screens/auth/auth_login_screen.dart';
import 'package:foodika/screens/my_reviews/widgets/edit_rate_dialog.dart';
import 'package:foodika/screens/profile/other_user_profile_screen.dart';
import 'package:foodika/screens/profile/profile_screen.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/style/app_text_style.dart';
import 'package:foodika/widget/cached_image_widget.dart';

class ReviewWidget extends StatelessWidget {
  const ReviewWidget({
    super.key,
    required this.product,
    required this.review,
    required this.onToggleLike,
    required this.onReviewEditOrDelete,
  });

  final ProductModel product;
  final ReviewModel review;
  final void Function(List<String>, int) onToggleLike;
  final Future<void> Function() onReviewEditOrDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 17.5, 20, 17.5),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              bottom: BorderSide(
                color: AppColors.main,
                width: 0.35,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 12.5),
              GetBuilder<UsersService>(builder: (service) {
                var user = service.getUser(review.authorId);
                return GestureDetector(
                  onTap: () {
                    if (user == null) return;
                    var currentUserId = Get.find<AuthService>().user?.id;
                    if (currentUserId == user.id) {
                      Get.to(() => const ProfileScreen());
                    } else {
                      Get.to(() => OtherUserProfileScreen(user: user));
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                            Flexible(
                              child: Text(
                                user?.name ?? 'Error'.tr,
                                style: AppTextStyle.titleText.copyWith(
                                  color: AppColors.text,
                                ),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        getLastAddTime(),
                        style: AppTextStyle.titleText.copyWith(
                          color: AppColors.middleGrey,
                        ),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 15),
              Text(
                review.text,
                style: AppTextStyle.bodyText.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 5),
              GetBuilder<AuthService>(builder: (service) {
                var id = service.user?.id ?? '-1';
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(builder: (context) {
                      var user = Get.find<AuthService>().user;

                      if (user != null) {
                        if (review.authorId != user.id) {
                          return const SizedBox(height: 0, width: 0);
                        }
                      } else {
                        return const SizedBox(height: 0, width: 0);
                      }

                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 0,
                              onPressed: () {
                                showOkCancelDialog(
                                  context,
                                  title:
                                      'Are you sure you want to delete the review?'
                                          .tr,
                                  content: null,
                                  leftButtonText: 'Delete'.tr,
                                  rightButtonText: 'Cancel'.tr,
                                  onLeftButtonPress: () async {
                                    Get.back();
                                    showLoadingDialog();
                                    try {
                                      await Get.find<ProductsService>()
                                          .deleteReview(
                                        productId: review.productBarcode,
                                        reviewId: review.id,
                                        rating: review.rating,
                                        categoryId: product.categoryId,
                                      );

                                      await onReviewEditOrDelete();
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
                            Container(
                              margin: const EdgeInsets.only(left: 12.5),
                              child: CupertinoButton(
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
                                          review: review,
                                          onRateEdit: () async {
                                            await onReviewEditOrDelete();
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: SvgPicture.asset(
                                  'assets/edit.svg',
                                  color: AppColors.darkGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () async {
                        var userId = Get.find<AuthService>().user?.id;
                        if (userId == null) {
                          Get.to(() => const AuthLoginScreen());
                          return;
                        }

                        var whoLikeIds = [...review.whoLikeIds];
                        if (whoLikeIds.contains(userId)) {
                          whoLikeIds.remove(userId);
                        } else {
                          whoLikeIds.add(userId);
                        }

                        onToggleLike([...whoLikeIds], [...whoLikeIds].length);

                        await Get.find<ProductsService>().updateReview(
                          review.copyWith(
                            whoLikeIds: [...whoLikeIds],
                            countLikes: [...whoLikeIds].length,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SvgPicture.asset(
                            'assets/like.svg',
                            color: review.whoLikeIds.contains(id)
                                ? AppColors.orange
                                : null,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            review.countLikes.toString(),
                            style: AppTextStyle.buttonText.copyWith(
                              color: review.whoLikeIds.contains(id)
                                  ? AppColors.orange
                                  : AppColors.middleGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        Positioned(
          right: 5,
          top: 5,
          child: Builder(builder: (context) {
            var user = Get.find<AuthService>().user;

            if (user != null) {
              if (review.authorId != user.id) {
                return const SizedBox(height: 0, width: 0);
              }
            } else {
              return const SizedBox(height: 0, width: 0);
            }

            return Container(
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(100),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: Text(
                'Your review'.tr,
                style: AppTextStyle.titleText.copyWith(
                  color: AppColors.white,
                ),
              ),
            );
          }),
        )
      ],
    );
  }

  String getLastAddTime() {
    var date = DateTime.fromMillisecondsSinceEpoch(
      review.createDate,
      isUtc: true,
    ).toLocal();

    var now = DateTime.now();
    if (now.difference(date).inMinutes < 59) {
      return '${now.difference(date).inMinutes} ${'minutes ago'.tr}';
    }
    if (now.difference(date).inHours < 24) {
      return '${now.difference(date).inHours} ${'hours ago'.tr}';
    }
    if (now.difference(date).inDays < 30) {
      return '${now.difference(date).inDays} ${'days ago'}';
    }

    var months = now.difference(date).inDays ~/ 60;
    return '$months ${'months ago'}';
  }
}
