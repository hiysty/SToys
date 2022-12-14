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
  late String displayImg;

  Product(String title, int status, Map imgLinks, String description,
      String email, String displayImg) {
    this.title = title;
    this.status = status;
    this.imgsLinks = imgLinks;
    this.description = description;
    this.email = email;
    this.displayImg = displayImg;
  }

  Future createProduct() async {
    var count = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("products")
        .get()
        .then((value) => value.size);

    final docProduct = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("products")
        .doc((count + 1).toString());

    final json = {
      "title": title,
      "status": status,
      "desc": description,
      "imgList": imgsLinks,
      "email": email,
      "displayImg": displayImg
    };
    await docProduct.set(json);
  }

  static Product fromJson(Map<String, dynamic> doc) => Product(
      doc["title"],
      doc["status"],
      doc["imgList"],
      doc["desc"],
      doc["email"],
      doc["displayImg"]);
}
