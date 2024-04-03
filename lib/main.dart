import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

import 'package:foodika/core/language/languages.dart';
import 'package:foodika/core/services/auth_service.dart';
import 'package:foodika/core/services/categories_service.dart';
import 'package:foodika/core/services/fav_service.dart';
import 'package:foodika/core/services/language_service.dart';
import 'package:foodika/core/services/my_scans_service.dart';
import 'package:foodika/core/services/products_service.dart';
import 'package:foodika/core/services/top_picks_service.dart';
import 'package:foodika/core/services/users_service.dart';
import 'package:foodika/screens/home/home_screen.dart';
import 'package:foodika/style/app_colors.dart';

Future<void> main() async {
  var widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp();

  Get.put(MyScansService());
  Get.put(ProductsService());
  Get.put(FavService());
  Get.put(UsersService());
  Get.put(LanguageService()).init();
  await Get.put(TopPicksService()).init();
  await Get.put(AuthService()).init();
  await Get.put(CategoriesService()).init();

  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }

  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageService>(builder: (service) {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        locale: service.locale,
        translations: Languages(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.background,
            elevation: 0,
            titleTextStyle: const TextStyle(
              color: Color(0xFF252525),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          useMaterial3: false,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const HomeScreen(),
      );
    });
  }
}
