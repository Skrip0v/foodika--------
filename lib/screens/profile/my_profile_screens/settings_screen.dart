import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodika/core/services/auth_service.dart';
import 'package:foodika/core/services/language_service.dart';
import 'package:foodika/functions/show_custom_dialog.dart';
import 'package:foodika/screens/home/home_screen.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/style/app_text_style.dart';
import 'package:foodika/widget/app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:pull_down_button/pull_down_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthService>(builder: (service) {
      if (service.user == null) {
        return const Scaffold();
      }
      var user = service.user!;

      return Scaffold(
        appBar: AppBarWidget.titleAndBack('Settings'.tr),
        body: SafeArea(
          bottom: true,
          top: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notifications'.tr,
                          style: AppTextStyle.buttonText.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          width: 60,
                          child: CupertinoSwitch(
                            value: user.isNotificationsEnable,
                            activeColor: AppColors.orange,
                            onChanged: (value) async {
                              await service.toogleNotifications();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: Get.width,
                    height: 0.25,
                    color: AppColors.main,
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 20, 27, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Language'.tr,
                          style: AppTextStyle.buttonText.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                        PullDownButton(
                          itemBuilder: (context) {
                            var service = Get.find<LanguageService>();
                            return [
                              PullDownMenuItem(
                                title: 'English',
                                onTap: () async {
                                  await service.changeLanguage('en');
                                },
                              ),
                              PullDownMenuItem(
                                title: 'Русский',
                                onTap: () async {
                                  await service.changeLanguage('ru');
                                },
                              ),
                              PullDownMenuItem(
                                title: 'Latviešu',
                                onTap: () async {
                                  await service.changeLanguage('lv');
                                },
                              ),
                              PullDownMenuItem(
                                title: 'Lietuvių kalba',
                                onTap: () async {
                                  await service.changeLanguage('lt');
                                },
                              ),
                              PullDownMenuItem(
                                title: 'Eesti',
                                onTap: () async {
                                  await service.changeLanguage('et');
                                },
                              ),
                            ];
                          },
                          buttonBuilder: (context, showMenu) {
                            return GetBuilder<LanguageService>(
                                builder: (service) {
                              return CupertinoButton(
                                padding: EdgeInsets.zero,
                                minSize: 0,
                                onPressed: showMenu,
                                child: Text(
                                  service.getCurrentLocaleString(),
                                  style: AppTextStyle.buttonText.copyWith(
                                    color: AppColors.orange,
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                    child: CupertinoButton(
                      onPressed: () {
                        showOkCancelDialog(
                          context,
                          title: 'Are you sure you want to log out?'.tr,
                          titleStyle: AppTextStyle.header2.copyWith(
                            color: AppColors.darkGrey,
                          ),
                          content: null,
                          leftButtonText: 'Yes'.tr,
                          rightButtonText: 'Cancel'.tr,
                          onLeftButtonPress: () async {
                            Get.back();
                            Get.offAll(() => const HomeScreen());
                            await Get.find<AuthService>().signOut();
                          },
                        );
                      },
                      padding: EdgeInsets.zero,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Logout'.tr,
                            style: AppTextStyle.buttonText.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                          SvgPicture.asset('assets/exit.svg'),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    '${'Signed in as'.tr} ${user.email}',
                    style: AppTextStyle.titleText.copyWith(
                      color: AppColors.middleGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      showOkCancelDialog(
                        context,
                        title:
                            'Are you sure you want to delete your account?'.tr,
                        titleStyle: AppTextStyle.header2.copyWith(
                          color: AppColors.darkGrey,
                        ),
                        content: null,
                        leftButtonText: 'Yes'.tr,
                        rightButtonText: 'Cancel'.tr,
                        onLeftButtonPress: () async {
                          Get.back();
                          await Get.find<AuthService>().deleteAccount();
                          log('delete');
                        },
                      );
                    },
                    padding: EdgeInsets.zero,
                    child: Text(
                      'Delete account'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC7052A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
