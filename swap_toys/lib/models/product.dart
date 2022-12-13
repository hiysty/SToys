import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:swap_toys/models/user.dart';

class Product {
  late String title;
  late int status;
  late Map imgsLinks;
  late String description;
  late String email;
  late user User_ = user("vx", "v");

  Product(String title, int status, Map imgLinks, String description,
      String email) {
    this.title = title;
    this.status = status;
    this.imgsLinks = imgLinks;
    this.description = description;
    this.email = email;
  }

  Future createProduct() async {
    final docProduct = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("products")
        .doc();

    final json = {
      "title": title,
      "status": status,
      "desc": description,
      "imgList": imgsLinks,
      "email": email
    };
    await docProduct.set(json);
  }

  static Product fromJson(var doc) => Product(
      doc["title"], doc["status"], doc["imgList"], doc["desc"], doc["email"]);
}
