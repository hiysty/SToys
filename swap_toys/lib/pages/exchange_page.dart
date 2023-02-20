import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/user.dart';
import 'package:swap_toys/pages/createProduct_page.dart';
import 'package:swap_toys/pages/inspectProduct_page.dart';
import 'package:swap_toys/pages/select_given_product.dart';
import 'package:swap_toys/pages/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/product.dart';

late Product receivedProduct;
late Product given_product;

late bool Isselected = false;

class ExchangePage extends StatefulWidget {
  final Product received_product;

  const ExchangePage({required this.received_product});
  @override
  State<ExchangePage> createState() {
    receivedProduct = received_product;
    return _ExchangePageState();
  }
}

class _ExchangePageState extends State<ExchangePage> {
  @override
  Widget build(BuildContext context) {
    getProductOwner();
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 244, 237, 249),
        body: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: [
                      FutureBuilder(
                        future: getProductOwner(),
                        builder: (context, AsyncSnapshot<String> snapshot) {
                          late String data;
                          if (snapshot.data == null)
                            data = " ";
                          else
                            data = snapshot.data!;

                          return Text(data,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue));
                        },
                      ),
                      ClipRRect(
                          borderRadius: BorderRadius.all(Radius.zero),
                          child: Image(
                            image:
                                NetworkImage(receivedProduct.imgLinksURLs[0]),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )),
                      Container(
                          width: 100,
                          child: Text("product name",
                              textAlign: TextAlign.center, style: header)),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 25),
                      child: SvgPicture.asset(
                          'lib/assets/images/exchange_icon.svg',
                          width: 75,
                          height: 75,
                          color: Colors.blue)),
                  Column(
                    children: [
                      Text(User_.displayName,
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                              color: Colors.blue)),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SelectGivenProductPage()))
                                .then((value) {
                              setState(() {
                                if (value != null) {
                                  Isselected = true;
                                  given_product = value;
                                }
                              });
                            });
                          },
                          child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.zero),
                              child: Isselected
                                  ? Image(
                                      image: NetworkImage(
                                          given_product.imgLinksURLs[0]),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover)
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      child: Text(
                                        "Click to select product to exchange",
                                        textAlign: TextAlign.justify,
                                      ),
                                    ))),
                      Container(
                          width: 100,
                          child: Text("product name",
                              textAlign: TextAlign.center, style: header))
                    ],
                  )
                ],
              ),
              Text("Kıyas", style: header),
              SizedBox(height: 20),
              Padding(
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Kategori",
                                style: header,
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(receivedProduct.category,
                                            style: body),
                                        Text("-", style: body)
                                      ])),
                              Text(
                                "Kullanılmışlık Durumu",
                                style: header,
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(statusList[receivedProduct.status],
                                            style: body),
                                        Text(
                                            Isselected
                                                ? given_product.status
                                                    .toString()
                                                : "-",
                                            style: body)
                                      ])),
                              Text(
                                "Kaçıncı Sahibi",
                                style: header,
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            receivedProduct.exchangedTimes
                                                .toString(),
                                            style: body),
                                        Text("-", style: body)
                                      ]))
                            ],
                          )))),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    "TAKAS TEKLİF ET",
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'Montserrat'),
                  ))
            ])));
  }
}

Future<String> getProductOwner() async {
  String ownerName = "";
  DocumentSnapshot ref = await FirebaseFirestore.instance
      .collection("users")
      .doc(receivedProduct.email)
      .get();
  var doc = ref.data();
  String extractMap(var doc) {
    return doc["displayName"];
  }

  print(User_.displayName);
  return extractMap(doc);
}

void StartExchangeRequest() {}
