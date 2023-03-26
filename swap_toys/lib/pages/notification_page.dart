import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/notification.dart';
import 'package:swap_toys/models/product.dart';
import 'package:swap_toys/pages/error_page.dart';
import 'package:swap_toys/pages/styles.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Future<List<ExchangeNotification>> getIncomingExchangeOffers() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final collection = firestore
        .collection('users')
        .doc(User_.email)
        .collection('notifications');

    List<ExchangeNotification> data = [];

    List<QueryDocumentSnapshot<Map<String, dynamic>>> snapshots =
        await collection.get().then((value) => value.docs);

    for (var doc in snapshots) {
      data.add(ExchangeNotification(
          id: doc.id,
          recievedProduct: Product.fromJsonWithoutId(doc["recievedProduct"]),
          givenProduct: Product.fromJsonWithoutId(doc["givenProduct"])));
    }
    return data;
  }

  Future<List<ExchangeNotification>> getOutgoingExchangeOffers() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final collection =
        firestore.collection('users').doc(User_.email).collection('offers');

    List<ExchangeNotification> data = [];

    List<QueryDocumentSnapshot<Map<String, dynamic>>> snapshots =
        await collection.get().then((value) => value.docs);

    for (var doc in snapshots) {
      data.add(ExchangeNotification(
          id: doc.id,
          recievedProduct: Product.fromJsonWithoutId(doc["recievedProduct"]),
          givenProduct: Product.fromJsonWithoutId(doc["givenProduct"])));
    }

    return data;
  }

  FutureOr acceptNotification(ExchangeNotification notification) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                  "Takas teklifini kabul etmek istediğinize emin misiniz?"),
              actions: [
                IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () async {
                      await acceptExchange(notification);
                      Navigator.of(context).pop();
                      getIncomingExchangeOffers();
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 50,
                    )),
                const SizedBox(width: 7),
                IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 50,
                    ))
              ],
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: const EdgeInsets.only(bottom: 25),
            ));

    getIncomingExchangeOffers();
    setState(() {});
  }

  FutureOr cancelNotification(ExchangeNotification notification,
      {required bool isOutgoing}) async {
    if (isOutgoing) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(notification.givenProduct.email)
          .collection('offers')
          .doc(notification.id.toString())
          .delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(notification.recievedProduct.email)
          .collection('notifications')
          .doc(notification.id.toString())
          .delete();
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(notification.recievedProduct.email)
          .collection('offers')
          .doc(notification.id.toString())
          .delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(notification.givenProduct.email)
          .collection('notifications')
          .doc(notification.id.toString())
          .delete();
    }

    getIncomingExchangeOffers();
    getOutgoingExchangeOffers();
    setState(() {});
  }

  Future acceptExchange(ExchangeNotification notification) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(notification.recievedProduct.email)
        .collection('offers')
        .doc(notification.id.toString())
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(notification.givenProduct.email)
        .collection('notifications')
        .doc(notification.id.toString())
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(notification.recievedProduct.email)
        .collection('products')
        .doc(notification.recievedProduct.id)
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(notification.givenProduct.email)
        .collection('products')
        .doc(notification.givenProduct.id)
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(notification.recievedProduct.email)
        .collection('products')
        .doc(notification.givenProduct.id)
        .set(notification.givenProduct
            .toJSONExchangeComplete(notification.recievedProduct.email));

    await FirebaseFirestore.instance
        .collection('users')
        .doc(notification.givenProduct.email)
        .collection('products')
        .doc(notification.recievedProduct.id)
        .set(notification.recievedProduct
            .toJSONExchangeComplete(notification.givenProduct.email));

    for (var _notification in await FirebaseFirestore.instance
        .collection('users')
        .doc(notification.givenProduct.email)
        .collection('notifications')
        .get()
        .then((value) => value.docs)) {
      if (_notification.data()["givenProduct"]["id"] ==
          notification.givenProduct.id) {
        _notification.reference.delete();
      }
    }

    for (var _notification in await FirebaseFirestore.instance
        .collection('users')
        .doc(notification.recievedProduct.email)
        .collection('notifications')
        .get()
        .then((value) => value.docs)) {
      if (_notification.data()["recievedProduct"]["id"] ==
          notification.recievedProduct.id) {
        _notification.reference.delete();
      }
    }

    for (var user in await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value) => value.docs)) {
      for (var offer in await FirebaseFirestore.instance
          .collection('users')
          .doc(user.data()["email"])
          .collection('offers')
          .get()
          .then((value) => value.docs)) {
        if (offer.data()["recievedProduct"]["id"] ==
            notification.givenProduct.id) {
          offer.reference.delete();
        }
      }
    }

    for (var user in await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value) => value.docs)) {
      for (var offer in await FirebaseFirestore.instance
          .collection('users')
          .doc(user.data()["email"])
          .collection('notifications')
          .get()
          .then((value) => value.docs)) {
        if (offer.data()["givenProduct"]["id"] ==
            notification.recievedProduct.id) {
          offer.reference.delete();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            backgroundColor: backgroundColorDefault,
            appBar: AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context)),
              title: const Text(
                'Takas Teklifleri',
                style: appBar,
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: "Gelen Teklifler"),
                  Tab(text: "Giden Teklifler"),
                ],
              ),
            ),
            body: TabBarView(children: [
              FutureBuilder<List<ExchangeNotification>>(
                  future: getIncomingExchangeOffers(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) => NotificationTile(
                                recievedProduct:
                                    snapshot.data![index].recievedProduct,
                                givenProduct:
                                    snapshot.data![index].givenProduct,
                                isIncoming: true,
                                callback: () {
                                  cancelNotification(snapshot.data![index],
                                      isOutgoing: false);
                                },
                                acceptCallback: () =>
                                    acceptNotification(snapshot.data![index]),
                              ));
                    } else if (snapshot.hasError) {
                      return ErrorPage(errorCode: snapshot.error.toString());
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
              FutureBuilder<List<ExchangeNotification>>(
                future: getOutgoingExchangeOffers(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) => NotificationTile(
                              recievedProduct:
                                  snapshot.data![index].recievedProduct,
                              givenProduct: snapshot.data![index].givenProduct,
                              isIncoming: false,
                              callback: () => cancelNotification(
                                  snapshot.data![index],
                                  isOutgoing: true),
                            ));
                  } else if (snapshot.hasError) {
                    return ErrorPage(errorCode: snapshot.error.toString());
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              )
            ])));
  }
}

class NotificationTile extends StatefulWidget {
  Product recievedProduct;
  Product givenProduct;
  bool isIncoming;
  VoidCallback? callback;
  VoidCallback? acceptCallback;
  NotificationTile(
      {required this.recievedProduct,
      required this.givenProduct,
      required this.isIncoming,
      this.callback,
      this.acceptCallback,
      super.key});

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  @override
  Widget build(BuildContext context) => Container(
      color: Colors.white,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
          child: Column(
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(children: [
                      ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          child: Image.network(
                            widget.recievedProduct.imgLinksURLs[0],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )),
                      SizedBox(
                          width: 100,
                          child: Text(widget.recievedProduct.title,
                              textAlign: TextAlign.center, style: header))
                    ]),
                    Padding(
                        padding: const EdgeInsets.only(top: 12.5),
                        child: SvgPicture.asset(
                          'lib/assets/images/exchange_icon.svg',
                          width: 75,
                          height: 75,
                          color: Colors.blue,
                        )),
                    Column(children: [
                      ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          child: Image.network(
                            widget.givenProduct.imgLinksURLs[0],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )),
                      SizedBox(
                          width: 100,
                          child: Text(widget.givenProduct.title,
                              textAlign: TextAlign.center, style: header))
                    ]),
                  ]),
              widget.isIncoming
                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      IconButton(
                          onPressed: widget.acceptCallback,
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 50,
                          )),
                      const SizedBox(
                        width: 50,
                      ),
                      IconButton(
                          onPressed: widget.callback,
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 50,
                          ))
                    ])
                  : ElevatedButton(
                      onPressed: widget.callback,
                      child: const Text('Teklifi İptal Et'))
            ],
          )));
}
