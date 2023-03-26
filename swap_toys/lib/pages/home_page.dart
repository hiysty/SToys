import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:like_button/like_button.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/user.dart';
import 'package:swap_toys/pages/error_page.dart';
import 'package:swap_toys/pages/inspectProduct_page.dart';
import 'package:swap_toys/pages/profile_page.dart';
import '../models/product.dart';
import 'styles.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Product>> getHomePage() async {
    List<Product> data = [];

    final users = await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value) => value.docs);

    for (var user in users) {
      if (user.data()["email"] != User_.email) {
        List<QueryDocumentSnapshot> products = await user.reference
            .collection('products')
            .get()
            .then((value) => value.docs);
        for (var product in products) {
          data.add(Product.fromJson(product));
        }
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: backgroundColorDefault,
        appBar: AppBar(title: const Text('Keşfet', style: appBar)),
        body: FutureBuilder<List<Product>>(
          future: getHomePage(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) =>
                      HomePageTile(snapshot.data!.elementAt(index)));
            } else if (snapshot.hasError) {
              return ErrorPage(errorCode: snapshot.error.toString());
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      );
}

class HomePageTile extends StatefulWidget {
  Product product;

  HomePageTile(this.product, {super.key});

  @override
  State<HomePageTile> createState() => _HomePageTileState();
}

class _HomePageTileState extends State<HomePageTile> {
  Future<Map<String, dynamic>> getData() async {
    return {
      "username": await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.product.email)
          .get()
          .then((value) => value.data()!["displayName"]),
      "profilePicture": await FirebaseStorage.instance
          .ref()
          .child('profilePictures/${widget.product.email}')
          .getDownloadURL()
    };
  }

  Future<bool> likeButton(bool isLiked) async {
    return !isLiked;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
      future: getData(),
      builder: (context, data) {
        if (data.hasData) {
          return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              InspectProductPage(product_: widget.product))),
                  child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              child: Row(children: [
                                CircleAvatar(
                                  radius: 24,
                                  foregroundImage: NetworkImage(
                                      data.data!["profilePicture"]),
                                  backgroundImage: const AssetImage(
                                      'lib/assets/images/default.png'),
                                  backgroundColor: Colors.white,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.product.title, style: header),
                                    Text(data.data!["username"], style: body)
                                  ],
                                )
                              ])),
                          Container(
                              color: Colors.grey.shade300,
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                widget.product.imgLinksURLs[0],
                                fit: BoxFit.fill,
                              )),
                          Container(
                            color: Colors.white,
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    LikeButton(
                                      size: 37,
                                      likeCount: 30,
                                      onTap: likeButton,
                                      likeBuilder: (isLiked) {
                                        return Icon(
                                          Icons.favorite_rounded,
                                          size: 37,
                                          color: isLiked
                                              ? Colors.red
                                              : Colors.blue,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.messenger_rounded,
                                        size: 37,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    IconButton(
                                        enableFeedback: false,
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.send_rounded,
                                          color: Colors.blue,
                                          size: 37,
                                        ))
                                  ],
                                )),
                          )
                        ],
                      ))));
        } else if (data.hasError) {
          return ErrorPage(errorCode: data.error.toString());
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      });
}
