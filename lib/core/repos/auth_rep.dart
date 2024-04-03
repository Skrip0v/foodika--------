import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/models/review_model.dart';
import 'package:foodika/core/models/user_model.dart';
import 'package:foodika/functions/show_error_dialog.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';

class AuthRep {
  Future<UserModel?> getCurrentUser() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    var uid = currentUser?.uid;
    log(uid.toString());

    if (uid == null) return null;

    try {
      return getUser(uid);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<UserModel?> getUser(String userId) async {
    var cloud = FirebaseFirestore.instance;
    var res = await cloud.doc('users/$userId').get();
    return UserModel.fromMap(res.data()!);
  }

  Future<UserModel?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    var auth = FirebaseAuth.instance;
    try {
      var res = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      var uid = res.user!.uid;
      var cloud = FirebaseFirestore.instance;

      var userMap = await cloud.doc('users/$uid').get();
      return UserModel.fromMap(userMap.data()!);
    } on FirebaseAuthException catch (e) {
      var code = e.code;
      log(e.code.toString());
      if (code == 'invalid-email') {
        showErrorDialog(
          Get.context!,
          title: 'Error'.tr,
          content: 'Incorrect email format'.tr,
          okButtonText: 'Ok'.tr,
        );
      } else if (code == 'user-disabled') {
        showErrorDialog(
          Get.context!,
          title: 'Error'.tr,
          content: 'User corresponding to the given email has been disabled'.tr,
          okButtonText: 'Ok'.tr,
        );
      } else if (code == 'user-not-found') {
        showErrorDialog(
          Get.context!,
          title: 'Error'.tr,
          content: 'The user was not found with this email'.tr,
          okButtonText: 'Ok'.tr,
        );
      } else if (code == 'wrong-password') {
        showErrorDialog(
          Get.context!,
          title: 'Error'.tr,
          content:
              'The password is invalid for the given email, or the account corresponding to the email does not have a password set'
                  .tr,
          okButtonText: 'Ok'.tr,
        );
      } else {
        showErrorDialog(
          Get.context!,
          title: 'Error'.tr,
          content: 'The wrong email or password'.tr,
          okButtonText: 'Ok'.tr,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel> registrationWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    var auth = FirebaseAuth.instance;
    var res = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    var uid = res.user!.uid;
    var cloud = FirebaseFirestore.instance;

    var user = UserModel(
      id: uid,
      email: email,
      name: name,
      myScansIds: [],
      productIdsRate: [],
      isAccountDeleted: false,
      blockedUsers: [],
      favIds: [],
      accountCreateDate: DateTime.now().toUtc().millisecondsSinceEpoch,
      about: null,
      photoUrl: null,
      isNotificationsEnable: true,
    );

    await cloud.doc('users/$uid').set(user.toMap());

    return user;
  }

  Future<void> signOut() async {
    var auth = FirebaseAuth.instance;
    await auth.signOut();
  }

  Future<void> saveProfilePhoto(
    String filePath,
    String userId,
  ) async {
    var storage = FirebaseStorage.instance;
    var reference =
        storage.ref().child("profile_images/${userId}_${const Uuid().v4()}");
    var res = await reference.putFile(File(filePath));
    var url = await res.ref.getDownloadURL();

    var cloud = FirebaseFirestore.instance;
    await cloud.doc('users/$userId').update({
      'photoUrl': url,
    });
  }

  Future<void> updateUserName(String userId, String name) async {
    var cloud = FirebaseFirestore.instance;
    await cloud.doc('users/$userId').update({
      'name': name,
    });
  }

  Future<void> deletePhotoUrl(String oldPhoto) async {
    await FirebaseStorage.instance.refFromURL(oldPhoto).delete();
  }

  Future<void> deleteReviewedProduct(
    String userId,
    String productId,
  ) async {
    log('start delete user - $productId');
    var cloud = FirebaseFirestore.instance;
    await cloud.doc('users/$userId').update({
      'productIdsRate': FieldValue.arrayRemove([productId]),
    });
  }

  Future<void> updateAboudUser(String userId, String about) async {
    var cloud = FirebaseFirestore.instance;
    await cloud.doc('users/$userId').update({
      'about': about,
    });
  }

  String generateNonce([int length = 32]) {
    var charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = math.Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> loginWitnApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    var res = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    var uid = res.user?.uid;
    if (uid == null) {
      throw Exception('error');
    }

    var userInBase = await FirebaseFirestore.instance.doc('users/$uid').get();
    if (userInBase.data() == null) {
      var user = UserModel(
        id: res.user!.uid,
        productIdsRate: [],
        email: res.user?.email ?? 'unknown email',
        name: res.user!.displayName ?? 'unknown name',
        isAccountDeleted: false,
        blockedUsers: [],
        myScansIds: [],
        favIds: [],
        accountCreateDate: DateTime.now().toUtc().millisecondsSinceEpoch,
        about: null,
        photoUrl: null,
        isNotificationsEnable: true,
      );
      var cloud = FirebaseFirestore.instance;
      await cloud.doc('users/${res.user!.uid}').set(user.toMap());
    }
  }

  Future<void> toogleNotifications({
    required bool newValue,
    required String userId,
  }) async {
    var cloud = FirebaseFirestore.instance;
    await cloud.doc('users/$userId').update({
      'isNotificationsEnable': newValue,
    });
  }

  Future<void> addProductIdReviewForUser({
    required String userId,
    required String productId,
  }) async {
    await FirebaseFirestore.instance.doc('users/$userId').update({
      'productIdsRate': FieldValue.arrayUnion([productId]),
    });
  }

  Future<void> saveBlockedUsers(
    String userId,
    List<String> ids,
  ) async {
    await FirebaseFirestore.instance.doc('users/$userId').update({
      'blockedUsers': ids,
    });
  }

  Future<void> loginWithGoogle() async {
    var googleUser = await GoogleSignIn(
      scopes: ['email'],
      clientId:
          '868307104703-24v2a6nlqadaif60ja833tha46a3ot2p.apps.googleusercontent.com',
    ).signIn();
    log('1');
    var googleAuth = await googleUser?.authentication;
    log('2');

    var credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    var res = await FirebaseAuth.instance.signInWithCredential(credential);
    log('3');

    var uid = res.user?.uid;
    if (uid == null) {
      throw Exception('error');
    }

    log('4');

    var userInBase = await FirebaseFirestore.instance.doc('users/$uid').get();
    if (userInBase.data() == null) {
      var user = UserModel(
        id: res.user!.uid,
        productIdsRate: [],
        email: res.user?.email ?? 'unknown email',
        name: res.user!.displayName ?? 'unknown name',
        isAccountDeleted: false,
        blockedUsers: [],
        myScansIds: [],
        favIds: [],
        accountCreateDate: DateTime.now().toUtc().millisecondsSinceEpoch,
        about: null,
        photoUrl: null,
        isNotificationsEnable: true,
      );
      var cloud = FirebaseFirestore.instance;
      await cloud.doc('users/${res.user!.uid}').set(user.toMap());
    }
  }

  Future<List<ReviewModel>> getMyReviews(String userId) async {
    var res = await FirebaseFirestore.instance
        .collection('reviews')
        .where('authorId', isEqualTo: userId)
        .orderBy('createDate', descending: true)
        .get();

    List<ReviewModel> reviews = [];

    for (var doc in res.docs) {
      reviews.add(ReviewModel.fromMap(doc.data()));
    }

    if (reviews.isEmpty) return [];

    var barcodes = reviews.map((e) => e.productBarcode).toList();
    var products = await _getProductsForMyReviews(barcodes);

    for (var product in products) {
      var review =
          reviews.firstWhere((e) => e.productBarcode == product.barcode);
      var index = reviews.indexOf(review);
      reviews[index].product = product;
    }

    return reviews;
  }

  Future<List<ProductModel>> _getProductsForMyReviews(
      List<String> barcodes) async {
    var res = await FirebaseFirestore.instance
        .collection('products')
        .where('barcode', whereIn: barcodes)
        .get();

    List<ProductModel> products = [];

    for (var doc in res.docs) {
      products.add(ProductModel.fromMap(doc.data()));
    }

    return products;
  }

  Future<void> deleteAccount(String userId) async {
    await FirebaseFirestore.instance.doc('users/$userId').update({
      'isAccountDeleted': true,
    });
    await signOut();
  }
}
