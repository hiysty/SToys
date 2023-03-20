import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/product.dart';
import 'package:swap_toys/models/user.dart';
import 'package:swap_toys/pages/chat_page.dart';
import 'package:swap_toys/pages/editProfile_page.dart';
import 'package:swap_toys/pages/error_page.dart';
import 'package:swap_toys/pages/inspectProduct_page.dart';
import 'package:swap_toys/pages/notification_page.dart';
import 'styles.dart';
import 'createProduct_page.dart';

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
          await storage.ref().child('profilePictures/$mail').getDownloadURL()
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
        .set({"isBlocked": isBlocked}, SetOptions(merge: true)).then((value) =>
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatPage(email: userMail))));
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
                    PopupMenuButton(
                        enableFeedback: false,
                        splashRadius: 0.0001,
                        itemBuilder: (context) => <PopupMenuEntry>[
                              const PopupMenuItem(
                                  value: 1, child: Text('Takas Tekliflerim')),
                              const PopupMenuItem(
                                  value: 2, child: Text('Ayarlar')),
                              const PopupMenuItem(
                                  value: 3, child: Text('Çıkış Yap'))
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
                                          builder: (context) => EditProfile()))
                                  .then(onGoBack);
                              break;

                            case 3:
                              FirebaseAuth.instance.signOut();
                              break;
                          }
                        })
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
                    CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 60,
                        foregroundImage:
                            NetworkImage(snapshot.data!['profilePicture']!)),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        snapshot.data!['displayName']!,
                        style: TextStyle(fontSize: 18),
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
                                return ProductGrid(
                                    snapshot.data![index], index);
                              }),
                            );
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        })),
              ),
            ]);
          } else if (snapshot.hasError) {
            return ErrorPage(errorCode: snapshot.error.toString());
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Stream<List<Product>> readProducts() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userMail)
        .collection("products")
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromJson(doc)).toList());
  }
}

class ProductGrid extends StatelessWidget {
  Product product;
  int index;
  ProductGrid(this.product, this.index, {super.key});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
                image: NetworkImage(product.imgLinksURLs[0]),
                fit: BoxFit.fitWidth,
                alignment: FractionalOffset.topCenter)),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => InspectProductPage(product_: product)),
        );
      },
    );
  }
}
