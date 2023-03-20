import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swap_toys/models/product.dart';

class ExchangeNotification {
  late String id;
  late Product recievedProduct;
  late Product givenProduct;

  ExchangeNotification(
      {required this.id,
      required this.recievedProduct,
      required this.givenProduct});

  ExchangeNotification.fromJSON(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    id = doc.id;
    recievedProduct = Product.fromJsonWithoutId(data["recievedProduct"]);
    givenProduct = Product.fromJsonWithoutId(data["givenProduct"]);
  }

  Map<String, dynamic> toJSON(bool reverse) {
    if (!reverse) {
      return {
        "recievedProduct": recievedProduct.toJSONNotification(),
        "givenProduct": givenProduct.toJSONNotification(),
      };
    } else {
      return {
        "recievedProduct": givenProduct.toJSONNotification(),
        "givenProduct": recievedProduct.toJSONNotification(),
      };
    }
  }
}
