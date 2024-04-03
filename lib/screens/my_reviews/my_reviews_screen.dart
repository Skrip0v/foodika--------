import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodika/core/models/review_model.dart';
import 'package:foodika/core/services/auth_service.dart';
import 'package:foodika/screens/my_reviews/widgets/my_review_widget.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/style/app_text_style.dart';
import 'package:foodika/widget/app_bar_widget.dart';
import 'package:get/get.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  bool isLoaded = false;
  List<ReviewModel> reviews = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    isLoaded = false;
    setState(() {});

    reviews = await Get.find<AuthService>().getMyReviews();
    isLoaded = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.titleAndBack('My reviews'.tr),
      body: Builder(builder: (context) {
        if (isLoaded == false) {
          return Center(
            child: CupertinoActivityIndicator(
              color: AppColors.orange,
              radius: 13,
            ),
          );
        }
        if (reviews.isEmpty) {
          return Center(
            child: Text(
              'Empty'.tr,
              style: AppTextStyle.bodyText.copyWith(
                color: AppColors.middleGrey,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: reviews.length,
          padding: EdgeInsets.only(
            bottom: Get.mediaQuery.viewPadding.bottom + 30,
          ),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return MyReviewWidget(
              review: reviews[index],
              onRateEdit: () async {
                await _load();
              },
              onDelete: () {
                reviews.removeAt(index);
                setState(() {});
              },
            );
          },
        );
      }),
    );
  }
}
