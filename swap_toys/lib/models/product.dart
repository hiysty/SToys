import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Product {
  late String title;
  late int status;
  late List<String> imgsPaths;
  late String id;
  late String? description;

  Product(String title, int status, List<String> imgsPaths, String id,
      {String? description}) {
    this.title = title;
    this.status = status;
    this.imgsPaths = imgsPaths;
    this.id = id;
    this.description = description;
  }

  Future createProduct() async {
    final docProduct = FirebaseFirestore.instance.collection("products").doc();

    final json = {"title": title, "status": status, "description": description};
    await docProduct.set(json);
  }

  late List<String> localImgPaths;
}
