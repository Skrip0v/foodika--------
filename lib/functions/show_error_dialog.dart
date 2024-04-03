import 'package:flutter/cupertino.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/style/app_text_style.dart';
import 'package:get/get.dart';

void showErrorDialog(
  BuildContext context, {
  required String? title,
  required String? content,
  required String okButtonText,
}) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: title == null
          ? null
          : Text(
              title,
              style: AppTextStyle.header2.copyWith(
                color: AppColors.text,
              ),
            ),
      insetAnimationDuration: 500.milliseconds,
      insetAnimationCurve: Curves.ease,
      content: content == null
          ? null
          : Container(
            margin: const EdgeInsets.only(top: 7.5),
            child: Text(
                content,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Get.back();
          },
          child: Text(
            okButtonText,
            style: TextStyle(
              color: AppColors.orange,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
