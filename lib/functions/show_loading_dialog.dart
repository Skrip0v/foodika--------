import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:get/get.dart';

Future<void> showLoadingDialog() async {
  await Get.dialog(
    Center(
      child: Container(
        height: Get.width * 0.4,
        width: Get.width * 0.4,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: CupertinoActivityIndicator(
          color: AppColors.orange,
          radius: 13,
        ),
      ),
    ),
    barrierDismissible: true,
  );
}
