import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => FirebaseAuth.instance.signOut(),
      label: Text(
        "Sign Out",
      ),
      icon: Icon(Icons.exit_to_app),
    );
  }
}
