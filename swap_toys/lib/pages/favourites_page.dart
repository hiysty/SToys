import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/pages/error_page.dart';
import 'package:swap_toys/pages/inspectProduct_page.dart';
import 'package:swap_toys/pages/styles.dart';
import '../models/product.dart';

class Favorites extends StatefulWidget {
  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  Future<List<Product>> getFavouriteProducts() async {
    final collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(User_.email)
        .collection('likes');

    List<Product> data = [];

    for (var doc in await collectionRef.get().then((value) => value.docs)) {
      data.add(Product.fromJson(doc));
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColorDefault,
      appBar: AppBar(title: const Text('Favorilerim', style: appBar)),
      body: FutureBuilder<List<Product>>(
          future: getFavouriteProducts(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Product product = snapshot.data![index];
                    return ListTile(
                        tileColor: Colors.white,
                        leading: CircleAvatar(
                            foregroundImage: CachedNetworkImageProvider(
                                product.imgLinksURLs[0])),
                        title: Text(product.title, style: header),
                        subtitle: Text(product.description, style: body),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    InspectProductPage(product_: product))),
                        onLongPress: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(product.email)
                              .collection('products')
                              .doc(product.id)
                              .update({
                            'likes': await FirebaseFirestore.instance
                                .collection('users')
                                .doc(product.email)
                                .collection('products')
                                .doc(product.id)
                                .get()
                                .then((value) => value.data()!['likes'] - 1)
                          });
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(User_.email)
                              .collection('likes')
                              .doc(product.id)
                              .delete();
                          setState(() {});
                        });
                  });
            } else if (snapshot.hasError) {
              return ErrorPage(errorCode: snapshot.error.toString());
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
