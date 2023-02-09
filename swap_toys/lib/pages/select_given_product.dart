import 'package:flutter/material.dart';
import 'package:swap_toys/models/product.dart';
import 'package:swap_toys/pages/inspectProduct_page.dart';
import 'package:swap_toys/pages/exchange_page.dart';

late Product receivedProduct;

class SelectGivenProductPage extends StatefulWidget {
  const SelectGivenProductPage({super.key, required this.received_product});
  final Product received_product;
  @override
  State<StatefulWidget> createState() {
    receivedProduct = received_product;
    return _SelectGivenProductPageState();
  }
}

class _SelectGivenProductPageState extends State<SelectGivenProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [],
      ),
    );
  }

  Product calcMostEquivalentProductOfMines() {
    return product;
  }
}
