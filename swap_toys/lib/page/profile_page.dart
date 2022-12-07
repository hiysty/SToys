import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

//profil

class ProfilePage extends StatelessWidget {
  static final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: EdgeInsets.only(left: 20, top: 20),
            child: Row(
              children: [
                CircleAvatar(
                    radius: 65,
                    backgroundImage: NetworkImage(
                        "https://pbs.twimg.com/profile_images/1376481584422002689/woHOrg1__400x400.jpg")),
                Text(
                  FirebaseAuth.instance.currentUser!.email!,
                  textAlign: TextAlign.right,
                )
              ],
            )));
  }
}
