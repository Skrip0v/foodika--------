import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodika/core/models/product_model.dart';

Future<void> sendToFirebase(List<ProductModel> products) async {
  int count = 0;
  for (var product in products) {
    count++;
    await FirebaseFirestore.instance
        .doc('products/${product.barcode}')
        .set(product.toMap());
    print(count.toString());
  }
}
