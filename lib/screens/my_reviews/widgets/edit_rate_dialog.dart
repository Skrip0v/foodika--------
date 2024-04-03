import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodika/core/models/review_model.dart';
import 'package:foodika/core/services/products_service.dart';
import 'package:foodika/functions/show_loading_dialog.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/style/app_text_style.dart';
import 'package:foodika/widget/colored_button_widget.dart';
import 'package:get/get.dart';

class EditRateDialog extends StatefulWidget {
  const EditRateDialog({
    super.key,
    required this.review,
    required this.onRateEdit,
  });

  final ReviewModel review;
  final Future<void> Function() onRateEdit;

  @override
  State<EditRateDialog> createState() => _EditRateDialogState();
}

class _EditRateDialogState extends State<EditRateDialog> {
  double currentRate = 1;
  late TextEditingController controller;
  final focus = FocusNode();

  @override
  void initState() {
    currentRate = widget.review.rating;
    controller = TextEditingController(text: widget.review.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: SizedBox(
              height: Get.height * 0.57,
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
                    const SizedBox(height: 7.5),
                    Container(
                      margin: const EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        'You can rate the product below and write a review'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStar(1),
                        const SizedBox(width: 15),
                        _buildStar(2),
                        const SizedBox(width: 15),
                        _buildStar(3),
                        const SizedBox(width: 15),
                        _buildStar(4),
                        const SizedBox(width: 15),
                        _buildStar(5),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: Text(
                        'Review'.tr,
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
                        cursorColor: AppColors.darkGrey,
                        maxLines: 5,
                        maxLength: 200,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(200),
                        ],
                        decoration: InputDecoration(
                          hintText:
                              'You can better explain your comments about the product by adding'
                                  .tr,
                          hintStyle: AppTextStyle.titleText.copyWith(
                            color: AppColors.darkGrey,
                          ),
                          counterStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            color: AppColors.middleGrey,
                          ),
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: Get.width * 0.6,
                          child: ColoredButtonWidget(
                            onPressed: () async {
                              if (currentRate == 0) return;

                              var service = Get.find<ProductsService>();
                              Get.back();
                              showLoadingDialog();
                              await service.editReview(
                                productId: widget.review.productBarcode,
                                reviewId: widget.review.id,
                                newText: controller.text,
                                newRating: currentRate,
                                oldRating: widget.review.rating,
                              );
                              widget.onRateEdit().then((value) {
                                Get.back();
                              });
                            },
                            text: 'Edit review'.tr,
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

  Widget _buildStar(double value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentRate = value;
        });
      },
      child: SvgPicture.asset(
        'assets/star.svg',
        color: value <= currentRate
            ? const Color(0xFFFCAF23)
            : const Color(0xFFA19CA9),
        height: 22,
        width: 22,
      ),
    );
  }
}
