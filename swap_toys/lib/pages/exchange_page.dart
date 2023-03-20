import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/pages/createProduct_page.dart';
import 'package:swap_toys/pages/select_given_product.dart';
import 'package:swap_toys/pages/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/product.dart';

class ExchangePage extends StatefulWidget {
  final Product recievedProduct;

  const ExchangePage({super.key, required this.recievedProduct});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  Product? givenProduct;

  Future<String> getProductOwner() async => await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.recievedProduct.email)
      .get()
      .then((value) => value['displayName']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 244, 237, 249),
        appBar: AppBar(title: const Text('Takas Teklifi', style: appBar)),
        body: Padding(
            padding: const EdgeInsets.only(top: 20),
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
                          if (snapshot.hasData) {
                            return Text(snapshot.data!, style: usernameStyle);
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                      ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          child: Image(
                            image: NetworkImage(
                                widget.recievedProduct.imgLinksURLs[0]),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )),
                      SizedBox(
                          width: 100,
                          child: Text(widget.recievedProduct.title,
                              textAlign: TextAlign.center, style: header)),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: SvgPicture.asset(
                          'lib/assets/images/exchange_icon.svg',
                          width: 75,
                          height: 75,
                          color: Colors.blue)),
                  Column(
                    children: [
                      Text(User_.displayName, style: usernameStyle),
                      GestureDetector(
                          onTap: () {
                            try {
                              User_.userProducts[0].checkIfNull();
                            } catch (e) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content:
                                    Text('Hiçbir ürününüz bulunmamaktadır.'),
                                backgroundColor: Colors.red,
                              ));
                              return;
                            }
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SelectGivenProductPage()))
                                .then((value) {
                              selectedProduct = null;
                              setState(() {
                                if (value != null) givenProduct = value;
                              });
                            });
                          },
                          child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              child: givenProduct != null
                                  ? Image(
                                      image: NetworkImage(
                                          givenProduct!.imgLinksURLs[0]),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover)
                                  : Container(
                                      alignment: Alignment.center,
                                      width: 100,
                                      height: 100,
                                      child: const Text(
                                        "Ürün seçmek için tıklayınız.",
                                        textAlign: TextAlign.center,
                                      ),
                                    ))),
                      SizedBox(
                          width: 100,
                          child: Text(
                              givenProduct != null ? givenProduct!.title : "—",
                              textAlign: TextAlign.center,
                              style: header))
                    ],
                  )
                ],
              ),
              const Text("Kıyas", style: header),
              Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
                  child: Container(
                      height: 250,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Kategori",
                                style: header,
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(widget.recievedProduct.category,
                                            style: body),
                                        Text(
                                          givenProduct != null
                                              ? givenProduct!.category
                                              : "—",
                                          style: body,
                                        )
                                      ])),
                              const Text(
                                "Kullanılmışlık Durumu",
                                style: header,
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            statusList[
                                                widget.recievedProduct.status],
                                            style: body),
                                        Text(
                                            givenProduct != null
                                                ? givenProduct!.status
                                                    .toString()
                                                : "—",
                                            style: body)
                                      ])),
                              const Text(
                                "Kaçıncı Sahibi",
                                style: header,
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            widget
                                                .recievedProduct.exchangedTimes
                                                .toString(),
                                            style: body),
                                        Text(
                                            givenProduct != null
                                                ? givenProduct!.exchangedTimes
                                                    .toString()
                                                : "—",
                                            style: body)
                                      ]))
                            ],
                          )))),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () => sendExchangeRequest(),
                  child: const Text(
                    "TAKAS TEKLİF ET",
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'Montserrat'),
                  ))
            ])));
  }

  void sendExchangeRequest() async {
    if (givenProduct == null) return;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final collection = firestore
        .collection('users')
        .doc(widget.recievedProduct.email)
        .collection('notifications');

    final reference = collection.doc();

    await reference.set({
      "recievedProduct": givenProduct!.toJSONNotification(),
      "givenProduct": widget.recievedProduct.toJSONNotification(),
    }, SetOptions(merge: true));

    final offerCollection =
        firestore.collection('users').doc(User_.email).collection('offers');

    offerCollection.doc(reference.id).set({
      "recievedProduct": widget.recievedProduct.toJSONNotification(),
      "givenProduct": givenProduct!.toJSONNotification(),
    }, SetOptions(merge: true));

    Navigator.pop(context);
  }
}
