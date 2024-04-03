import 'package:flutter/material.dart';
import 'package:foodika/core/repos/categories_rep.dart';
import 'package:foodika/core/services/auth_service.dart';
import 'package:foodika/core/services/categories_service.dart';
import 'package:foodika/screens/auth/auth_login_screen.dart';
import 'package:foodika/screens/scanner/scanner_screen.dart';
import 'package:foodika/widget/categories_widget.dart';
import 'package:foodika/widget/colored_button_widget.dart';
import 'package:get/get.dart';

class MyScansEmptyScreen extends StatefulWidget {
  const MyScansEmptyScreen({super.key});

  @override
  State<MyScansEmptyScreen> createState() => _MyScansEmptyScreenState();
}

class _MyScansEmptyScreenState extends State<MyScansEmptyScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ListView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20),
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 90),
              child:  Text(
                'You scan list is empty'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
             Text(
              'All your scanned products will be kept here'.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF65646C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80),
            ColoredButtonWidget(
              onPressed: () async {
                Get.to(() => const ScannerScreen());
              },
              text: 'Scan your first product'.tr,
            ),
          ],
        ),
        const CategoriesWidget()
      ],
    );
  }
}
