import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/pages/profile_page.dart';
import 'package:swap_toys/models/product.dart';
import 'dart:async';
import '../models/user.dart';
import 'inspectProduct_page.dart';
import 'styles.dart';

late Timer timer;
List<Product> allProducts = [];
List<user> allUsers = [];

int productCountToShow = 5;
int userCountToShow = 5;

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    Timer.run(() async {
      allProducts = await getAll();
    });

    timer = Timer.periodic(const Duration(seconds: 60), (Timer t) async {
      allProducts = await getAll();
      if (currentPageIndex != 1) t.cancel();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ara",
          style: appBar,
        ),
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
      body: const Center(
          child: SizedBox(
        width: 250,
        child: Text(
          "Arama yapmak için arama butonuna tıklayınız.",
          style: header,
          textAlign: TextAlign.center,
        ),
      )),
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
    FocusScope.of(context).unfocus();
    return buildSuggestions(context);
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
    for (var toy in allProducts) {
      if (toy.isAboutMe(query)) matcheds.add(toy);
    }
    return matcheds;
  }

  List<user> getMatchedUsers(String query) {
    List<user> matcheds = [];

    for (var user in allUsers) {
      if (user.isAboutMe(query)) matcheds.add(user);
    }
    return matcheds;
  }

  Widget toySuggestionsWidget(List<Product> productSuggestions) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: productSuggestions.length + 1,
        itemBuilder: ((context, index) {
          if (index == 0)
            return ListTile(
              title: Text(
                "Oyuncaklar",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            );
          else {
            final suggestion = productSuggestions[index - 1];
            return ListTile(
              title: Text(suggestion.title),
              onTap: () {
                _SearchPageState();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          InspectProductPage(product_: suggestion)),
                ).then((value) async {
                  if (suggestion.email == User_.email) return;

                  final docRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(User_.email);

                  int newInterest = await docRef.get().then((doc) {
                    try {
                      final data = doc.data()!["interests"];
                      try {
                        return data[suggestion.category]! + 1;
                      } catch (e) {
                        return 1;
                      }
                    } catch (e) {
                      return 1;
                    }
                  });
                  await docRef.set({
                    "interests": {suggestion.category: newInterest}
                  }, SetOptions(merge: true));
                });
                query = suggestion.title;
              },
            );
          }
        }));
  }

  Widget userSuggestionWidget(List<user> userSuggestions) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: userSuggestions.length + 1,
        itemBuilder: ((context, index) {
          if (index == 0)
            return ListTile(
              title: Text(
                "Kullanıcılar",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            );
          else {
            final suggestion = userSuggestions[index - 1];
            return ListTile(
              title: Text(suggestion.displayName),
              onTap: () {
                query = suggestion.displayName;
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(suggestion.email)))
                    .then((value) => ProfilePage(User_.email));
              },
            );
          }
        }));
  }

  Widget buildSuggestionsSuccess(
      List<Product> productSuggestions, List<user> userSuggestions) {
    return DefaultTabController(
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: TabBar(tabs: [
              Tab(
                  icon: Icon(
                Icons.toys_rounded,
                color: Colors.blueAccent,
              )),
              Tab(
                  icon: Icon(
                Icons.supervisor_account_rounded,
                color: Colors.blueAccent,
              )),
            ]),
          ),
        ),
        body: TabBarView(children: [
          toySuggestionsWidget(productSuggestions),
          userSuggestionWidget(userSuggestions)
        ]),
      ),
      length: 2,
    );
  }
}

Future<List<Product>> getAll() async {
  allUsers = [];

  QuerySnapshot users =
      await FirebaseFirestore.instance.collection("users").get();
  List<Product> productPool = [];
  for (QueryDocumentSnapshot user_ in users.docs) {
    if (user_["email"] == User_.email) continue;
    user usr = user(user_["displayName"], user_["email"]);
    allUsers.add(usr);
    productPool.addAll(await usr.MyProducts(user_));
  }

  return productPool;
}
