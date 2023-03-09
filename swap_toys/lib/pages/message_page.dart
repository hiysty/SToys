import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/user.dart';
import 'package:swap_toys/pages/chat_page.dart';
import 'package:swap_toys/pages/styles.dart';

class MessagePage extends StatefulWidget {
  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  Future<List<MessageItem>> fetchData() async {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    final collection =
        firestore.collection('users').doc(User_.email).collection('chats');

    QuerySnapshot snapshot = await collection.get();

    List<MessageItem> messageList = [];

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      MessageItem messageItem = MessageItem(doc.id, "", "", "");

      String username = await firestore
          .collection('users')
          .doc(doc.id)
          .get()
          .then((value) => value["displayName"]);

      messageItem.username = username;

      int lastMessageCount = await collection
          .doc(doc.id)
          .get()
          .then((value) => value.data()!.length);

      try {
        String lastMessage = await collection.doc(doc.id).get().then(
            (DocumentSnapshot value) =>
                value[lastMessageCount.toString()]['message']);
        messageItem.lastMessage = lastMessage;
      } catch (e) {
        messageItem.lastMessage = "";
      }

      String profilePictureURL;

      try {
        profilePictureURL = await storage
            .ref()
            .child('profilePictures/${doc.id}')
            .getDownloadURL();
      } catch (e) {
        profilePictureURL = await storage
            .ref()
            .child('profilePictures/default.png')
            .getDownloadURL();
      }

      messageItem.profilePictureURL = profilePictureURL;

      messageList.add(messageItem);
    }

    return messageList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColorDefault,
        appBar: AppBar(
            title: const Text(
          'Mesaj',
          style: appBar,
        )),
        body: FutureBuilder<List<MessageItem>>(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return MessageItem(
                          snapshot.data!.elementAt(index).id,
                          snapshot.data!.elementAt(index).username,
                          snapshot.data!.elementAt(index).lastMessage,
                          snapshot.data!.elementAt(index).profilePictureURL);
                    });
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}

class MessageItem extends StatelessWidget {
  late String id;
  late String username;
  late String lastMessage;
  late String profilePictureURL;

  MessageItem(this.id, this.username, this.lastMessage, this.profilePictureURL);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
            alignment: Alignment.center,
            height: 80,
            child: ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatPage(
                            id: id,
                          ))),
              title: Text(username, style: header),
              subtitle:
                  lastMessage != "" ? Text(lastMessage, style: body) : null,
              tileColor: Colors.white,
              leading: Container(
                width: 40,
                height: double.infinity,
                child: Image.network(
                  profilePictureURL,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            )));
  }
}
