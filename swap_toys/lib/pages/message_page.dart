import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/pages/chat_page.dart';
import 'package:swap_toys/pages/error_page.dart';
import 'package:swap_toys/pages/styles.dart';

class MessagePage extends StatefulWidget {
  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  Stream<List<MessageItem>> fetchData() async* {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    final collection =
        firestore.collection('users').doc(User_.email).collection('chats');

    QuerySnapshot snapshot = await collection.get();

    List<MessageItem> messageList = [];

    for (var i = 0; i < snapshot.docs.length; i++) {
      QueryDocumentSnapshot doc = snapshot.docs[i];

      String username = await firestore
          .collection('users')
          .doc(doc.id)
          .get()
          .then((value) => value["displayName"]);

      int lastMessageCount = await collection
          .doc(doc.id)
          .get()
          .then((value) => value.data()!.length - 1);

      String lastMessage;

      try {
        lastMessage = await collection.doc(doc.id).get().then(
            (DocumentSnapshot value) =>
                value[lastMessageCount.toString()]['message']);
      } catch (e) {
        lastMessage = "";
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

      MessageItem messageItem =
          MessageItem(doc.id, username, lastMessage, profilePictureURL);

      messageList.add(messageItem);
    }

    yield messageList;
  }

  FutureOr deleteMessages(String email) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(User_.email)
        .collection('chats')
        .doc(email)
        .delete();

    fetchData();
    setState(() {});
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
        body: StreamBuilder<List<MessageItem>>(
            stream: fetchData(),
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
                        snapshot.data!.elementAt(index).profilePictureURL,
                        callback: () =>
                            deleteMessages(snapshot.data!.elementAt(index).id),
                      );
                    });
              } else if (snapshot.hasError) {
                return ErrorPage(errorCode: snapshot.error.toString());
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}

class MessageItem extends StatefulWidget {
  late String id;
  late String username;
  late String lastMessage;
  late String profilePictureURL;
  final VoidCallback? callback;

  MessageItem(this.id, this.username, this.lastMessage, this.profilePictureURL,
      {this.callback});

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  final maxLength = 30;

  @override
  Widget build(BuildContext context) {
    showPopupMenu(Offset offset) async {
      double left = offset.dx;
      double top = offset.dy;
      bool isBlocked = await FirebaseFirestore.instance
          .collection('users')
          .doc(User_.email)
          .collection('chats')
          .doc(widget.id)
          .get()
          .then((value) => value['isBlocked']);
      await showMenu(
          context: context,
          position: RelativeRect.fromLTRB(left, top, left + 100, top + 100),
          elevation: 8.0,
          items: <PopupMenuEntry>[
            PopupMenuItem(
                child: isBlocked
                    ? const Text('Engeli kaldır')
                    : const Text('Engelle'),
                onTap: () async => await FirebaseFirestore.instance
                    .collection('users')
                    .doc(User_.email)
                    .collection('chats')
                    .doc(widget.id)
                    .update({'isBlocked': !isBlocked})),
            PopupMenuItem(
                onTap: widget.callback, child: const Text('Mesajları sil'))
          ]);
    }

    if (widget.lastMessage.length > maxLength) {
      widget.lastMessage = "${widget.lastMessage.substring(0, maxLength)}...";
    }

    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          alignment: Alignment.center,
          child: GestureDetector(
            onLongPressStart: (LongPressStartDetails longPressStartDetails) =>
                showPopupMenu(longPressStartDetails.globalPosition),
            child: ListTile(
                onTap: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatPage(email: widget.id)))
                      .then((value) => getLastMessage());
                },
                title: Text(widget.username, style: header),
                subtitle: widget.lastMessage != ""
                    ? Text(widget.lastMessage, style: body)
                    : null,
                tileColor: Colors.white,
                leading: SizedBox(
                    width: 50,
                    height: double.infinity,
                    child: CircleAvatar(
                        backgroundColor: Colors.white,
                        foregroundImage: NetworkImage(
                          widget.profilePictureURL,
                        )))),
          ),
        ));
  }

  Future getLastMessage() async {
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(User_.email)
        .collection('chats');

    String lastMessage;

    int lastMessageCount = await collection
        .doc(widget.id)
        .get()
        .then((value) => value.data()!.length - 1);

    try {
      lastMessage = await collection.doc(widget.id).get().then(
          (DocumentSnapshot value) =>
              value[lastMessageCount.toString()]['message']);
      if (lastMessage.length > maxLength) {
        lastMessage = "${lastMessage.substring(0, maxLength)}...";
      }
    } catch (e) {
      lastMessage = "";
    }

    setState(() {
      widget.lastMessage = lastMessage;
    });
  }
}
