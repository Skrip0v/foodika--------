import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodika/screens/profile/edit_about_dialog.dart';
import 'package:foodika/screens/profile/edit_name_dialog.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:foodika/core/services/auth_service.dart';
import 'package:foodika/functions/show_loading_dialog.dart';
import 'package:foodika/screens/my_reviews/my_reviews_screen.dart';
import 'package:foodika/screens/profile/my_profile_screens/profile_fav_screen.dart';
import 'package:foodika/screens/profile/my_profile_screens/settings_screen.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/style/app_text_style.dart';
import 'package:foodika/widget/cached_image_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthService>(builder: (service) {
      var user = service.user;
      if (user == null) {
        return const Scaffold();
      }
      return Scaffold(
        body: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      width: Get.width,
                      height: Get.mediaQuery.viewPadding.top + 109,
                      color: AppColors.orange,
                    ),
                    const SizedBox(height: 60),
                    Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              user.name,
                              style: AppTextStyle.header.copyWith(
                                color: AppColors.text,
                              ),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          const SizedBox(width: 10),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            minSize: 0,
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    contentPadding: EdgeInsets.zero,
                                    content: EditNameDialog(
                                      initName: user.name,
                                    ),
                                  );
                                },
                              );
                            },
                            child: SvgPicture.asset('assets/edit.svg'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              user.about ?? 'Empty'.tr,
                              style: AppTextStyle.bodyText.copyWith(
                                color: AppColors.text,
                                decoration: user.about == null
                                    ? TextDecoration.underline
                                    : null,
                              ),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          const SizedBox(width: 10),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            minSize: 0,
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    contentPadding: EdgeInsets.zero,
                                    content: EditAboutDialog(
                                      initAbout: user.about ?? '',
                                    ),
                                  );
                                },
                              );
                              // await _showEditDialog(
                              //   initText: user.about ?? '',
                              //   title: 'Edit about'.tr,
                              //   onEditPress: (str) async {
                              //     Get.back();
                              //     var service = Get.find<AuthService>();
                              //     service.updateAboudUser(str).then((value) {
                              //       Get.back();
                              //     });

                              //     await showLoadingDialog();
                              //   },
                              // );
                            },
                            child: SvgPicture.asset('assets/edit.svg'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: Get.mediaQuery.viewPadding.top + 55,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        width: 5,
                        color: AppColors.orange,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: user.photoUrl == null
                          ? GestureDetector(
                              onTap: () async {
                                final picker = ImagePicker();
                                var image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (image == null) return;
                                var service = Get.find<AuthService>();
                                service
                                    .saveProfilePhoto(image.path, null)
                                    .then((value) {
                                  Get.back();
                                });

                                await showLoadingDialog();
                              },
                              child: Container(
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/edit.svg',
                                    height: 28,
                                    width: 28,
                                  ),
                                ),
                              ),
                            )
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  color: Colors.white,
                                  child: CachedImageWidget(
                                    imageUrl: user.photoUrl!,
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ),
                                Positioned(
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    minSize: 0,
                                    onPressed: () async {
                                      final picker = ImagePicker();
                                      var image = await picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (image == null) return;
                                      var service = Get.find<AuthService>();
                                      service
                                          .saveProfilePhoto(
                                        image.path,
                                        user.photoUrl,
                                      )
                                          .then((value) {
                                        Get.back();
                                      });

                                      await showLoadingDialog();
                                    },
                                    child: SvgPicture.asset(
                                      'assets/edit.svg',
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
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
              ],
            ),
            Flexible(
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: Get.mediaQuery.viewPadding.bottom + 20,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 20),
                  _buildTile(
                    iconPath: 'assets/settings/fav.svg',
                    title: 'Favorites'.tr,
                    rightspaceIcon: 16,
                    onPressed: () {
                      Get.to(() => const ProfileFavScreen());
                    },
                  ),
                  _buildTile(
                    iconPath: 'assets/settings/star.svg',
                    title: 'My reviews'.tr,
                    rightspaceIcon: 13,
                    onPressed: () {
                      Get.to(() => const MyReviewsScreen());
                    },
                  ),
                  _buildTile(
                    iconPath: 'assets/settings/settings.svg',
                    title: 'Settings'.tr,
                    rightspaceIcon: 17,
                    leftSpaceIocn: 2.5,
                    onPressed: () {
                      Get.to(() => const SettingsScreen());
                    },
                  ),
                  _buildTile(
                    iconPath: 'assets/settings/privacy.svg',
                    title: 'Privacy'.tr,
                    leftSpaceIocn: 5,
                    rightspaceIcon: 16,
                  ),
                  _buildTile(
                    iconPath: 'assets/settings/support.svg',
                    title: 'Support'.tr,
                    leftSpaceIocn: 5,
                    rightspaceIcon: 16.5,
                  ),
                  _buildTile(
                    iconPath: 'assets/settings/privacy.svg',
                    title: 'Term & conditions'.tr,
                    leftSpaceIocn: 5,
                    rightspaceIcon: 16,
                  ),
                  // _buildTile(
                  //   iconPath: 'assets/settings/privacy.svg',
                  //   title: 'IMPORT DATA',
                  //   leftSpaceIocn: 5,
                  //   rightspaceIcon: 16,
                  //   onPressed: () async {
                  //     Get.to(() => const CategoriesTestWidget());
                  //   },
                  // ),
                  CupertinoButton(
                    child: Column(
                      children: [
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 50),
                                Text(
                                  'Share the app'.tr,
                                  style: AppTextStyle.buttonText.copyWith(
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: SvgPicture.asset(
                                'assets/settings/share.svg',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTile({
    required String iconPath,
    required String title,
    double? rightspaceIcon,
    double? leftSpaceIocn,
    void Function()? onPressed,
  }) {
    return Column(
      children: [
        const SizedBox(height: 6),
        CupertinoButton(
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 10),
                  SizedBox(width: leftSpaceIocn ?? 0),
                  SvgPicture.asset(
                    iconPath,
                    height: 22,
                    width: 22,
                  ),
                  SizedBox(width: rightspaceIcon ?? 15),
                  Text(
                    title,
                    style: AppTextStyle.buttonText.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(right: 15),
                child: SvgPicture.asset('assets/settings/right_arrow.svg'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 0.3,
          width: Get.width,
          color: AppColors.orange,
        )
      ],
    );
  }
}
