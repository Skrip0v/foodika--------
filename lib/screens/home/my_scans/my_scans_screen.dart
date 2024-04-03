import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:foodika/core/services/my_scans_service.dart';
import 'package:foodika/screens/home/my_scans/my_scans_empty_screen.dart';
import 'package:foodika/screens/home/my_scans/my_scans_full_screen.dart';
import 'package:foodika/screens/home/my_scans/my_scans_short_screen.dart';
import 'package:foodika/widget/app_bar_widget.dart';

class MyScansScreen extends StatefulWidget {
  const MyScansScreen({super.key});

  @override
  State<MyScansScreen> createState() => _MyScansScreenState();
}

class _MyScansScreenState extends State<MyScansScreen>
    with AutomaticKeepAliveClientMixin<MyScansScreen> {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBarWidget.home('My scans'.tr),
      body: GetBuilder<MyScansService>(builder: (service) {
        var myScans = service.myScans;
        if (myScans.isEmpty) {
          return const MyScansEmptyScreen();
        }
        if (myScans.length <= 9) {
          return MyScansShortScreen(products: myScans);
        }

        return const MyScansFullScreen();
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
