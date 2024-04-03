import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:foodika/core/services/auth_service.dart';
import 'package:foodika/functions/show_loading_dialog.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/widget/colored_button_widget.dart';

class EditAboutDialog extends StatefulWidget {
  const EditAboutDialog({
    super.key,
    required this.initAbout,
  });

  final String initAbout;

  @override
  State<EditAboutDialog> createState() => _EditAboutDialogState();
}

class _EditAboutDialogState extends State<EditAboutDialog> {
  late TextEditingController controller;
  final focus = FocusNode();

  @override
  void initState() {
    controller = TextEditingController(text: widget.initAbout);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: SizedBox(
              height: Get.height * 0.425,
              width: Get.width * 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.orange, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A1919).withOpacity(0.25),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //dismiss
                    Container(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        color: Colors.transparent,
                        minSize: 0,
                        onPressed: () {
                          Get.back();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF1A1919).withOpacity(0.15),
                                blurRadius: 30,
                                spreadRadius: 0,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset('assets/dismiss.svg'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: Text(
                        'About me'.tr,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEE1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: TextField(
                        controller: controller,
                        focusNode: focus,
                        textCapitalization: TextCapitalization.sentences,
                        onTapOutside: (event) {
                          focus.unfocus();
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                        cursorColor: AppColors.darkGrey,
                        maxLines: 4,
                        maxLength: 50,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(200),
                        ],
                        decoration: InputDecoration(
                          counterStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            color: AppColors.middleGrey,
                          ),
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: controller.text.isEmpty ? 0.5 : 1,
                          child: IgnorePointer(
                            ignoring: controller.text.isEmpty,
                            child: SizedBox(
                              width: Get.width * 0.6,
                              child: ColoredButtonWidget(
                                onPressed: () async {
                                  var service = Get.find<AuthService>();
                                  Get.back();
                                  showLoadingDialog();
                                  await service.updateAboudUser(controller.text);
                                  Get.back();
                                },
                                text: 'Edit'.tr,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
