import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/pages/styles.dart';
import 'package:grouped_list/grouped_list.dart';

class ChatPage extends StatefulWidget {
  final String id;

  const ChatPage({Key? key, required this.id}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Future<String> getUsername() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore
        .collection('users')
        .doc(widget.id)
        .get()
        .then((value) => value['displayName']);
  }

  Stream<List<Message>>? getMessages() {
    final messagesController = StreamController<List<Message>>();
    final transformer = StreamTransformer<
            DocumentSnapshot<Map<String, dynamic>>, List<Message>>.fromHandlers(
        handleData: (DocumentSnapshot<Map<String, dynamic>> snapshot,
            EventSink<List<Message>> sink) {
      final messages = <Message>[];
      if (snapshot.exists) {
        final data = snapshot.data()!;
        data.forEach((key, value) {
          final message = Message.fromJSON(value);
          messages.add(message);
        });
      }
      messages.sort((a, b) => a.date.compareTo(b.date));
      print(messages);
      sink.add(messages);
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(User_.email)
        .collection('chats')
        .doc(widget.id)
        .snapshots()
        .transform(transformer)
        .pipe(messagesController);

    return messagesController.stream;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return FutureBuilder<String>(
        future: getUsername(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                  title: Text(
                snapshot.data!,
                style: appBar,
              )),
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
                                      DateFormat.yMMMd().format(message.date),
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
                                  child: Card(
                                    elevation: 8,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        message.text,
                                      ),
                                    ),
                                  ))),
                            );
                          } else if (stream.hasError) {
                            return const Center(
                                child: Text(
                                    'Hay aksi, bir şeyler yanlış gitti...'));
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        })),
                Container(
                    color: Colors.grey.shade300,
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'Mesajınız...'),
                      onSubmitted: (text) async {
                        final message = Message(text, DateTime.now(), true);
                        final document = FirebaseFirestore.instance
                            .collection('users')
                            .doc(User_.email)
                            .collection('chats')
                            .doc(widget.id);
                        String name = await document.get().then(
                            (value) => (value.data()!.length + 1).toString());
                        Map<String, dynamic> data =
                            await document.get().then((value) => value.data()!);
                        data.addAll({name: message.toJSON()});
                        await document.set(data);
                        controller.text = "";
                      },
                    ))
              ]),
            );
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

  Message(this.text, this.date, this.isSentByMe);

  Message.fromJSON(var message) {
    text = message["message"];
    date = (message["date_time"] as Timestamp).toDate();
    if (message["user"] == User_.email.toString()) {
      isSentByMe = true;
    } else {
      isSentByMe = false;
    }
  }

  Map<String, dynamic> toJSON() {
    final json = {"message": text, "date_time": date, "user": User_.email};

    return json;
  }
}
