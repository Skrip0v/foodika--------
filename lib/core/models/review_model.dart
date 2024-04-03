// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:foodika/core/models/product_model.dart';

class ReviewModel {
  String id;
  String authorId;
  int createDate;
  int countLikes;
  String productBarcode;
  List<String> whoLikeIds;
  String text;
  double rating;
  ProductModel? product;

  ReviewModel({
    required this.id,
    required this.authorId,
    required this.createDate,
    required this.countLikes,
    required this.whoLikeIds,
    required this.productBarcode,
    required this.text,
    required this.rating,
    this.product,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'authorId': authorId,
      'createDate': createDate,
      'countLikes': countLikes,
      'whoLikeIds': whoLikeIds,
      'text': text,
      'rating': rating,
      'productBarcode': productBarcode,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as String,
      authorId: map['authorId'] as String,
      createDate: map['createDate'] as int,
      countLikes: map['countLikes'] as int,
      productBarcode: map['productBarcode'] as String,
      whoLikeIds: List<String>.from(
        map['whoLikeIds'].map(
          (e) => e.toString(),
        ),
      ),
      text: map['text'] as String,
      rating: map['rating'] is int
          ? map['rating'].toDouble()
          : map['rating'] as double,
    );
  }

  ReviewModel copyWith({
    String? id,
    String? authorId,
    int? createDate,
    int? countLikes,
    String? productBarcode,
    List<String>? whoLikeIds,
    String? text,
    double? rating,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      createDate: createDate ?? this.createDate,
      countLikes: countLikes ?? this.countLikes,
      productBarcode: productBarcode ?? this.productBarcode,
      whoLikeIds: whoLikeIds ?? this.whoLikeIds,
      text: text ?? this.text,
      rating: rating ?? this.rating,
    );
  }
}
