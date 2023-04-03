import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/pages/chat_page.dart';
import 'package:swap_toys/pages/error_page.dart';
import 'package:swap_toys/pages/styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessagePage extends StatefulWidget {
  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  Stream<List<MessageItem>> fetchData() {
    final storage = FirebaseStorage.instance;
    final firestore = FirebaseFirestore.instance;

    Stream<List<MessageItem>> data = firestore
        .collection('users')
        .doc(User_.email)
        .collection('chats')
        .snapshots()
        .asyncMap((collection) async {
      List<MessageItem> items = [];
      for (var doc in collection.docs) {
        List<MapEntry<String, dynamic>> entries = doc.data().entries.toList();
        entries = entries.reversed.toList();
        final temp = entries.toList();
        for (var entry in temp) {
          if (entry.value.runtimeType == bool) entries.remove(entry);
        }
        bool isLink;
        try {
          isLink = doc.data()[(entries.length).toString()]["isLink"];
        } catch (e) {
          isLink = false;
        }

        String lastMessage;

        print(entries);

        try {
          lastMessage = doc.data()[(entries.length).toString()]["message"];
        } catch (e) {
          lastMessage = " ";
        }

        MessageItem item = MessageItem(
            doc.id,
            await firestore
                .collection('users')
                .doc(doc.id)
                .get()
                .then((value) => value.get("displayName")),
            !isLink
                ? lastMessage
                : "Bir ürün paylaştı: ${await firestore.collection('users').doc(doc.data()[(entries.length).toString()]["product_user"]).collection('products').doc(doc.data()[(entries.length).toString()]["message"]).get().then((value) => value.data()!['title'])}",
            await storage
                .ref()
                .child('profilePictures/${doc.id}')
                .getDownloadURL());
        items.add(item);
      }
      return items;
    });

    return data;
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
                if (snapshot.data!.isEmpty) {
                  return const Center(
                      child:
                          Text("Henüz hiçbir mesajınız yok.", style: header));
                } else {
                  return ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return MessageItem(
                          snapshot.data!.elementAt(index).id,
                          snapshot.data!.elementAt(index).username,
                          snapshot.data!.elementAt(index).lastMessage,
                          snapshot.data!.elementAt(index).profilePictureURL,
                        );
                      });
                }
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

  MessageItem(this.id, this.username, this.lastMessage, this.profilePictureURL);

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
                    .update({"isBlocked": !isBlocked})),
            PopupMenuItem(
                onTap: () async => await FirebaseFirestore.instance
                    .collection('users')
                    .doc(User_.email)
                    .collection('chats')
                    .doc(widget.id)
                    .delete(),
                child: const Text('Mesajları sil'))
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
                          builder: (context) => ChatPage(email: widget.id)));
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
                        backgroundColor: Colors.transparent,
                        foregroundImage: CachedNetworkImageProvider(
                          widget.profilePictureURL,
                        )))),
          ),
        ));
  }
}
