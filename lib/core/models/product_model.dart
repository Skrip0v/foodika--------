// ignore_for_file: public_member_api_docs, sort_constructors_first

class ProductModel {
  ///ID продукта в GS1
  String gtin;

  ///Фотографии продукта. Может быть пустым
  List<ProductInfoModel> photoUrls;

  ///Название продукта на всех доступных языках
  List<ProductInfoModel>? productDescription;

  ///Название бренда на всех доступых языках
  List<ProductInfoModel>? brandName;

  ///Лицензия
  String? licenseeName;

  ///Дата создания продукта в GS1
  String? dateCreated;

  ///Рейтинг продукта
  ProductRateModel rate;

  double rating;

  ///ID категории в Firebase
  String? categoryId;

  String barcode;

  ///Коды стран, в которой продается данный товар
  List<ProductCountryOfSaleModel>? countryOfSaleCode;

  List<String> q;

  ProductModel({
    required this.gtin,
    required this.photoUrls,
    required this.productDescription,
    required this.brandName,
    required this.licenseeName,
    required this.dateCreated,
    required this.rate,
    required this.categoryId,
    required this.countryOfSaleCode,
    required this.rating,
    required this.barcode,
    required this.q,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gtin': gtin,
      'photoUrls': photoUrls.map((x) => x.toMap()).toList(),
      'productDescription': productDescription?.map((x) => x.toMap()).toList(),
      'brandName': brandName?.map((x) => x.toMap()).toList(),
      'licenseeName': licenseeName,
      'dateCreated': dateCreated,
      'rate': rate.toMap(),
      'categoryId': categoryId,
      'countryOfSaleCode': countryOfSaleCode?.map((x) => x.toMap()).toList(),
      'rating': rating,
      'q': getQ(),
      'barcode': barcode,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      gtin: map['gtin'] as String,
      rating: map['rating'] is int
          ? map['rating'].toDouble()
          : map['rating'] as double,
      photoUrls: List<ProductInfoModel>.from(
        (map['photoUrls'] as List<dynamic>).map<ProductInfoModel>((x) {
          if (x is String) {
            return ProductInfoModel(language: 'en', value: x);
          }
          return ProductInfoModel.fromMap(x as Map<String, dynamic>);
        }),
      ),
      productDescription: map['productDescription'] == null
          ? null
          : List<ProductInfoModel>.from(
              (map['productDescription'] as List<dynamic>)
                  .map<ProductInfoModel>(
                (x) => ProductInfoModel.fromMap(x as Map<String, dynamic>),
              ),
            ),
      q: List<String>.from((map['q'] as List<dynamic>)),
      brandName: List<ProductInfoModel>.from(
        (map['brandName'] as List<dynamic>).map<ProductInfoModel>(
          (x) => ProductInfoModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      licenseeName: map['licenseeName'] as String?,
      dateCreated: map['dateCreated'] as String?,
      rate: ProductRateModel.fromMap(map['rate'] as Map<String, dynamic>),
      categoryId:
          map['categoryId'] == null ? null : map['categoryId'] as String,
      barcode: map['barcode'] as String,
      countryOfSaleCode: map['countryOfSaleCode'] == null
          ? null
          : List<ProductCountryOfSaleModel>.from(
              (map['countryOfSaleCode'] as List<dynamic>)
                  .map<ProductCountryOfSaleModel>(
                (x) => ProductCountryOfSaleModel.fromMap(
                    x as Map<String, dynamic>),
              ),
            ),
    );
  }

  Map<String, String> productDescriptionToMap() {
    Map<String, String> map = {};

    for (var e in productDescription ?? []) {
      map.addAll({e.language: e.value});
    }

    return map;
  }

  Map<String, String> brandNameToMap() {
    Map<String, String> map = {};
    if (brandName == null) return map;

    for (var e in brandName!) {
      map.addAll({e.language: e.value});
    }

    return map;
  }

  List<String> getQ() {
    List<String> list = [];

    for (var item in productDescription ?? []) {
      var value = item.value;
      value = value
          .replaceAll(', ', '')
          .replaceAll('!', '')
          .replaceAll('?', '')
          .replaceAll('.', '')
          .replaceAll(';', '');

      for (var i = 0; i < value.length; i++) {
        list.add(
          value.substring(0, i + 1).toLowerCase(),
        );
      }

      var wordsEng = value.toLowerCase().split(' ');
      for (var word in wordsEng) {
        for (var i = 0; i < word.length; i++) {
          list.add(
            word.substring(0, i + 1).toLowerCase(),
          );
        }
      }

      list.addAll(wordsEng);
    }

    return list;
  }
}

class ProductInfoModel {
  String language;
  String value;

  ProductInfoModel({
    required this.language,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'language': language,
      'value': value,
    };
  }

  factory ProductInfoModel.fromMap(Map<String, dynamic> map) {
    return ProductInfoModel(
      language: map['language'] as String,
      value: map['value'] as String,
    );
  }
}

class ProductRateModel {
  int count1;
  int count2;
  int count3;
  int count4;
  int count5;

  ProductRateModel({
    required this.count1,
    required this.count2,
    required this.count3,
    required this.count4,
    required this.count5,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'count1': count1,
      'count2': count2,
      'count3': count3,
      'count4': count4,
      'count5': count5,
    };
  }

  factory ProductRateModel.fromMap(Map<String, dynamic> map) {
    return ProductRateModel(
      count1: map['count1'] as int,
      count2: map['count2'] as int,
      count3: map['count3'] as int,
      count4: map['count4'] as int,
      count5: map['count5'] as int,
    );
  }

  int get allCount {
    return count1 + count2 + count3 + count4 + count5;
  }

  int get sum {
    return (count1 * 1) +
        (count2 * 2) +
        (count3 * 3) +
        (count4 * 4) +
        (count5 * 5);
  }
}

class ProductCountryOfSaleModel {
  String numeric;
  String? alpha2;
  String? alpha3;

  ProductCountryOfSaleModel({
    required this.numeric,
    this.alpha2,
    this.alpha3,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'numeric': numeric,
      'alpha2': alpha2,
      'alpha3': alpha3,
    };
  }

  factory ProductCountryOfSaleModel.fromMap(Map<String, dynamic> map) {
    return ProductCountryOfSaleModel(
      numeric: map['numeric'] as String,
      alpha2: map['alpha2'] != null ? map['alpha2'] as String : null,
      alpha3: map['alpha3'] != null ? map['alpha3'] as String : null,
    );
  }
}
