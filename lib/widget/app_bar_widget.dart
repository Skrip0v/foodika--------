import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodika/core/services/auth_service.dart';
import 'package:foodika/screens/auth/auth_login_screen.dart';
import 'package:foodika/screens/profile/profile_screen.dart';
import 'package:get/get.dart';

abstract class AppBarWidget {
  static AppBar titleAndBack(String title) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading: CupertinoButton(
        onPressed: () {
          Get.back();
        },
        child: SvgPicture.asset('assets/back.svg'),
      ),
      automaticallyImplyLeading: false,
    );
  }

  static AppBar home(String title) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leadingWidth: 86,
      leading: Center(
        child: SvgPicture.asset(
          'assets/logo.svg',
          height: 48,
          width: 48,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () {
              var user = Get.find<AuthService>().user;
              if (user == null) {
                Get.to(() => const AuthLoginScreen());
              } else {
                Get.to(() => const ProfileScreen());
              }
            },
            child: SvgPicture.asset(
              'assets/profile.svg',
              height: 46,
              width: 46,
            ),
          ),
        ),
      ],
    );
  }
}
