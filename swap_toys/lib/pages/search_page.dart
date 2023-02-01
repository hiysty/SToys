import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/pages/profile_page.dart';
import 'package:swap_toys/models/product.dart';
import 'dart:async';
import '../models/user.dart';

late Timer timer;
List<Product> allProducts = [];
List<user> allUsers = [];

int productCountToShow = 5;
int userCountToShow = 5;

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer.run(() async {
      allProducts = await getAll();
    });

    timer = Timer.periodic(Duration(seconds: 60), (Timer t) async {
      allProducts = await getAll();
      if (currentPageIndex != 1) t.cancel();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ürün Ara"),
        actions: [
          IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                final results = showSearch(
                    context: context, delegate: CustomSearchDelegate());
              },
              icon: const Icon(Icons.search)),
        ],
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
            showSuggestions(context);
          }
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text("yok");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Product> productSuggestions =
        query.isEmpty ? [] : getMatchedProducts(query);
    final List<user> userSuggestions =
        query.isEmpty ? [] : getMatchedUsers(query);
    return buildSuggestionsSuccess(productSuggestions, userSuggestions);
  }

  List<Product> getMatchedProducts(String query) {
    List<Product> matcheds = [];
    print("hm");
    for (var toy in allProducts) {
      if (toy.isAboutMe(query)) matcheds.add(toy);
    }
    return matcheds;
  }

  List<user> getMatchedUsers(String query) {
    List<user> matcheds = [];
    print("a");
    for (var user in allUsers) {
      print(user.displayName);
      if (user.isAboutMe(query)) matcheds.add(user);
    }
    return matcheds;
  }

  Widget buildSuggestionsSuccess(
      List<Product> productSuggestions, List<user> userSuggestions) {
    int productCount = productCountToShow < productSuggestions.length
        ? productCountToShow
        : productSuggestions.length;
    int userCount = userCountToShow < userSuggestions.length
        ? userCountToShow
        : userSuggestions.length;

    int totalCount = productCount + userCount + 4;
    return Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: totalCount,
            itemBuilder: ((context, index) {
              if (index == 0)
                return ListTile(
                  title: Text(
                    "Oyuncaklar",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                );
              else if (0 < index && index <= productCount) {
                final suggestion = productSuggestions[index - 1];
                return ListTile(
                  title: Text(suggestion.title),
                  onTap: () {
                    query = suggestion.title;
                  },
                );
              } else if (index == productCount + 1)
                return ListTile(
                  leading: Icon(Icons.add),
                  onTap: () {
                    productCountToShow += 5;
                    showSuggestions(context);
                  },
                );
              else if (index == productCount + 2)
                return ListTile(
                  title: Text(
                    "Kullanıcılar",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                );
              else if (index > productCount + 2 &&
                  index <= productCount + 2 + userCount) {
                final suggestion = userSuggestions[index - productCount - 3];
                return ListTile(
                  title: Text(suggestion.displayName),
                  onTap: () {
                    query = suggestion.displayName;
                  },
                );
              } else {
                return ListTile(
                  leading: Icon(Icons.add),
                  onTap: () {
                    userCountToShow += 5;
                    showSuggestions(context);
                  },
                );
              }
            })));
  }
}

Future<List<Product>> getAll() async {
  allUsers = [];

  QuerySnapshot users =
      await FirebaseFirestore.instance.collection("users").get();
  List<Product> productPool = [];
  for (var user_ in users.docs) {
    user usr = user(user_["displayName"], user_["email"]);
    print(usr.displayName);
    allUsers.add(usr);
    productPool.addAll(await usr.MyProducts(user_));
  }

  return productPool;
}
