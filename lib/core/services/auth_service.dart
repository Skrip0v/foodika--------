import 'dart:developer';

import 'package:foodika/core/models/review_model.dart';
import 'package:foodika/core/models/user_model.dart';
import 'package:foodika/core/repos/auth_rep.dart';
import 'package:foodika/core/services/fav_service.dart';
import 'package:foodika/core/services/my_scans_service.dart';
import 'package:foodika/screens/home/home_screen.dart';
import 'package:get/get.dart';

class AuthService extends GetxController {
  final _authRep = AuthRep();
  UserModel? user;
  bool isWasInit = false;

  Future<void> init() async {
    user = await _authRep.getCurrentUser();
    update();
    await _initOtherServices();
  }

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      user = await _authRep.loginWithEmail(
        email: email,
        password: password,
      );

      update();

      if (user == null) return false;
      
      await _initOtherServices();
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> registrationWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      user = await _authRep.registrationWithEmail(
        name: name,
        email: email,
        password: password,
      );
      update();

      await _initOtherServices();
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    Get.find<MyScansService>().onExit();
    Get.find<FavService>().onExit();
    user = null;
    update();
    await _authRep.signOut();
  }

  Future<void> saveProfilePhoto(
    String filePath,
    String? oldPhotoUrl,
  ) async {
    try {
      await _authRep.saveProfilePhoto(filePath, user!.id);

      user = await _authRep.getUser(user!.id);
      update();
    } catch (e) {
      log(e.toString());
    }

    try {
      if (oldPhotoUrl != null) {
        await _authRep.deletePhotoUrl(oldPhotoUrl);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> updateUserName(String name) async {
    await _authRep.updateUserName(user!.id, name);
    user = await _authRep.getUser(user!.id);
    update();
  }

  Future<void> updateAboudUser(String about) async {
    await _authRep.updateAboudUser(user!.id, about);
    user = await _authRep.getUser(user!.id);
    update();
  }

  Future<void> loginWithApple() async {
    try {
      await _authRep.loginWitnApple();
      user = await _authRep.getCurrentUser();
      await _initOtherServices();
      update();
      Get.offAll(() => const HomeScreen());
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      await _authRep.loginWithGoogle();
      user = await _authRep.getCurrentUser();
      await _initOtherServices();
      update();
      Get.offAll(() => const HomeScreen());
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> toogleNotifications() async {
    if (user == null) return;
    user!.isNotificationsEnable = !user!.isNotificationsEnable;
    update();

    await _authRep.toogleNotifications(
      newValue: user!.isNotificationsEnable,
      userId: user!.id,
    );
  }

  Future<void> _initOtherServices() async {
    await Get.find<MyScansService>().init(user);
    await Get.find<FavService>().init(user);
  }

  Future<void> addProductIdReviewForUser({
    required String productId,
  }) async {
    await _authRep.addProductIdReviewForUser(
      userId: user!.id,
      productId: productId,
    );
    user = await _authRep.getUser(user!.id);
    update();
  }

  Future<void> toggleBlockedUsers(
    String otherUserId,
  ) async {
    if (user == null) return;

    var ids = [...user!.blockedUsers];
    if (ids.contains(otherUserId)) {
      ids.remove(otherUserId);
    } else {
      ids.add(otherUserId);
    }

    await _authRep.saveBlockedUsers(user!.id, ids);

    user = await _authRep.getUser(user!.id);
    update();
  }

  Future<List<ReviewModel>> getMyReviews() async {
    if (user?.id == null) return [];
    return _authRep.getMyReviews(user!.id);
  }

  Future<void> deleteReview(String productId) async {
    if (user == null) return;
    await _authRep.deleteReviewedProduct(user!.id, productId);
    user = await _authRep.getUser(user!.id);
    update();
  }

  Future<void> deleteAccount() async {
    if (user == null) return;
    var userId = user!.id;
    user = null;
    update();
    Get.offAll(() => const HomeScreen());
    Get.find<MyScansService>().onExit();
    Get.find<FavService>().onExit();
    await _authRep.deleteAccount(userId);
  }
}
