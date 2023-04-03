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
  late String description;
  late String email;
  late String firstImg;
  late String id;
  late int exchangedTimes;
  late String category;
  late int likes;
  DateTime dateTime = DateTime.now();
  List<dynamic> tags = [];

  late List<String> imgLinksURLs;

  Product(this.title, this.status, this.imgLinksURLs, this.description,
      this.email, this.tags, this.category, this.likes) {
    exchangedTimes = 0;
    firstImg = imgLinksURLs[0];
  }

  Future createProduct() async {
    final docProduct = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("products")
        .doc();

    id = docProduct.id;

    await docProduct.set(toJson());
  }

  Future updateProduct() async {
    final refProduct = FirebaseFirestore.instance
        .collection("users")
        .doc(email)
        .collection("products")
        .doc(id.toString());

    await refProduct.update(toJson());
  }

  bool checkIfNull() {
    return [id].contains(null);
  }

  Product.fromJson(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    id = doc.id;
    title = data["title"];
    status = data["status"];
    if (data["imgList"] != null)
      imgLinksURLs = (data["imgList"] as List).map((e) => e as String).toList();
    description = data["desc"];
    email = data["email"];
    likes = data["likes"];
    if (data["tags"] != null) tags = data["tags"];
    if (data["category"] != null) category = data["category"];
    if (data["exchangedTimes"] != null) exchangedTimes = data["exchangedTimes"];
  }

  Product.fromJsonWithoutId(dynamic data) {
    title = data["title"];
    status = data["status"];
    if (data["imgList"] != null)
      imgLinksURLs = (data["imgList"] as List).map((e) => e as String).toList();
    description = data["desc"];
    email = data["email"];
    likes = data["likes"];
    if (data["tags"] != null) tags = data["tags"];
    if (data["category"] != null) category = data["category"];
    if (data["exchangedTimes"] != null) exchangedTimes = data["exchangedTimes"];
    id = data["id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      "title": title,
      "status": status,
      "desc": description,
      "imgList": imgLinksURLs,
      "email": email,
      "exchangedTimes": exchangedTimes,
      "category": category,
      "date_time": dateTime,
      "tags": tags,
      "likes": likes
    };

    return json;
  }

  Map<String, dynamic> toJSONNotification() {
    return {
      "title": title,
      "status": status,
      "desc": description,
      "imgList": imgLinksURLs,
      "email": email,
      "date_time": dateTime,
      "exchangedTimes": exchangedTimes,
      "category": category,
      "id": id,
      "tags": tags,
      "likes": likes
    };
  }

  Map<String, dynamic> toJSONExchangeComplete(String newMail) {
    return {
      "title": title,
      "status": status,
      "desc": description,
      "imgList": imgLinksURLs,
      "date_time": dateTime,
      "email": newMail,
      "exchangedTimes": exchangedTimes + 1,
      "category": category,
      "id": id,
      "tags": tags,
      "likes": 0
    };
  }

  List<String> mapToListForImgLinks(var doc) {
    List<String> imgLinks_ = [];
    for (var i = 0; i < doc.length; i++) {
      imgLinks_.add(doc["$i"]);
    }
    return imgLinks_;
  }

  Future<List<String>> PathsToLinks(List<String> paths) async {
    final List<String> imgLinks = [];

    for (var i = 0; i < paths.length; i++) {
      File file = File(paths[i]);
      final ref =
          FirebaseStorage.instance.ref().child("images/${file.hashCode}}");
      UploadTask uploadtask = ref.putFile(file);

      String url = "";
      await uploadtask.whenComplete(() async {
        url = await ref.getDownloadURL();
      });

      imgLinks.add(url);
    }
    return imgLinks;
  }

  List<String> Terms() {
    List<String> allWords = title.split(" ");
    allWords.addAll(List<String>.from(tags));
    return allWords;
  }

  bool isAboutMe(String query) {
    List<String> QW_list = query.split(" ");

    for (String word in Terms()) {
      final word_ = word.toLowerCase();
      for (var QW in QW_list) {
        final QW_L = QW.toLowerCase();
        if (word_.contains(QW_L)) return true;
      }
    }
    return false;
  }
}
