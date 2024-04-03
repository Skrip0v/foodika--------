import 'package:flutter/cupertino.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/style/app_text_style.dart';
import 'package:get/get.dart';

void showOkCancelDialog(
  BuildContext context, {
  required String? title,
  TextStyle? titleStyle,
  TextStyle? leftButtonStyle,
  required String? content,
  required String leftButtonText,
  required String rightButtonText,
  required void Function() onLeftButtonPress,
}) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: title == null
          ? null
          : Text(
              title,
              style: titleStyle ??
                  AppTextStyle.header2.copyWith(
                    color: AppColors.text,
                  ),
            ),
      insetAnimationDuration: 500.milliseconds,
      insetAnimationCurve: Curves.ease,
      content: content == null
          ? null
          : Text(
              content,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: onLeftButtonPress,
          child: Text(
            leftButtonText,
            style: 
            leftButtonStyle ?? 
            TextStyle(
              color: AppColors.middleGrey,
              fontSize: 17,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Get.back();
          },
          child: Text(
            rightButtonText,
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
