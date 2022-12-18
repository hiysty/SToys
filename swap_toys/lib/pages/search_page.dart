import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/pages/profile_page.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ürün Ara"),
        actions: [
          IconButton(
              onPressed: () {
                final results = showSearch(
                    context: context, delegate: CustomSearchDelegate());
              },
              icon: const Icon(Icons.search)),
        ],
      ),
      body: ElevatedButton.icon(
        onPressed: () => FirebaseAuth.instance.signOut(),
        label: const Text(
          "Sign Out",
        ),
        icon: const Icon(Icons.exit_to_app),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  List<String> searchTerms = ['hiysty', 'god', 'gamer'];

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
    return Text("Rers");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? [""]
        : searchTerms.where((element) {
            final elementLower = element.toLowerCase();
            final queryLower = query.toLowerCase();

            return elementLower.startsWith(queryLower);
          }).toList();

    return buildSuggestionsSuccess(suggestions);
  }

  Widget buildSuggestionsSuccess(List<String> suggestions) => ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: ((context, index) {
        final suggestion = suggestions[index];

        return ListTile(
          title: Text(suggestion),
          onTap: () {
            query = suggestion;

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FutureBuilder<String>(
                        future: fetchData(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ProfilePage(snapshot.data!);
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          return CircularProgressIndicator();
                        })));
          },
        );
      }));

  Future<String> fetchData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('displayName', isEqualTo: query)
        .get();

    final DocumentSnapshot document = snapshot.docs.first;

    return document.id;
  }
}
