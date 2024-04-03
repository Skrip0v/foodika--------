import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodika/core/services/auth_service.dart';
import 'package:foodika/screens/auth/email/auth_login_email_screen.dart';
import 'package:foodika/screens/auth/widgets/auth_field_widget.dart';
import 'package:foodika/screens/home/home_screen.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/style/app_text_style.dart';
import 'package:foodika/widget/app_bar_widget.dart';
import 'package:get/get.dart';

class AuthRegistrationEmailScreen extends StatefulWidget {
  const AuthRegistrationEmailScreen({super.key});

  @override
  State<AuthRegistrationEmailScreen> createState() =>
      _AuthRegistrationEmailScreenState();
}

class _AuthRegistrationEmailScreenState
    extends State<AuthRegistrationEmailScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var isHidePassword = true;
  var isAgree = true;

  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.titleAndBack('Account details'.tr),
      body: SafeArea(
        bottom: true,
        top: false,
        right: false,
        left: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //Form
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        'Fill your information bellow or register with your social account'
                            .tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF65646C),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9.5),
                    Container(
                      margin: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 17.5,
                      ),
                      child: AuthFieldWidget(
                        title: 'Name'.tr,
                        controller: nameController,
                        onChanged: (p0) {
                          setState(() {});
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 23.5,
                      ),
                      child: AuthFieldWidget(
                        title: 'Email'.tr,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (p0) {
                          setState(() {});
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 23.5,
                      ),
                      child: AuthFieldWidget(
                        title: 'Password'.tr,
                        controller: passwordController,
                        isHidePassword: isHidePassword,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (p0) {
                          setState(() {});
                        },
                        suffix: CupertinoButton(
                          child: isHidePassword
                              ? const Icon(
                                  Icons.visibility_outlined,
                                  color: Color(0xFF454558),
                                )
                              : const Icon(
                                  Icons.visibility_off_outlined,
                                  color: Color(0xFF454558),
                                ),
                          onPressed: () {
                            setState(() {
                              isHidePassword = !isHidePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 47.5),
                    _buildAgree(),
                  ],
                ),
              ),
            ),
            CupertinoButton(
              onPressed: () {
                Get.off(() => const AuthLoginEmailScreen());
              },
              child: Text(
                'Login'.tr,
                style: AppTextStyle.buttonText.copyWith(
                  color: AppColors.orange,
                ),
              ),
            ),
            //Button
            Container(
              width: Get.width,
              margin: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: Get.mediaQuery.viewPadding.bottom == 0 ? 20 : 0,
              ),
              child: Opacity(
                opacity: _isAllOk() ? 1 : 0.5,
                child: IgnorePointer(
                  ignoring: !_isAllOk(),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (isLoading) return;
                      setState(() => isLoading = true);

                      var service = Get.find<AuthService>();
                      var res = await service.registrationWithEmail(
                        name: nameController.text,
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      log('done');

                      setState(() => isLoading = false);
                      if (res == true) {
                        Get.offAll(() => const HomeScreen());
                      } else {}
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
                      child: isLoading
                          ? const CupertinoActivityIndicator(
                              color: Colors.white,
                              radius: 13,
                            )
                          :  Text(
                              'Continue'.tr,
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgree() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 24.0,
          width: 24.0,
          child: Checkbox(
            value: isAgree,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
            side: MaterialStateBorderSide.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return BorderSide(
                  width: 1.5,
                  color: AppColors.orange,
                );
              } else {
                return const BorderSide(
                  width: 1.5,
                  color: Colors.black,
                );
              }
            }),
            activeColor: AppColors.orange,
            onChanged: (value) {
              setState(() => isAgree = value ?? !isAgree);
            },
          ),
        ),
        const SizedBox(width: 15),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            children: [
               TextSpan(
                text: '${'Agree with'.tr} ',
                style: const TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: 'Terms & Conditions'.tr,
                style: TextStyle(
                  color: AppColors.orange,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isAllOk() {
    if (nameController.text.isEmpty) return false;
    if (emailController.text.isEmail == false) return false;
    if (passwordController.text.length < 4) return false;

    return true;
  }
}
