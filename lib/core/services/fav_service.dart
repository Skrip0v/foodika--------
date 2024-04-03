import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/models/user_model.dart';
import 'package:foodika/core/repos/fav_rep.dart';
import 'package:get/get.dart';

class FavService extends GetxController {
  List<String> favIds = [];
  List<ProductModel> fav = [];
  UserModel? user;
  final _favRep = FavRep();

  Future<void> init(UserModel? initUser) async {
    user = initUser;

    favIds = user?.favIds == null ? [] : [...user!.favIds];

    if (favIds.isEmpty) {
      update();
      return;
    }

    fav = await _favRep.getProducts(favIds);
    update();
  }

  void onExit() {
    user = null;
    fav = [];
    favIds = [];
    update();
  }

  Future<void> favToogle(String productBarcode, ProductModel product) async {
    if (favIds.contains(productBarcode)) {
      favIds.remove(productBarcode);
      fav.removeWhere((e) => e.barcode == productBarcode);
    } else {
      favIds.insert(0, productBarcode);
      fav.insert(0, product);
    }
    update();

    await _favRep.saveFav(userId: user!.id, ids: favIds);
  }

  void updateProducts(List<ProductModel> products) {
    var isHasChanges = false;

    for (var product in products) {
      var inMyScan = fav.firstWhereOrNull((e) => e.barcode == product.barcode);
      if (inMyScan == null) continue;
      isHasChanges = true;
      var index = fav.indexOf(inMyScan);
      fav[index] = product;
    }
    if (isHasChanges == false) return;

    update();
  }
}
