// ignore_for_file: public_member_api_docs, sort_constructors_first

class CategoryModel {
  String id;
  Map<String, String> name;
  List<String> gpcClassCodes;
  List<String> gpcBrickCodes;
  List<String> classDescription;
  String photoUrl;
  int sort;
  int countRateProductsFromThisCategory;

  CategoryModel({
    required this.id,
    required this.name,
    required this.gpcClassCodes,
    required this.gpcBrickCodes,
    required this.classDescription,
    required this.photoUrl,
    required this.sort,
    required this.countRateProductsFromThisCategory,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'gpcClassCodes': gpcClassCodes,
      'gpcBrickCodes': gpcBrickCodes,
      'classDescription': classDescription,
      'photoUrl': photoUrl,
      'sort': sort,
      'countRateProductsFromThisCategory': countRateProductsFromThisCategory,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: Map<String, String>.from((map['name'] as Map<String, dynamic>)),
      gpcBrickCodes: map['gpcBrickCodes'] == null
          ? []
          : List<String>.from((map['gpcBrickCodes'] as List<dynamic>)),
      gpcClassCodes: List<String>.from((map['gpcClassCodes'] as List<dynamic>)),
      classDescription: List<String>.from(
        (map['classDescription'] as List<dynamic>),
      ),
      photoUrl: map['photoUrl'] as String,
      sort: map['sort'].toInt(),
      countRateProductsFromThisCategory:
          map['countRateProductsFromThisCategory'] == null
              ? 0
              : map['countRateProductsFromThisCategory'].toInt(),
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, codes: $gpcClassCodes, classDescription: $classDescription, photoUrl: $photoUrl, sort: $sort)';
  }
}
