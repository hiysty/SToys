import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/product.dart';
import 'package:swap_toys/models/user.dart';
import 'package:swap_toys/pages/createProduct_page.dart';
import 'package:swap_toys/pages/profile_page.dart';
import 'package:swap_toys/pages/updateProduct_page.dart';

late Product product;
late String email;

class inspectProductPage extends StatefulWidget {
  const inspectProductPage(
      {super.key, required this.product_, required this.email_});
  final Product product_;
  final String email_;

  @override
  inspectProductPageState createState() {
    product = product_;
    email = email_;
    return inspectProductPageState();
  }
}

class inspectProductPageState extends State<inspectProductPage> {
  inspectProductPageState();
  List<Widget> images = [];
  @override
  Widget build(BuildContext context) {
    getImagesViaUrl(product.imgLinksURLs).then((value) {
      setState(() {
        images = value;
      });
    });
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Ürünü İncele"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: PageView(
                children: images,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text("Başlık: " + product.title,
                textAlign: TextAlign.left, style: TextStyle(fontSize: 20)),
            SizedBox(
              height: 10,
            ),
            Text("Açıklama: " + product.description,
                textAlign: TextAlign.left, style: TextStyle(fontSize: 20)),
            SizedBox(
              height: 10,
            ),
            Text("Durum: " + statusList[product.status],
                textAlign: TextAlign.left, style: TextStyle(fontSize: 20)),
            SizedBox(
              height: 20,
            ),
            Update_offer_check(context)
          ],
        ),
      ),
    );
  }
}

Future<List<Widget>> getImagesViaUrl(List<String> UrlList) async {
  List<Widget> ImageWidgets = [];

  for (String url in UrlList) {
    Widget img = await Image(
      image: NetworkImage(url),
      fit: BoxFit.fitHeight,
    );
    ImageWidgets.add(img);
  }

  return ImageWidgets;
}

Widget Update_offer_check(BuildContext context) {
  Widget BTN;
  if (email == User_.email) {
    BTN = ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UpdateProduct(product)),
          );
        },
        child: Text(
          "Ürünü Güncelle",
          style: TextStyle(fontSize: 20),
        ));
  } else {
    BTN = ElevatedButton(
        onPressed: () {},
        child: Text(
          "Takas teklif et!",
          style: TextStyle(fontSize: 20),
        ));
  }

  return BTN;
}
