import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodika/screens/auth/email/auth_login_email_screen.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:get/get.dart';

class AuthButtonBorderWidget extends StatelessWidget {
  const AuthButtonBorderWidget({
    super.key,
    required this.imagePath,
    required this.text,
    this.onPressed,
  });
  final String text;
  final String imagePath;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.only(right: 20, left: 20),
      child: ElevatedButton(
        onPressed: onPressed ??
            () {
              Get.to(() => const AuthLoginEmailScreen());
            },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(color: AppColors.main),
          ),
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        child: SizedBox(
          width: Get.width,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                child: SvgPicture.asset(imagePath),
              ),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16.5,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
