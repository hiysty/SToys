import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/product.dart';
import 'package:swap_toys/models/user.dart';
import 'package:swap_toys/pages/error_page.dart';
import 'package:swap_toys/pages/profile_page.dart';
import 'package:swap_toys/pages/styles.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String email;
  Product? productMsg;
  ChatPage({Key? key, required this.email, this.productMsg}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Future<Map<String, dynamic>> getData() async {
    //get data
    Map<String, dynamic> data = {};

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    data.addAll({
      "username": await firestore
          .collection('users')
          .doc(widget.email)
          .get()
          .then((value) => value['displayName'])
    });

    data.addAll({
      "isBlocked": await firestore
          .collection('users')
          .doc(User_.email)
          .collection('chats')
          .doc(widget.email)
          .get()
          .then((value) => value.data()!["isBlocked"])
    });

    return data;
  }

  Stream<List<Message>>? getMessages() {
    final messagesController = StreamController<List<Message>>();
    final transformer = StreamTransformer<
            DocumentSnapshot<Map<String, dynamic>>, List<Message>>.fromHandlers(
        handleData: (DocumentSnapshot<Map<String, dynamic>> snapshot,
            EventSink<List<Message>> sink) {
      final messages = <Message>[];
      if (snapshot.exists) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(User_.email)
            .collection('chats')
            .doc(widget.email)
            .set({"isRead": true}, SetOptions(merge: true));
        final data = snapshot.data()!;
        data.forEach((key, value) {
          if (value.runtimeType == bool) return;
          final message = Message.fromJSON(value);
          messages.add(message);
        });
      }
      messages.sort((a, b) => a.date.compareTo(b.date));
      sink.add(messages);
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(User_.email)
        .collection('chats')
        .doc(widget.email)
        .snapshots()
        .transform(transformer)
        .pipe(messagesController);

    return messagesController.stream;
  }

  Future sendMessage(String text, TextEditingController controller,
      {bool isLink = false}) async {
    {
      final message = Message(text, DateTime.now(), true, isLink: isLink);
      final recieverMessage =
          Message(text, DateTime.now(), false, isLink: isLink);

      controller.clear();

      final document = FirebaseFirestore.instance
          .collection('users')
          .doc(User_.email)
          .collection('chats')
          .doc(widget.email);

      String name = await document
          .get()
          .then((value) => (value.data()!.length - 1).toString());

      Map<String, dynamic> data =
          await document.get().then((value) => value.data()!);
      data.addAll({name: message.toJSON()});

      await document.set(data);

      final recieverDocument = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.email)
          .collection('chats')
          .doc(User_.email);

      recieverDocument.set({"isRead": false}, SetOptions(merge: true));

      bool isBlocked = false;

      try {
        isBlocked =
            await recieverDocument.get().then((value) => value["isBlocked"]);
      } catch (e) {
        recieverDocument.set({"isBlocked": isBlocked}, SetOptions(merge: true));
      }

      if (isBlocked) return;

      String recieverName = await recieverDocument
          .get()
          .then((value) => (value.data()!.length - 1).toString());

      Map<String, dynamic> recieverData =
          await recieverDocument.get().then((value) => value.data()!);

      recieverData.addAll({recieverName: recieverMessage.toJSON()});

      await recieverDocument.set(recieverData);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    initializeDateFormatting("tr_TR", null);
  }

  Widget productMessage(String productId) {
    return Column();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    if (widget.productMsg != null) {
      sendMessage(widget.productMsg!.id, controller, isLink: true);
      widget.productMsg = null;
    }
    return FutureBuilder<Map<String, dynamic>>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: backgroundColorDefault,
              appBar: AppBar(
                  title: GestureDetector(
                      onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProfilePage(widget.email)))
                          .then((value) => ProfilePage(User_.email)),
                      child: Text(
                        snapshot.data!["username"]!,
                        style: appBar,
                      ))),
              body: Column(children: [
                Expanded(
                    child: StreamBuilder<List<Message>>(
                        stream: getMessages(),
                        builder: (context, stream) {
                          if (stream.hasData) {
                            return GroupedListView<Message, DateTime>(
                              reverse: true,
                              order: GroupedListOrder.DESC,
                              useStickyGroupSeparators: true,
                              floatingHeader: true,
                              padding: const EdgeInsets.all(8),
                              elements: stream.data!,
                              groupBy: (message) => DateTime(message.date.year,
                                  message.date.month, message.date.day),
                              groupHeaderBuilder: (Message message) => SizedBox(
                                height: 40,
                                child: Center(
                                    child: Card(
                                  color: Theme.of(context).primaryColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      DateFormat.yMMMd("tr_TR")
                                          .format(message.date),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                )),
                              ),
                              itemBuilder: ((context, Message message) => Align(
                                  alignment: message.isSentByMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3 *
                                              2),
                                      child: message.isLink
                                          ? Card(
                                              elevation: 8,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                child: Text(
                                                  message.text,
                                                ),
                                              ),
                                            )
                                          : productMessage(message.text)))),
                            );
                          } else if (stream.hasError) {
                            return ErrorPage(
                                errorCode: stream.error.toString());
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        })),
                Container(
                    color: Colors.grey.shade300,
                    child: TextField(
                      maxLength: 300,
                      maxLines: null,
                      enabled: !snapshot.data!["isBlocked"],
                      controller: controller,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(12),
                          hintText: !snapshot.data!["isBlocked"]
                              ? 'Mesajınız...'
                              : "Bu kullanıcıyı engellediniz.",
                          suffixIcon: IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {
                                if (controller.text.isEmpty) return;
                                sendMessage(controller.text, controller);
                              })),
                      onSubmitted: (text) {
                        if (controller.text.isEmpty) return;
                        sendMessage(text, controller);
                      },
                      onEditingComplete: () {},
                    ))
              ]),
            );
          } else if (snapshot.hasError) {
            return ErrorPage(errorCode: snapshot.error.toString());
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

class Message {
  late String text;
  late DateTime date;
  late bool isSentByMe;
  bool isLink = false;

  Message(this.text, this.date, this.isSentByMe, {this.isLink = false});

  Message.fromJSON(var message) {
    text = message["message"];
    date = (message["date_time"] as Timestamp).toDate();
    if (message["user"] == User_.email.toString()) {
      isSentByMe = true;
    } else {
      isSentByMe = false;
    }
    if (message["isLink"] != null) isLink = message["isLink"];
  }

  Map<String, dynamic> toJSON() {
    return {
      "message": text,
      "date_time": date,
      "user": User_.email,
      "isLink": isLink,
    };
  }
}
