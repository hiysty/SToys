import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/product.dart';

import 'createProduct_page.dart';

//profil

class ProfilePage extends StatefulWidget {
  static final user = FirebaseAuth.instance.currentUser!;

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AccountPage(),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CreateProduct();
              }));
            }));
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    print(User_.productCount);
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
                  child: Text(
                FirebaseAuth.instance.currentUser!.email!,
                style: const TextStyle(fontSize: 18),
              ))
            ],
          )),
      Expanded(
        child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: GridView.count(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              shrinkWrap: true,
              crossAxisCount: 3,
              children: List.generate(25, (index) => const ProductGrid()),
            )),
      )
    ]);
  }
}
