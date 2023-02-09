import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/product.dart';
import 'package:swap_toys/pages/inspectProduct_page.dart';

import 'createProduct_page.dart';

//profil
late String userInspectorMail;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: isUserProfile
            ? null
            : AppBar(
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context)),
                title: Text('Profil'),
              ),
        body: AccountPage(userMail),
        floatingActionButton: Visibility(
            visible: isUserProfile,
            child: FloatingActionButton(
                backgroundColor: Colors.blue,
                child: const Icon(Icons.add),
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

  Future<String> readDisplayName(String mail) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(mail);

    late var data;
    await docRef.get().then((DocumentSnapshot doc) {
      data = doc.data() as Map<String, dynamic>;
    });
    return data['displayName'];
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
          child: Row(
            children: [
              const CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                      "https://pbs.twimg.com/profile_images/1376481584422002689/woHOrg1__400x400.jpg")),
              const SizedBox(width: 18),
              Expanded(
                child: FutureBuilder<String>(
                  future: readDisplayName(userMail),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: TextStyle(fontSize: 18),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    return CircularProgressIndicator();
                  },
                ),
              )
            ],
          )),
      Expanded(
        child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: StreamBuilder<List<Product>>(
                stream: readProducts(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Bir şeyler yanlış gitti! ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    User_.userProducts = snapshot.data!;
                    return GridView.count(
                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      children: List.generate(snapshot.data!.length, (index) {
                        return ProductGrid(
                            snapshot.data![index], index.toString());
                      }),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                })),
      )
    ]);
  }

  Stream<List<Product>> readProducts() => FirebaseFirestore.instance
      .collection("users")
      .doc(userMail)
      .collection("products")
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList());
}

class ProductGrid extends StatelessWidget {
  Product product;
  String id;
  ProductGrid(this.product, this.id, {super.key});
  @override
  Widget build(BuildContext context) {
    product.id = id;
    return InkWell(
      child: Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: NetworkImage(product.imgLinksURLs[0]),
                fit: BoxFit.fitWidth,
                alignment: FractionalOffset.topCenter)),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => InspectProductPage(
                  product_: product, email_: userInspectorMail)),
        );
      },
    );
  }
}
