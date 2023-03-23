import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/user.dart';
import 'package:swap_toys/pages/error_page.dart';
import 'package:swap_toys/pages/inspectProduct_page.dart';
import 'package:swap_toys/pages/profile_page.dart';
import '../models/product.dart';
import 'styles.dart';

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
              return ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) =>
                          HomePageTile(snapshot.data!.elementAt(index))));
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
  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.product.email)
          .get()
          .then((value) => value.data()!["displayName"]),
      builder: (context, username) {
        if (username.hasData) {
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
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 3),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(widget.product.title, style: header),
                                  Text(username.data, style: body)
                                ],
                              )),
                          Container(
                              color: Colors.grey.shade300,
                              child: Center(
                                  child: Image.network(
                                widget.product.imgLinksURLs[0],
                                fit: BoxFit.fill,
                              ))),
                          Container(
                            color: Colors.white,
                            height: 25,
                          )
                        ],
                      ))));
        } else if (username.hasError) {
          return ErrorPage(errorCode: username.error.toString());
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      });
}
