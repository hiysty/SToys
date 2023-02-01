import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/Managers/cameraManager.dart';

import '../models/product.dart';
import 'createProduct_page.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:swap_toys/models/product.dart';
import '../Managers/cameraManager.dart';
import 'package:camera/camera.dart';

class UpdateProduct extends StatefulWidget {
  UpdateProduct(this.productUpdate, {super.key});
  Product productUpdate;
  @override
  UpdateProductState createState() => UpdateProductState(productUpdate);
}

class UpdateProductState extends State<UpdateProduct> {
  @override
  UpdateProductState(this.productUpdate_);
  Product productUpdate_;
  late Product localProduct;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? dropdownValue;
  List<String>? imgLinks;

  static late List<String> localImgPaths_ = [];

  @override
  void initState() {
    super.initState();
    localProduct = productUpdate_;
    titleController.text = localProduct.title;
    descriptionController.text = localProduct.description;
    dropdownValue = statusList[localProduct.status];
    imgLinks = localProduct.imgLinksURLs;
  }

  // ignore: empty_constructor_bodies
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            localImgPaths_ = [];
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Ürünü Güncelle"),
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
                onChanged: (value) => localProduct.title = value,
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 3,
                controller: descriptionController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ürün Açıklaması (İsteğe Bağlı)'),
                onChanged: (value) => localProduct.description = value,
              ),
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
                    localProduct.status = statusList.indexOf(value);
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList()),
              const SizedBox(height: 10),
              takenPics_Update(localImgPaths_, imgLinks!)
            ],
          )),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: const Icon(Icons.upload),
          onPressed: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );

            update_Button(imgLinks);
            Navigator.pop(context);
            Navigator.pop(context);
          }),
    );
  }

  Widget takenPics_Update(List<String> localImgPaths, List<String> ImgLinks) {
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
                behavior: MyBehaviorUpdate(),
                child: Expanded(
                    child: GridView.count(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  children: List.generate(
                      localImgPaths.length + ImgLinks.length + 1,
                      (index) => getPicPreviews_update(
                          index, ImgLinks, localImgPaths)),
                ))),
          ]))
    ]);
  }

  Widget getPicPreviews_update(
      int index, List<String> ImgLinks, List<String> ImgPaths) {
    if (index <= ImgLinks.length - 1) {
      return Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: NetworkImage(ImgLinks[index]),
                fit: BoxFit.fitWidth,
                alignment: FractionalOffset.topCenter)),
      );
    } else if (index <= ImgLinks.length + ImgPaths.length - 1) {
      return Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: FileImage(File(ImgPaths[index - ImgLinks.length])),
                fit: BoxFit.fitWidth,
                alignment: FractionalOffset.topCenter)),
      );
    } else if (ImgLinks.length + ImgPaths.length == index) {
      return ElevatedButton.icon(
        onPressed: () async {
          WidgetsFlutterBinding.ensureInitialized();

          final cameras = await availableCameras();
          // Get a specific camera from the list of available cameras.
          final firstCamera = cameras.first;

          String? path = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TakePictureScreen(
                      camera: firstCamera,
                    )),
          );

          setState(() {
            if (path != null) ImgPaths.add(path);
          });
        },
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text("resim ekle"),
      );
    }

    throw const Text("upload error!");
  }

  void update_Button(List<String>? links) async {
    Map? map;

    await localProduct.PathsToLinks(localImgPaths_).then((map_) {
      map = map_;
    });
    imgLinks!.addAll(localProduct.mapToListForImgLinks(map));

    localProduct.imgsLinksMap = localProduct.listToMap(links!);

    localProduct.updateProduct();
  }
}

class MyBehaviorUpdate extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
