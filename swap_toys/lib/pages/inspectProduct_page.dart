import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/product.dart';
import 'package:swap_toys/models/user.dart';
import 'package:swap_toys/pages/createProduct_page.dart';
import 'package:swap_toys/pages/profile_page.dart';
import 'package:swap_toys/pages/updateProduct_page.dart';

class inspectProductPage extends StatefulWidget {
  const inspectProductPage(
      {super.key, required this.product, required this.email});
  final Product product;
  final String email;

  @override
  inspectProductPageState createState() =>
      inspectProductPageState(product, email);
}

class inspectProductPageState extends State<inspectProductPage> {
  inspectProductPageState(this.product_, this.email_);
  Product product_;
  String email_;
  List<Widget> images = [];
  @override
  Widget build(BuildContext context) {
    getImagesViaUrl(product_.imgLinksURLs).then((value) {
      setState(() {
        images = value;
      });
    });
    print(images.toString() + "that is value");
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
            Text("Başlık: " + product_.title,
                textAlign: TextAlign.left, style: TextStyle(fontSize: 20)),
            SizedBox(
              height: 10,
            ),
            Text("Açıklama: " + product_.description,
                textAlign: TextAlign.left, style: TextStyle(fontSize: 20)),
            SizedBox(
              height: 10,
            ),
            Text("Durum: " + statusList[product_.status],
                textAlign: TextAlign.left, style: TextStyle(fontSize: 20)),
            SizedBox(
              height: 20,
            ),
            Visibility(
                visible: email_ == User_.email,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdateProduct(product_)),
                      );
                    },
                    child: Text(
                      "Ürünü Güncelle",
                      style: TextStyle(fontSize: 20),
                    ))),
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
