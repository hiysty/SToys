import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/models/user.dart';

class Product {
  late String title;
  late int status;
  late Map imgsLinksMap;
  late String description;
  late String email;
  late String firsImg;
  late String id;

  late List<String> imgLinksURLs;

  Product(String title, int status, Map imgLinksMap, String description,
      String email,
      {String? id}) {
    this.title = title;
    this.status = status;
    this.imgsLinksMap = imgLinksMap;
    this.description = description;
    this.email = email;
    this.firsImg = imgLinksMap[0];
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

    await docProduct.set(toJson());
  }

  void updateProduct() {
    final refProduct = FirebaseFirestore.instance
        .collection("users")
        .doc(email)
        .collection("products")
        .doc(id);

    refProduct.update(toJson());
  }

  Product.fromJson(Map<String, dynamic> doc) {
    this.title = doc["title"];
    this.status = doc["status"];
    this.imgLinksURLs = mapToListForImgLinks(doc["imgList"]);
    this.description = doc["desc"];
    this.email = doc["email"];
  }
  Map<String, dynamic> toJson() {
    final json = {
      "title": title,
      "status": status,
      "desc": description,
      "imgList": imgsLinksMap,
      "email": email,
    };

    return json;
  }

  List<String> mapToListForImgLinks(var doc) {
    List<String> imgLinks_ = [];
    for (var i = 0; i < doc.length; i++) {
      imgLinks_.add(doc["$i"]);
    }
    return imgLinks_;
  }

  Future<Map> PathsToLinks(List<String> paths) async {
    final imgLinks = {"0": "1"};

    for (var i = 0; i < paths.length; i++) {
      File file = File(paths[i]);
      final ref =
          FirebaseStorage.instance.ref().child("images/${file.hashCode}}");
      UploadTask uploadtask = ref.putFile(file);

      String url = "";
      await uploadtask.whenComplete(() async {
        url = await ref.getDownloadURL();
      });

      imgLinks["$i"] = url;
    }
    return imgLinks;
  }
}
