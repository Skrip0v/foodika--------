// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  String id;
  String email;
  String name;
  String? about;
  String? photoUrl;
  List<String> blockedUsers;
  List<String> myScansIds;
  List<String> favIds;
  List<String> productIdsRate;
  int accountCreateDate;
  bool isNotificationsEnable;
  bool isAccountDeleted;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.productIdsRate,
    required this.myScansIds,
    required this.favIds,
    this.about,
    this.photoUrl,
    required this.blockedUsers,
    required this.accountCreateDate,
    required this.isNotificationsEnable,
    required this.isAccountDeleted,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'myScansIds': myScansIds,
      'id': id,
      'isAccountDeleted': false,
      'email': email,
      'name': name,
      'about': about,
      'photoUrl': photoUrl,
      'favIds': favIds,
      'productIdsRate': productIdsRate,
      'blockedUsers': blockedUsers,
      'accountCreateDate': accountCreateDate,
      'isNotificationsEnable': isNotificationsEnable,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      isAccountDeleted: map['isAccountDeleted'] == null
          ? false
          : map['isAccountDeleted'] as bool,
      productIdsRate: map['productIdsRate'] == null
          ? []
          : List<String>.from(
              map['productIdsRate'].map(
                (e) => e.toString(),
              ),
            ),
      myScansIds: map['myScansIds'] == null
          ? []
          : List<String>.from(
              map['myScansIds'].map(
                (e) => e.toString(),
              ),
            ),
      favIds: map['favIds'] == null
          ? []
          : List<String>.from(
              map['favIds'].map(
                (e) => e.toString(),
              ),
            ),
      email: map['email'] as String,
      name: map['name'] as String,
      about: map['about'] != null ? map['about'] as String : null,
      photoUrl: map['photoUrl'] != null ? map['photoUrl'] as String : null,
      blockedUsers: List<String>.from(
        map['blockedUsers'].map(
          (e) => e.toString(),
        ),
      ),
      accountCreateDate: map['accountCreateDate'] as int,
      isNotificationsEnable: map['isNotificationsEnable'] as bool,
    );
  }
}
