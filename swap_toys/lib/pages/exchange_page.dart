import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/product.dart';

class ExchangePage extends StatelessWidget {
  late Product givenProduct;
  late Product recievedProduct;

  ExchangePage(Product product) {
    recievedProduct = product;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle header = new TextStyle(
        fontSize: 18,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
        color: Color.fromARGB(255, 31, 62, 166));

    TextStyle body = new TextStyle(
        fontSize: 14,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
        color: Colors.blue);

    return Scaffold(
        backgroundColor: Color.fromARGB(255, 244, 237, 249),
        appBar: AppBar(title: const Text("Takas Teklifi")),
        body: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: [
                      Text("username",
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                              color: Colors.blue)),
                      ClipRRect(
                          borderRadius: BorderRadius.all(Radius.zero),
                          child: Image(
                              image: NetworkImage(
                                  "https://images.unsplash.com/photo-1481349518771-20055b2a7b24?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8cmFuZG9tfGVufDB8fDB8fA%3D%3D&w=1000&q=80"),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover)),
                      Container(
                          width: 100,
                          child: Text("product name",
                              textAlign: TextAlign.center, style: header)),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 25),
                      child: SvgPicture.asset(
                          'lib/assets/images/exchange_icon.svg',
                          width: 75,
                          height: 75,
                          color: Colors.blue)),
                  Column(
                    children: [
                      Text("username",
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                              color: Colors.blue)),
                      ClipRRect(
                          borderRadius: BorderRadius.all(Radius.zero),
                          child: Image(
                              image: NetworkImage(
                                  "https://images.unsplash.com/photo-1481349518771-20055b2a7b24?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8cmFuZG9tfGVufDB8fDB8fA%3D%3D&w=1000&q=80"),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover)),
                      Container(
                          width: 100,
                          child: Text("product name",
                              textAlign: TextAlign.center, style: header))
                    ],
                  )
                ],
              ),
              Text("Kıyas", style: header),
              SizedBox(height: 20),
              Padding(
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Kategori",
                                style: header,
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Merhaba", style: body),
                                        Text("Merhaba", style: body)
                                      ])),
                              Text(
                                "Kullanılmışlık Durumu",
                                style: header,
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Merhaba", style: body),
                                        Text("Merhaba", style: body)
                                      ])),
                              Text(
                                "Kaçıncı Sahibi",
                                style: header,
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Merhaba", style: body),
                                        Text("Merhaba", style: body)
                                      ]))
                            ],
                          )))),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    "TAKAS TEKLİF ET",
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'Montserrat'),
                  ))
            ])));
  }
}
