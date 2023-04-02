import 'dart:async';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/product.dart';
import 'package:swap_toys/models/user.dart';
import 'package:swap_toys/pages/chat_page.dart';
import 'package:swap_toys/pages/editProfile_page.dart';
import 'package:swap_toys/pages/error_page.dart';
import 'package:swap_toys/pages/favourites_page.dart';
import 'package:swap_toys/pages/inspectProduct_page.dart';
import 'package:swap_toys/pages/notification_page.dart';
import 'styles.dart';
import 'package:rxdart/rxdart.dart';
import 'createProduct_page.dart';
import 'package:http/http.dart' as http;

//profil
late String userInspectorMail;

Future<Map<String, String>> fetchData(String mail) async {
  final storage = FirebaseStorage.instance;
  final docRef = FirebaseFirestore.instance.collection('users').doc(mail);

  late Map<String, dynamic> data;
  await docRef.get().then((DocumentSnapshot doc) {
    data = doc.data() as Map<String, dynamic>;
  });
  final displayName = data['displayName'];

  try {
    return {
      "displayName": displayName,
      "profilePicture":
          await docRef.get().then((value) => value.get('profilePicture'))
    };
  } catch (e) {
    return {
      "displayName": displayName,
      "profilePicture": await storage
          .ref()
          .child('profilePictures/default.png')
          .getDownloadURL()
    };
  }
}

class ProfilePage extends StatefulWidget {
  ProfilePage(String mail) {
    userInspectorMail = mail;
  }

  @override
  State<ProfilePage> createState() => _ProfilePageState(userInspectorMail);
}

class _ProfilePageState extends State<ProfilePage> {
  late String userMail;
  bool isUserProfile = false;

  _ProfilePageState(String currentUserMail) {
    userMail = currentUserMail;

    if (userMail == User_.email) {
      isUserProfile = true;
    }
  }

  FutureOr onGoBack(dynamic value) {
    fetchData(User_.email);
    setState(() {});
  }

  startChat() async {
    final firestore = FirebaseFirestore.instance;

    bool isBlocked;

    try {
      isBlocked = await firestore
          .collection('users')
          .doc(User_.email)
          .collection('chats')
          .doc(userMail)
          .get()
          .then((value) => value['isBlocked']);
    } catch (e) {
      isBlocked = false;
    }

    await firestore
        .collection('users')
        .doc(User_.email)
        .collection('chats')
        .doc(userMail)
        .set({"isBlocked": false}, SetOptions(merge: true)).then((value) =>
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatPage(email: userMail))));
  }

  Stream<bool> getBadge() {
    final Stream<bool> offers = FirebaseFirestore.instance
        .collection('users')
        .doc(User_.email)
        .collection('offers')
        .snapshots()
        .map((snapshot) {
      bool hasOffer = false;
      if (snapshot.docs.isNotEmpty) {
        hasOffer = true;
      }
      return hasOffer;
    });

    final Stream<bool> notifications = FirebaseFirestore.instance
        .collection('users')
        .doc(User_.email)
        .collection('notifications')
        .snapshots()
        .map((snapshot) {
      bool hasOffer = false;
      if (snapshot.docs.isNotEmpty) {
        hasOffer = true;
      }
      return hasOffer;
    });

    return Rx.combineLatest2(
        offers, notifications, (offer, notification) => offer || notification);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: isUserProfile
            ? AppBar(
                title: const Text('Profil',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 23)),
                actions: [
                    StreamBuilder<bool>(
                        stream: getBadge(),
                        builder: (context, snapshot) => Badge(
                            position: BadgePosition.topEnd(top: 9, end: 13),
                            showBadge:
                                snapshot.hasData ? snapshot.data! : false,
                            child: PopupMenuButton(
                                enableFeedback: false,
                                splashRadius: 0.0001,
                                itemBuilder: (context) => <PopupMenuEntry>[
                                      const PopupMenuItem(
                                          value: 1,
                                          child: Text('Takas Tekliflerim')),
                                      const PopupMenuItem(
                                          value: 2, child: Text('Favorilerim')),
                                      const PopupMenuItem(
                                          value: 3, child: Text('Ayarlar')),
                                      const PopupMenuItem(
                                          value: 4, child: Text('Çıkış Yap'))
                                    ],
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  switch (value) {
                                    case 1:
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const NotificationPage()));
                                      break;

                                    case 2:
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Favorites()));
                                      break;

                                    case 3:
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditProfile()))
                                          .then(onGoBack);
                                      break;

                                    case 4:
                                      FirebaseAuth.instance.signOut();
                                      break;
                                  }
                                })))
                  ])
            : AppBar(
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context)),
                title: const Text('Profil', style: appBar),
                actions: [
                  IconButton(
                      enableFeedback: false,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: startChat,
                      icon: const Icon(Icons.mail_outline))
                ],
              ),
        body: AccountPage(userMail),
        floatingActionButton: Visibility(
            visible: isUserProfile,
            child: FloatingActionButton.extended(
                backgroundColor: Colors.blue,
                icon: const Icon(Icons.add),
                label: const Text("Ürün Ekle"),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CreateProduct();
                  }));
                })));
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class AccountPage extends StatefulWidget {
  late String userMail;
  AccountPage(email) {
    userMail = email;
  }

  @override
  State<AccountPage> createState() => _AccountPageState(userMail);
}

class _AccountPageState extends State<AccountPage> {
  late String userMail;
  _AccountPageState(email) {
    userMail = email;
  }

  var collectionRef = FirebaseFirestore.instance
      .collection("users")
      .doc(User_.email)
      .collection("products");

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
        future: fetchData(userMail),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                  child: Row(children: [
                    Stack(children: [
                      const CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.transparent,
                          child: Center(
                              child: SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator()))),
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 60,
                        foregroundImage: CachedNetworkImageProvider(
                            snapshot.data!['profilePicture']!),
                      )
                    ]),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        snapshot.data!['displayName']!,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ])),
              Expanded(
                child: ScrollConfiguration(
                    behavior: MyBehavior(),
                    child: StreamBuilder<List<Product>>(
                        stream: readProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return ErrorPage(
                                errorCode: snapshot.error.toString());
                          } else if (snapshot.hasData) {
                            User_.userProducts = snapshot.data!;
                            return GridView.count(
                              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              shrinkWrap: true,
                              crossAxisCount: 3,
                              children:
                                  List.generate(snapshot.data!.length, (index) {
                                return ProductGrid(snapshot.data![index]);
                              }),
                            );
                          } else {
                            return Container();
                          }
                        })),
              ),
            ]);
          } else if (snapshot.hasError) {
            return ErrorPage(errorCode: snapshot.error.toString());
          } else {
            return Container();
          }
        });
  }

  Stream<List<Product>>? readProducts() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userMail)
        .collection('products')
        .orderBy('date_time', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((e) => Product.fromJson(e)).toList());
  }
}

class ProductGrid extends StatelessWidget {
  Product product;
  ProductGrid(this.product, {super.key});

  Future deleteProduct() async {
    final userCollection = FirebaseFirestore.instance.collection('users');
    final userDoc = userCollection.doc(User_.email);

    await userDoc.collection('products').doc(product.id).delete();

    for (var notification in await userDoc
        .collection('notifications')
        .get()
        .then((value) => value.docs)) {
      if (notification.data()["givenProduct"]["id"] == product.id) {
        notification.reference.delete();
      }
    }

    for (var offer in await userDoc
        .collection('offers')
        .get()
        .then((value) => value.docs)) {
      if (offer.data()["givenProduct"]["id"] == product.id) {
        offer.reference.delete();
      }
    }

    for (var user in await userCollection.get().then((value) => value.docs)) {
      for (var notification in await user.reference
          .collection('notifications')
          .get()
          .then((value) => value.docs)) {
        if (product.id == notification.data()["recievedProduct"]["id"]) {
          notification.reference.delete();
        }
      }

      for (var offer in await user.reference
          .collection('offers')
          .get()
          .then((value) => value.docs)) {
        if (product.id == offer.data()["recievedProduct"]["id"]) {
          offer.reference.delete();
        }
      }
    }
  }

  Future manageInterests() async {
    if (product.email == User_.email) return;

    final docRef =
        FirebaseFirestore.instance.collection('users').doc(User_.email);

    int newInterest = await docRef.get().then((doc) {
      try {
        final data = doc.data()!["interests"];
        try {
          return data[product.category]! + 1;
        } catch (e) {
          return 1;
        }
      } catch (e) {
        return 1;
      }
    });
    await docRef.set({
      "interests": {product.category: newInterest}
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: () async {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title:
                        const Text("Ürünü silmek istediğinize emin misiniz?"),
                    actions: [
                      IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: () async {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                            await deleteProduct();
                            Navigator.pop(context);
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
        },
        child: InkWell(
          child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                imageUrl: product.imgLinksURLs[0],
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, progress) =>
                    const Center(child: CircularProgressIndicator()),
              )),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InspectProductPage(product_: product)),
            ).then((value) => manageInterests());
          },
        ));
  }

  Future<ImageProvider> getImage(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    return MemoryImage(bytes);
  }
}
