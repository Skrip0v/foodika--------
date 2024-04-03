// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodika/core/services/products_service.dart';
import 'package:foodika/functions/show_loading_dialog.dart';
import 'package:foodika/widget/app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final controller = MobileScannerController();
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            overlay: Container(
              height: 150,
              width: Get.width * 0.7,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onDetect: (barcode) async {
              if (isScanned) return;
              isScanned = true;
              Get.back();
              showLoadingDialog();

              // try {
              await Get.find<ProductsService>().scan(
                barcode.barcodes.first.rawValue.toString(),
              );
              // } catch (e) {
              //   Get.back();
              //   log(e.toString());
              // }
            },
          ),
          Positioned(
            top: Get.mediaQuery.viewPadding.top + 10,
            left: 20,
            child: CupertinoButton(
              child: ValueListenableBuilder(
                valueListenable: controller.torchState,
                builder: (context, state, child) {
                  switch (state) {
                    case TorchState.off:
                      return const Icon(
                        Icons.flash_off,
                        color: Colors.white,
                        size: 28,
                      );
                    case TorchState.on:
                      return const Icon(
                        Icons.flash_on,
                        color: Colors.white,
                        size: 28,
                      );
                  }
                },
              ),
              onPressed: () => controller.toggleTorch(),
            ),
          ),
          Positioned(
            top: Get.mediaQuery.viewPadding.top + 10,
            right: 20,
            child: CupertinoButton(
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () => Get.back(),
            ),
          )
        ],
      ),
    );
  }
}
