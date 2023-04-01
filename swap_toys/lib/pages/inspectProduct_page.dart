import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final pageController = PageController(initialPage: 0);

  Future<Map<String, String>> getData() async {
    String displayName = await FirebaseFirestore.instance
        .collection('users')
        .doc(product.email)
        .get()
        .then((value) => value['displayName']);

    return {
      'displayName': displayName,
    };
  }

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
        body: FutureBuilder<Map<String, String>>(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                    child: Column(
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 500,
                        child: PageView(
                          controller: pageController,
                          children: images,
                        )),
                    Container(
                        color: Colors.white,
                        width: double.infinity,
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.title,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromARGB(
                                              255, 31, 62, 166))),
                                  Text(product.description,
                                      textAlign: TextAlign.left, style: body),
                                ]))),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                            child: Container(
                                color: Colors.white,
                                width:
                                    MediaQuery.of(context).size.width / 3 - 10,
                                height: 100,
                                child: Center(
                                    child: Text(
                                  "Durum:\n${statusList[product.status]}",
                                  style: header,
                                  textAlign: TextAlign.center,
                                )))),
                        Container(
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width / 3 - 10,
                            height: 100,
                            child: Center(
                              child: Text(
                                "Kategori:\n${product.category}",
                                style: header,
                                textAlign: TextAlign.center,
                              ),
                            )),
                        Container(
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width / 3 - 10,
                          height: 100,
                          child: Center(
                              child: Text(
                            "Sahibi:\n${product.exchangedTimes}.",
                            style: header,
                            textAlign: TextAlign.center,
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    updateExchangeButton(context)
                  ],
                ));
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
        fit: BoxFit.fitWidth,
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
