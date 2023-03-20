import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/main.dart';
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
      List<QueryDocumentSnapshot> products = await user.reference
          .collection('products')
          .get()
          .then((value) => value.docs);
      for (var product in products) {
        data.add(Product.fromJson(product));
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Keşfet', style: appBar)),
        body: FutureBuilder<List<Product>>(
          future: getHomePage(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: GridView.count(
                    crossAxisCount: 3,
                    padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    shrinkWrap: true,
                    children: List.generate(snapshot.data!.length,
                        (index) => ProductGrid(snapshot.data![index], index)),
                  ));
            } else if (snapshot.hasError) {
              return ErrorPage(errorCode: snapshot.error.toString());
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      );
}
