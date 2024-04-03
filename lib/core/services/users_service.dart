import 'dart:developer';

import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/models/user_model.dart';
import 'package:foodika/core/repos/users_rep.dart';
import 'package:foodika/core/services/auth_service.dart';
import 'package:get/get.dart';

class UsersService extends GetxController {
  List<UserModel> users = [];
  final _usersRep = UsersRep();

  Future<void> getInfoAboutUsers(List<String> newIds) async {
    var ids = [...newIds];

    var currentUserId = Get.find<AuthService>().user?.id;

    ids.removeWhere((id) {
      if (currentUserId == id) return true;
      return false;
    });

    log('start get info about ${ids.length} users');

    if (ids.isEmpty) return;

    var newUsers = await _usersRep.getUsers(ids);
    users.addAll(newUsers);

    update();
  }

  UserModel? getUser(String userId) {
    var service = Get.find<AuthService>();
    var currentUserId = service.user?.id;
    if (currentUserId == userId) return service.user;

    var user = users.firstWhereOrNull((e) => e.id == userId);
    return user;
  }

  Future<List<ProductModel>> getFavProductForUser(List<String> ids) async {
    return await _usersRep.getFavProductForUser(ids);
  }
}
