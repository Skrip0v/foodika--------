import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:awesome_bottom_bar/widgets/inspired/painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodika/core/services/auth_service.dart';
import 'package:foodika/screens/auth/auth_login_screen.dart';
import 'package:foodika/screens/home/favorites/favorites_screen.dart';
import 'package:foodika/screens/home/my_scans/my_scans_screen.dart';
import 'package:foodika/screens/home/top_picks/top_picks_screen.dart';
import 'package:foodika/screens/scanner/scanner_screen.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/widget/app_bar_widget.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final pageController = PageController(
    keepPage: true,
    initialPage: 0,
  );
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        children: const [
          MyScansScreen(),
          TopPicksScreen(),
          FavoritesScreen(),
        ],
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: 100,
            width: Get.width,
            child: CustomPaint(
              painter: ConvexPainter(
                top: -12.5,
                width: 85,
                height: 63,
                color: Colors.white,
                shadowColor: const Color(0xFF260E54).withOpacity(0.1),
                sigma: 2,
                isHexagon: false,
                drawHexagon: false,
                leftPercent: const AlwaysStoppedAnimation(0.87),
                notchSmoothness: NotchSmoothness.defaultEdge,
                convexBridge: true,
                leftCornerRadius: 0,
                rightCornerRadius: 0,
              ),
            ),
          ),
          Positioned(
            top: -13,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Get.to(() => const ScannerScreen());
              },
              child: Container(
                padding: const EdgeInsets.all(17.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF260E54).withOpacity(0.24),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  'assets/scanner.svg',
                  height: 24,
                  width: 24,
                ),
              ),
            ),
          ),
          Positioned(
            child: Container(
              color: Colors.white,
              height: 100,
              margin: const EdgeInsets.only(right: 100, left: 20),
              padding: const EdgeInsets.only(bottom: 12.5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBottomItem(
                    'assets/my_scans.svg',
                    'My scans'.tr,
                    0,
                  ),
                  _buildBottomItem(
                    'assets/top_picks.svg',
                    'Top_Picks_Menu'.tr,
                    1,
                  ),
                  _buildBottomItem(
                    'assets/favorites.svg',
                    'Favorites'.tr,
                    2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomItem(
    String iconPath,
    String title,
    int index,
  ) {
    var isCurrent = currentIndex == index;
    return Flexible(
      child: GestureDetector(
        onTap: () {
          setState(() {
            currentIndex = index;
          });
          pageController.jumpToPage(currentIndex);
        },
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: 100.milliseconds,
                height: isCurrent ? 8 : 0,
                width: isCurrent ? 8 : 0,
                margin: EdgeInsets.only(bottom: isCurrent ? 5 : 0),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              AnimatedContainer(
                duration: 100.milliseconds,
                height: isCurrent ? 30 : 22,
                width: isCurrent ? 30 : 22,
                child: SvgPicture.asset(
                  iconPath,
                  color: isCurrent ? AppColors.orange : const Color(0xFFA19CA9),
                ),
              ),
              const SizedBox(height: 5),
              AnimatedDefaultTextStyle(
                duration: 100.milliseconds,
                style: TextStyle(
                  color: isCurrent ? AppColors.orange : const Color(0xFFA19CA9),
                  fontSize: 14,
                  fontWeight: !isCurrent ? FontWeight.w500 : FontWeight.bold,
                ),
                child: Text(
                  title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
