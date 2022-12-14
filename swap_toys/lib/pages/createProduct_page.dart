import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/product.dart';
import 'package:swap_toys/models/user.dart';
import 'profile_page.dart';
import '../Managers/cameraManager.dart';
import 'dart:async';
import 'package:camera/camera.dart';

const List<String> statusList = <String>[
  'Oldukça Eski',
  'Eski',
  'Ortalama',
  'Yeni',
  'Kutusu Açılmamış'
];

Future<void> CreateProductFunc(String path) async {
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: CreateProduct(),
    ),
  );
}

class CreateProduct extends StatefulWidget {
  CreateProduct({super.key});
  @override
  State<CreateProduct> createState() => _CreateProductState();
  late String path;
}

class _CreateProductState extends State<CreateProduct> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String dropdownValue = statusList[2];
  static late List<String> localImgPaths = [];
  static late List<String> imgLinks = [];

  @override
  Widget build(BuildContext context) {
    int statuValue = 2;
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
          onPressed: () async {
            Product product = Product(
              titleController.text,
              statuValue,
              await uploadImgs(localImgPaths),
              descriptionController.text,
              User_.email,
            );
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
            ScrollConfiguration(
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
          ]))
    ]);
  }

  Widget getPicPreviews(int index) {
    if (index < localImgPaths.length) {
      print(localImgPaths[index]);
      return Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: FileImage(File(localImgPaths[index])),
                fit: BoxFit.fitWidth,
                alignment: FractionalOffset.topCenter)),
      );
    } else {
      (index == localImgPaths.length);
    }
    return ElevatedButton.icon(
      onPressed: () async {
        WidgetsFlutterBinding.ensureInitialized();

        final cameras = await availableCameras();
        // Get a specific camera from the list of available cameras.
        final firstCamera = cameras.first;

        var path = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TakePictureScreen(
                    camera: firstCamera,
                  )),
        );
        setState(() {
          localImgPaths.add(path);
        });
      },
      icon: const Icon(Icons.add_a_photo_outlined),
      label: const Text("resim ekle"),
    );
    throw const Text("upload error!");
  }

  Future<Map> uploadImgs(List<String> paths) async {
    final Links = {"0": "1"};
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    for (var i = 0; i < localImgPaths.length; i++) {
      File file = File(paths[i]);
      final ref =
          FirebaseStorage.instance.ref().child("images/${file.hashCode}}");
      UploadTask uploadtask = ref.putFile(file);

      String url = "";
      await uploadtask.whenComplete(() async {
        url = await ref.getDownloadURL();
      });

      Links["$i"] = url;
    }
    Navigator.pop(context);
    Navigator.pop(context);

    return Links;
  }
}
