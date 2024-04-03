import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../style/app_colors.dart';

class ColoredButtonWidget extends StatelessWidget {
  const ColoredButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
    this.margin,
  });
  final void Function() onPressed;
  final String text;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      margin: margin ?? const EdgeInsets.only(right: 20, left: 20),
      child: ElevatedButton(
        onPressed: onPressed,
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
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
