import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:swap_toys/models/product.dart';

class user {
  late String displayName;
  late String email;
  late List<Product> userProducts;

  user(String displayName, String email) {
    this.displayName = displayName;
    this.email = email;
  }

  void fromDB(String email) async {
    DocumentSnapshot a =
        await FirebaseFirestore.instance.collection("users").doc(email).get();

    this.displayName = a["displayName"];
    this.email = email;
    print(a["displayName"]);
  }

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

  Future<List<Product>> MyProducts(QueryDocumentSnapshot userSnapShot) async {
    List<Product> myProducts_ = [];
    var product = await userSnapShot.reference.collection("products").get();

    myProducts_ = product.docs.map((e) => Product.fromJson(e.data())).toList();
    userProducts = myProducts_;
    return myProducts_;
  }

  bool isAboutMe(String query) {
    List<String> words = this.displayName.split(" ");

    for (var word in words) {
      String word_ = word.toLowerCase();
      String query_ = query.toLowerCase();

      if (word_.contains(query_)) return true;
    }

    return false;
  }
}
