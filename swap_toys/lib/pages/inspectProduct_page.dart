import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/product.dart';
import 'package:swap_toys/models/user.dart';
import 'package:swap_toys/pages/createProduct_page.dart';
import 'package:swap_toys/pages/error_page.dart';
import 'package:swap_toys/pages/profile_page.dart';
import 'package:swap_toys/pages/updateProduct_page.dart';
import 'styles.dart';

import 'exchange_page.dart';

late Product product;

class InspectProductPage extends StatefulWidget {
  const InspectProductPage({
    super.key,
    required this.product_,
  });
  final Product product_;

  @override
  InspectProductPageState createState() {
    product = product_;
    return InspectProductPageState();
  }
}

class InspectProductPageState extends State<InspectProductPage> {
  InspectProductPageState();
  List<Widget> images = [];
  @override
  Widget build(BuildContext context) {
    getImagesViaUrl(product.imgLinksURLs).then((value) {
      setState(() {
        images = value;
      });
    });
    return Scaffold(
        backgroundColor: backgroundColorDefault,
        appBar: AppBar(
            title: const Text(
          'Ürün İncele',
          style: appBar,
        )),
        body: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(product.email)
                .get()
                .then((value) => value['displayName']),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Container(
                        color: Colors.white,
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 7, 15, 7),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    product.title,
                                    style: header,
                                  ),
                                  Text(
                                    snapshot.data,
                                    style: body,
                                  )
                                ]))),
                    Container(
                      color: backgroundColorDefault,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width,
                      child: PageView(
                        children: images,
                      ),
                    ),
                    SizedBox(
                        width: double.infinity,
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.description,
                                      textAlign: TextAlign.left, style: header),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text("Durum: ${statusList[product.status]}",
                                      style: header),
                                  Text(
                                    "Kategori: ${product.category}",
                                    style: header,
                                  ),
                                  Text(
                                    "Sahibi: ${product.exchangedTimes}",
                                    style: header,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  )
                                ]))),
                    updateExchangeButton(context)
                  ],
                );
              } else if (snapshot.hasError) {
                return ErrorPage(errorCode: snapshot.error.toString());
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }

  Future<List<Widget>> getImagesViaUrl(List<String> urlList) async {
    List<Widget> imageWidgets = [];

    for (String url in urlList) {
      Widget img = Image(
        image: NetworkImage(url),
        fit: BoxFit.fitHeight,
      );
      imageWidgets.add(img);
    }

    return imageWidgets;
  }

  Widget updateExchangeButton(BuildContext context) {
    if (product.email == User_.email) {
      return ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UpdateProduct(product)),
            );
          },
          child: const Text(
            "Ürünü Güncelle",
            style: TextStyle(fontSize: 20),
          ));
    } else {
      return ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ExchangePage(recievedProduct: product)));
          },
          child: const Text(
            "Takas teklif et!",
            style: TextStyle(fontSize: 20),
          ));
    }
  }
}
