import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swap_toys/models/product.dart';

import '../pages/profile_page.dart';
import 'cameraManager.dart';

const List<String> statusList = <String>[
  'Oldukça Eski',
  'Eski',
  'Ortalama',
  'Yeni',
  'Kutusu Açılmamış'
];

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple,
    );
  }
}

Future<void> CreateProductFunc(String path) async {
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: CreateProduct(path: path),
    ),
  );
}

class CreateProduct extends StatefulWidget {
  String path;
  CreateProduct({super.key, required this.path});
  @override
  State<CreateProduct> createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String dropdownValue = statusList[2];
  static late List<String> localImgPaths = [];

  @override
  Widget build(BuildContext context) {
    int statuValue = 2;
    if (widget.path != "" && !localImgPaths.contains(widget.path))
      localImgPaths.add(widget.path);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Ürün Ekle"),
        centerTitle: true,
      ),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Ürün Adı',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 3,
                  controller: descriptionController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Ürün Açıklaması (İsteğe Bağlı)')),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: 'Ürün Durumu',
                  ),
                  value: dropdownValue,
                  onChanged: (String? value) {
                    setState(() {
                      dropdownValue = value!;
                    });
                  },
                  items:
                      statusList.map<DropdownMenuItem<String>>((String value) {
                    statuValue = statusList.indexOf(value);
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList()),
              const SizedBox(height: 10),
              takenPics()
            ],
          )),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: const Icon(Icons.upload),
          onPressed: () {
            Product product = Product(
                titleController.text, statuValue, localImgPaths, "id",
                description: descriptionController.text);
            product.createProduct();
          }),
    );
  }

  Widget takenPics() {
    return Column(children: [
      const Text(
        "Resimler",
        style: TextStyle(fontSize: 20),
      ),
      const SizedBox(height: 12),
      Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(children: [
            Expanded(
              child: ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: Expanded(
                      child: GridView.count(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    children: List.generate(localImgPaths.length + 1,
                        (index) => getPicPreviews(index)),
                  ))),
            )
          ]))
    ]);
  }

  Widget getPicPreviews(int index) {
    if (index < localImgPaths.length) {
      print(localImgPaths[index]);
      return Image.file(File(localImgPaths[index]));
    } else
      (index == localImgPaths.length);
    return ElevatedButton.icon(
      onPressed: () => openCam(),
      icon: const Icon(Icons.add_a_photo_outlined),
      label: const Text("resim ekle"),
    );
    throw const Text("upload error!");
  }
}
