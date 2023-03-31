import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/Managers/cameraManager.dart';
import 'package:swap_toys/pages/photogrammetryInput_page.dart';
import 'package:swap_toys/pages/styles.dart';
import 'package:textfield_tags/textfield_tags.dart';

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
  TextfieldTagsController _controller = TextfieldTagsController();
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
    for (var element in productUpdate_.tags) {
      print(element);
    }

    return MaterialApp(
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
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
                          items: statusList
                              .map<DropdownMenuItem<String>>((String value) {
                            localProduct.status = statusList.indexOf(value);
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList()),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        photogrammetryInputPage()));
                          },
                          child: Text("3D Model Oluştur")),
                      const SizedBox(height: 10),
                      TabBar(
                          onTap: (value) {
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus)
                              currentFocus.unfocus();
                          },
                          labelColor: Colors.indigo,
                          labelStyle: header,
                          tabs: const [
                            Tab(text: "Resimler"),
                            Tab(text: "Etiketler"),
                          ]),
                      Expanded(
                          child: TabBarView(children: [
                        takenPics_Update(localImgPaths_, imgLinks!),
                        tagAuto_Update(),
                      ]))
                    ],
                  )),
              floatingActionButton: FloatingActionButton.extended(
                  backgroundColor: Colors.blue,
                  label: const Text("Ürün Güncelle"),
                  icon: const Icon(Icons.replay),
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
            )));
  }

  Widget takenPics_Update(List<String> localImgPaths, List<String> ImgLinks) {
    return Container(
        padding: const EdgeInsets.all(5),
        child: GridView.count(
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          shrinkWrap: true,
          crossAxisCount: 3,
          children: List.generate(localImgPaths.length + ImgLinks.length + 1,
              (index) => getPicPreviews_update(index, ImgLinks, localImgPaths)),
        ));
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

          var value = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TakePictureScreen(
                      camera: firstCamera,
                    )),
          );

          List<String> path = (value.runtimeType == List<String>)
              ? value
              : List.empty(growable: true);

          setState(() {
            if (path != null) ImgPaths.addAll(path);
          });
        },
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text("resim ekle"),
      );
    }

    throw const Text("upload error!");
  }

  void update_Button(List<String>? links) async {
    List<String> map;

    map = await localProduct.PathsToLinks(localImgPaths_);
    imgLinks!.addAll(map);

    localProduct.updateProduct();
  }

  Widget tagAuto_Update() {
    return Column(
      children: [
        TextFieldTags(
          textfieldTagsController: _controller,
          initialTags: productUpdate_.tags.map((e) => e as String).toList(),
          textSeparators: const [' ', ','],
          letterCase: LetterCase.normal,
          validator: (String tag) {
            if (_controller.getTags!.contains(tag)) {
              return 'Lütfen bir etiketi tekrar kullanmayınız';
            }
            return null;
          },
          inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
            return ((context, sc, tags, onTagDelete) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: tec,
                  focusNode: fn,
                  decoration: InputDecoration(
                    isDense: true,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 3.0,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 3.0,
                      ),
                    ),
                    helperStyle: const TextStyle(
                      color: Colors.blue,
                    ),
                    hintText: _controller.hasTags ? '' : "Etiket giriniz...",
                    errorText: error,
                    prefixIcon: tags.isNotEmpty
                        ? SingleChildScrollView(
                            controller: sc,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                children: tags.map((String tag) {
                              return Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  color: Colors.blue,
                                ),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      child: Text(
                                        tag,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 4.0),
                                    InkWell(
                                      child: const Icon(
                                        Icons.cancel,
                                        size: 14.0,
                                        color:
                                            Color.fromARGB(255, 233, 233, 233),
                                      ),
                                      onTap: () {
                                        onTagDelete(tag);
                                      },
                                    )
                                  ],
                                ),
                              );
                            }).toList()),
                          )
                        : null,
                  ),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                ),
              );
            });
          },
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.blue,
            ),
          ),
          onPressed: () {
            _controller.clearTags();
          },
          child: const Text('Etiketleri Temizle'),
        ),
      ],
    );
  }
}

class MyBehaviorUpdate extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
