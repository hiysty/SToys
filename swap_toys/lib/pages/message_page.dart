import 'package:flutter/material.dart';
import 'package:swap_toys/pages/styles.dart';

class MessagePage extends StatefulWidget {
  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColorDefault,
      appBar: AppBar(title: Text('Mesaj')),
      body: ListView.builder(
          padding: EdgeInsets.only(top: 10),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Container(
                    alignment: Alignment.center,
                    height: 80,
                    child: ListTile(
                      title: Text('Username', style: header),
                      subtitle: Text('Messaage', style: body),
                      tileColor: Colors.white,
                      leading: Container(
                        child: Icon(Icons.account_box, size: 40),
                        height: double.infinity,
                      ),
                    )));
          }),
    );
  }
}
