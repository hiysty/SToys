import 'package:cached_network_image/cached_network_image.dart';
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
    List<Product> rawData = [];
    Map<String, int> interests;
    try {
      interests = Map<String, int>.from(await FirebaseFirestore.instance
          .collection('users')
          .doc(User_.email)
          .get()
          .then((value) => value.data()!["interests"]));
    } catch (e) {
      interests = {};
    }

    var sortedEntries = interests.entries.toList()
      ..sort((a, b) {
        var valueComparison = b.value.compareTo(a.value);
        if (valueComparison != 0) {
          return valueComparison;
        }
        return a.key.compareTo(b.key); // secondary comparison by key
      });

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
          Product newProduct = Product.fromJson(product);
          rawData.add(newProduct);
        }
      }
    }
    List<String> mostLikedCategories = [];

    final tempRawData = rawData.toList();

    for (var element in tempRawData) {
      for (var entry in sortedEntries) {
        if (element.category == entry.key) {
          data.add(element);
          rawData.remove(element);
        }
      }
    }
    data.addAll(rawData);

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

  Future manageInterests() async {
    if (widget.product.email == User_.email) return;

    final docRef =
        FirebaseFirestore.instance.collection('users').doc(User_.email);

    int newInterest = await docRef.get().then((doc) {
      try {
        final data = doc.data()!["interests"];
        try {
          return data[widget.product.category]! + 1;
        } catch (e) {
          return 1;
        }
      } catch (e) {
        return 1;
      }
    });
    await docRef.set({
      "interests": {widget.product.category: newInterest}
    }, SetOptions(merge: true));
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
                                  InspectProductPage(product_: widget.product)))
                      .then((value) => manageInterests()),
                  child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              child: Row(children: [
                                GestureDetector(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ProfilePage(
                                                widget.product.email))).then(
                                        (value) => ProfilePage(User_.email)),
                                    child: Stack(children: [
                                      const CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.transparent,
                                          child: SizedBox(
                                              height: 32,
                                              width: 32,
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator()))),
                                      CircleAvatar(
                                        radius: 24,
                                        foregroundImage:
                                            CachedNetworkImageProvider(
                                                data.data!["profilePicture"]),
                                        backgroundColor: Colors.transparent,
                                      )
                                    ])),
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
                          SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: CachedNetworkImage(
                                imageUrl: widget.product.imgLinksURLs[0],
                                fadeInDuration: Duration.zero,
                                fadeOutDuration: Duration.zero,
                                fit: BoxFit.fitWidth,
                                progressIndicatorBuilder:
                                    (context, url, progress) => Container(
                                        color: Colors.grey.shade300,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                2 /
                                                3,
                                        child: const Center(
                                            child:
                                                CircularProgressIndicator())),
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
          return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                  onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  InspectProductPage(product_: widget.product)))
                      .then((value) => manageInterests()),
                  child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height:
                                  MediaQuery.of(context).size.height * 2 / 3,
                              child: const Center(
                                  child: CircularProgressIndicator())),
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
        }
      });
}
