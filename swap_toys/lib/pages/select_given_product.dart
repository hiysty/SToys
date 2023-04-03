import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/product.dart';
import 'package:swap_toys/pages/error_page.dart';
import 'package:swap_toys/pages/styles.dart';

Product? selectedProduct;
late Product mostEquivalentProduct;

class SelectGivenProductPage extends StatefulWidget {
  const SelectGivenProductPage({super.key});

  @override
  State<StatefulWidget> createState() => _SelectGivenProductPageState();
}

class _SelectGivenProductPageState extends State<SelectGivenProductPage> {
  final List<String> statusList = <String>[
    'Oldukça Eski',
    'Eski',
    'Ortalama',
    'Yeni',
    'Kutusu Açılmamış'
  ];

  Future<List<Product>> getProducts() async {
    List<Product> data = [];

    for (var doc in await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('products')
        .get()
        .then((value) => value.docs)) {
      data.add(Product.fromJson(doc));
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    mostEquivalentProduct = calcMostEquivalentProductOfMines();
    return Scaffold(
        appBar: AppBar(title: const Text("Ürün Seç", style: appBar)),
        backgroundColor: backgroundColorDefault,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 7, 15, 7),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedProduct != null
                                  ? selectedProduct!.title
                                  : "—",
                              style: header,
                            ),
                            Text(
                              User_.displayName,
                              style: body,
                            )
                          ]))),
              selectedProduct != null
                  ? Image(image: NetworkImage(selectedProduct!.imgLinksURLs[0]))
                  : const SizedBox(
                      height: 300,
                      child: Center(
                        child: Text("Takas edilecek ürünü seçiniz"),
                      )),
              SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                            child: Container(
                                color: Colors.white,
                                width:
                                    MediaQuery.of(context).size.width / 3 - 10,
                                height: 100,
                                child: Center(
                                    child: Text(
                                  selectedProduct != null
                                      ? "Durum:\n${statusList[selectedProduct!.status]}"
                                      : "Durum:\n—",
                                  style: header,
                                  textAlign: TextAlign.center,
                                )))),
                        Container(
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width / 3 - 10,
                            height: 100,
                            child: Center(
                              child: Text(
                                selectedProduct != null
                                    ? "Kategori:\n${selectedProduct!.category}"
                                    : "Kategori:\n—",
                                style: header,
                                textAlign: TextAlign.center,
                              ),
                            )),
                        Container(
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width / 3 - 10,
                          height: 100,
                          child: Center(
                              child: Text(
                            selectedProduct != null
                                ? "Sahibi:\n${selectedProduct!.exchangedTimes}."
                                : "Sahibi:\n—",
                            style: header,
                            textAlign: TextAlign.center,
                          )),
                        ),
                      ],
                    ),
                  )),
              const Text('Ürünleriniz', style: header),
              const SizedBox(height: 10),
              FutureBuilder(
                  future: getProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        children: List.generate(
                            snapshot.data!.length,
                            (index) => ProductGrid(
                                snapshot.data![index], index.toString(), this)),
                      );
                    } else if (snapshot.hasError) {
                      return ErrorPage(errorCode: snapshot.error.toString());
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, selectedProduct);
                  },
                  child: const Text(
                    "SEÇ",
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'Montserrat'),
                  ))
            ],
          ),
        ));
  }

  Product calcMostEquivalentProductOfMines() {
    return User_.userProducts[0];
  }

  void setSelectedProduct(Product? selected) {
    setState(() {
      selectedProduct = selected;
    });
  }
}

class ProductGrid extends StatelessWidget {
  Product product;
  String id;
  _SelectGivenProductPageState state;

  ProductGrid(this.product, this.id, this.state, {super.key});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: product == mostEquivalentProduct
          ? Stack(
              children: [
                Container(
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                          image: NetworkImage(product.imgLinksURLs[0]),
                          fit: BoxFit.fitWidth,
                          alignment: FractionalOffset.topCenter)),
                ),
                Positioned(
                  top: 10,
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.black54,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Suggested',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(255, 255, 187, 0)),
                    ),
                  ),
                )
              ],
            )
          : Container(
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                      image: NetworkImage(product.imgLinksURLs[0]),
                      fit: BoxFit.fitWidth,
                      alignment: FractionalOffset.topCenter)),
            ),
      onTap: () {
        if (selectedProduct != product) {
          state.setSelectedProduct(product);
        } else {
          state.setSelectedProduct(null);
        }
      },
    );
  }
}
