import 'dart:developer';

import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/models/user_model.dart';
import 'package:foodika/core/repos/my_scans_rep.dart';
import 'package:get/get.dart';

class MyScansService extends GetxController {
  List<String> myScansIds = [];
  List<ProductModel> myScans = [];
  UserModel? user;
  final _myScansRep = MyScansRep();

  Future<void> init(UserModel? initUser) async {
    user = initUser;

    myScansIds = user?.myScansIds == null ? [] : [...user!.myScansIds];

    if (myScansIds.isEmpty) {
      update();
      return;
    }

    myScans = await _myScansRep.getMyScans(user!.id, myScansIds);
    log(myScans.toString());
    update();
  }

  void onExit() {
    user = null;
    myScans = [];
    myScansIds = [];
    update();
  }

  Future<void> addProductToMyScans(String barcode) async {
    log(user.toString(), name: 'kek');

    if (user == null) return;
    if (myScansIds.contains(barcode)) return;

    myScansIds.insert(0, barcode);
    await _myScansRep.saveProductsIdsToMyScans(
      userId: user!.id,
      ids: myScansIds,
    );
    var newProduct = await _myScansRep.getProduct(barcode);
    myScans.insert(0, newProduct);
    myScans = [...myScans];
    update();
  }

  void updateProducts(List<ProductModel> products) {
    var isHasChanges = false;

    for (var product in products) {
      var inMyScan = myScans.firstWhereOrNull((e) => e.barcode == product.barcode);
      if (inMyScan == null) continue;
      isHasChanges = true;
      var index = myScans.indexOf(inMyScan);
      myScans[index] = product;
    }
    if (isHasChanges == false) return;

    update();
  }
}
