// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodika/core/services/auth_service.dart';
import 'package:foodika/functions/show_error_dialog.dart';
import 'package:foodika/functions/show_loading_dialog.dart';
import 'package:foodika/screens/auth/email/auth_login_email_screen.dart';
import 'package:foodika/screens/auth/email/auth_registration_email_screen.dart';
import 'package:foodika/screens/auth/widgets/auth_button_border_widget.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';

class AuthLoginScreen extends StatelessWidget {
  const AuthLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: Get.mediaQuery.viewPadding.top + 37.5,
              ),
              Image.asset(
                'assets/auth.png',
                fit: BoxFit.cover,
                height: 387.5,
              ),
              const SizedBox(height: 32),
              //Email
              Container(
                width: Get.width,
                margin: const EdgeInsets.only(right: 20, left: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => const AuthRegistrationEmailScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    child:  Text(
                      'Continue with email'.tr,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              //Google
              AuthButtonBorderWidget(
                imagePath: 'assets/google.svg',
                text: 'Continue with Google'.tr,
                onPressed: () async {
                  showLoadingDialog();
                  try {
                    await Get.find<AuthService>().loginWithGoogle();
                    Get.back();
                  } catch (e) {
                    Get.back();
                    showErrorDialog(
                      context,
                      title: 'Error'.tr,
                      content: 'couldn\'t log in to your account',
                      okButtonText: 'Ok',
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              Platform.isAndroid
                  ? Container()
                  : Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: AuthButtonBorderWidget(
                        imagePath: 'assets/apple.svg',
                        text: 'Continue with Apple ID'.tr,
                        onPressed: () async {
                          showLoadingDialog();
                          await Get.find<AuthService>().loginWithApple();
                          Get.back();
                        },
                      ),
                    ),
              //Facebook
              const AuthButtonBorderWidget(
                imagePath: 'assets/facebook.svg',
                text: 'Continue with Facebook',
              ),
            ],
          ),
          Positioned(
            top: Get.mediaQuery.viewPadding.top,
            left: 10,
            child: CupertinoButton(
              child: SvgPicture.asset('assets/back.svg'),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
