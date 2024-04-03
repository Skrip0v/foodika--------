import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodika/widget/cached_image_widget.dart';
import 'package:get/get.dart';

import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/models/user_model.dart';
import 'package:foodika/core/services/auth_service.dart';
import 'package:foodika/core/services/users_service.dart';
import 'package:foodika/functions/show_custom_dialog.dart';
import 'package:foodika/functions/show_loading_dialog.dart';
import 'package:foodika/screens/auth/auth_login_screen.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/style/app_text_style.dart';
import 'package:foodika/widget/build_products_grid.dart';

class OtherUserProfileScreen extends StatefulWidget {
  const OtherUserProfileScreen({
    super.key,
    required this.user,
  });
  final UserModel user;
  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  List<ProductModel> products = [];
  bool isProductsLoaded = false;
  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    products = await Get.find<UsersService>().getFavProductForUser(
      widget.user.favIds,
    );
    isProductsLoaded = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Container(
                width: Get.width,
                height: Get.mediaQuery.viewPadding.top + 109,
                color: AppColors.orange,
              ),
              const SizedBox(height: 82),
              Expanded(
                child: BuildProductsGrid(
                  products: products,
                  bottomPaddingBetweenSeeAllAndGrid: 20,
                  colorSeeAllButton: AppColors.text,
                ),
              ),
            ],
          ),
          Positioned(
            top: Get.mediaQuery.viewPadding.top,
            left: 5,
            child: CupertinoButton(
              onPressed: () {
                Get.back();
              },
              child: SvgPicture.asset('assets/back.svg'),
            ),
          ),
          Positioned(
            top: Get.mediaQuery.viewPadding.top + 51,
            child: Container(
              height: 130,
              width: Get.width * 0.825,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A1919).withOpacity(0.25),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(left: 15, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        width: 5,
                        color: AppColors.orange,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: widget.user.photoUrl == null
                          ? SizedBox(
                              height: 90,
                              width: 90,
                              child: Icon(
                                Icons.person,
                                color: AppColors.orange,
                                size: 42,
                              ),
                            )
                          : CachedImageWidget(
                              imageUrl: widget.user.photoUrl!,
                              height: 90,
                              width: 90,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            widget.user.name,
                            style: AppTextStyle.header.copyWith(
                              color: AppColors.text,
                            ),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Flexible(
                          child: Text(
                            widget.user.about == null
                                ? 'Empty'.tr
                                : widget.user.about!,
                            style: AppTextStyle.bodyText.copyWith(
                              color: AppColors.text,
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        const SizedBox(height: 7),
                        GetBuilder<AuthService>(builder: (service) {
                          var user = service.user;

                          return SizedBox(
                            width: 125,
                            child: ElevatedButton(
                              onPressed: () {
                                var userId = Get.find<AuthService>().user?.id;
                                if (userId == null) {
                                  Get.to(() => const AuthLoginScreen());
                                  return;
                                }

                                showOkCancelDialog(
                                  context,
                                  title: 'Block ${widget.user.name}',
                                  content:
                                      'Don\'t worry, they won\'t be notified that you blocked them',
                                  leftButtonText: 'Block user',
                                  rightButtonText: 'Cancel'.tr,
                                  onLeftButtonPress: () async {
                                    Get.back();
                                    showLoadingDialog();
                                    var service = Get.find<AuthService>();
                                    await service.toggleBlockedUsers(
                                      widget.user.id,
                                    );
                                    Get.back();
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                padding: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 16,
                                ),
                                visualDensity: VisualDensity.compact,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                user == null
                                    ? 'Block user'
                                    : user.blockedUsers.contains(widget.user.id)
                                        ? 'Unblock user'
                                        : 'Block user',
                                style: AppTextStyle.buttonText,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
