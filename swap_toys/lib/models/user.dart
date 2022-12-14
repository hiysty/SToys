import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swap_toys/models/product.dart';

class user {
  late String displayName;
  late String email;
  late Future<List<Product>> userProducts;
  late int productCount = 2;
  user(String displayName, String email) {
    this.displayName = displayName;
    this.email = email;
  }

  static Product fromJson(var doc) => Product(doc["title"], doc["status"],
      doc["imgList"], doc["desc"], doc["email"], doc["displayImg"]);

  Future saveUser() async {
    final docProduct = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.email);

    final json = {
      "email": FirebaseAuth.instance.currentUser!.email,
      "displayName": displayName
    };
    docProduct.set(json);
  }

  // Stream<QuerySnapshot> requestCount() {
  //   return FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(email)
  //       .collection("products")
  //       .get().;
  // }
}
