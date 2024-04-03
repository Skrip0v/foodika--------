import 'dart:developer';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends GetxController {
  final _key = 'language';
  Locale locale = const Locale('en');

  Future<void> init() async {
    var sp = await SharedPreferences.getInstance();
    var str = sp.getString(_key);
    if (str == null) {
      locale = Get.deviceLocale ?? const Locale('en');
      await changeLanguage(locale.languageCode);
    } else {
      locale = Locale(str);
    }
    update();
  }

  Future<void> changeLanguage(String str) async {
    locale = Locale(str);
    update();
    await Get.updateLocale(locale);
    var sp = await SharedPreferences.getInstance();
    await sp.setString(_key, str);
  }

  String getCurrentLocaleString() {
    var code = locale.languageCode;

    if (code == 'en') {
      return 'ENG';
    } else if (code == 'ru') {
      return 'RUS';
    } else if (code == 'lv') {
      return 'LAT';
    } else if (code == 'lt') {
      return 'LIT';
    } else if (code == 'et') {
      return 'EST';
    }

    return code;
  }
}
