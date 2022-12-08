import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swap_toys/models/user.dart';
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
    if (Path != "" && !localImgPaths.contains(Path))
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
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Ürün Adı',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 3,
                  controller: descriptionController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Ürün Açıklaması (İsteğe Bağlı)')),
              SizedBox(height: 10),
              DropdownButtonFormField(
                  decoration: InputDecoration(
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
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList()),
              SizedBox(height: 10),
              takenPics()
            ],
          )),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: const Icon(Icons.upload),
          onPressed: () {}),
    );
  }

  Widget takenPics() {
    return Column(children: [
      Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(children: [
            Expanded(
              child: ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: GridView.count(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    children: List.generate(localImgPaths.length + 1,
                        (index) => getPicPreviews(index)),
                  )),
            )
          ]))
    ]);
  }

  Widget getPicPreviews(int index) {
    if (index < localImgPaths.length) {
      return Container(
        child: Text(localImgPaths[index]),
      );
    } else
      (index == localImgPaths.length);
    return ElevatedButton.icon(
      onPressed: () => openCam(),
      icon: Icon(Icons.add_a_photo_outlined),
      label: Text("add pic"),
    );
    throw Text("upload error!");
  }
}
