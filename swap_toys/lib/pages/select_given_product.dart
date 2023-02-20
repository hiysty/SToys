import 'package:flutter/material.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/product.dart';
import 'package:swap_toys/pages/inspectProduct_page.dart';
import 'package:swap_toys/pages/exchange_page.dart';
import 'package:swap_toys/pages/styles.dart';

Product? selectedProduct;
late Product mostEquivalentProduct;

class SelectGivenProductPage extends StatefulWidget {
  const SelectGivenProductPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SelectGivenProductPageState();
  }
}

class _SelectGivenProductPageState extends State<SelectGivenProductPage> {
  @override
  Widget build(BuildContext context) {
    mostEquivalentProduct = calcMostEquivalentProductOfMines(receivedProduct);
    return Scaffold(
      body: Column(
        children: [
          Text(
            "Seçilen Ürün",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          Row(
            children: [
              Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.width,
                  child: (selectedProduct != null)
                      ? Image(
                          image: NetworkImage(selectedProduct!.imgLinksURLs[0]))
                      : Align(
                          child: Text("Takas edilecek ürünü seçiniz"),
                          alignment: Alignment.topCenter,
                        )),
              Text(
                "Ürün bilgileri ve değer puanı",
                textAlign: TextAlign.left,
              )
            ],
          ),
          GridView.count(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            shrinkWrap: true,
            crossAxisCount: 3,
            children: List.generate(User_.userProducts.length, (index) {
              return ProductGrid(
                  User_.userProducts[index], index.toString(), this);
            }),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedProduct);
              },
              child: Text(
                "SEÇ",
                style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
              ))
        ],
      ),
    );
  }

  Product calcMostEquivalentProductOfMines(Product received) {
    return User_.userProducts[0];
  }

  void setSelectedProduct(Product selected) {
    print("piç");
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
    product.id = id;
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
        if (selectedProduct == product) return;
        state.setSelectedProduct(product);
      },
    );
  }
}
