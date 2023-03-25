import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/product.dart';
import 'package:swap_toys/models/user.dart';
import 'package:swap_toys/pages/inspectProduct_page.dart';
import 'package:swap_toys/pages/photogrammetryInput_page.dart';
import 'package:swap_toys/pages/styles.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'profile_page.dart';
import '../Managers/cameraManager.dart';
import 'dart:async';
import 'dart:math' as math;
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
  TextfieldTagsController tagFieldController = TextfieldTagsController();
  TextfieldTagsController _controller = TextfieldTagsController();
  String dropdownValue = statusList[2];
  late List<String> localImgPaths = [];
  late List<String> imgLinks = [];

  @override
  Widget build(BuildContext context) {
    int statuValue = 2;
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
        },
        child: MaterialApp(
            home: DefaultTabController(
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        Reference termsRef = FirebaseStorage.instance
                            .ref()
                            .child("searchTerms/terms.txt");
                        dynamic data = await termsRef.getData();
                        String termsText = utf8.decode(data);
                      },
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    title: const Text(
                      "Ürün Ekle",
                      style: appBar,
                    ),
                    centerTitle: true,
                  ),
                  body: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
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
                            items: statusList
                                .map<DropdownMenuItem<String>>((String value) {
                              statuValue = statusList.indexOf(value);
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
                          takenPics(),
                          tagAuto(),
                        ]))
                      ])),
                  floatingActionButton: FloatingActionButton.extended(
                      backgroundColor: Colors.blue,
                      icon: const Icon(Icons.upload),
                      label: const Text('Ürün Yükle'),
                      onPressed: () async {
                        if (titleController.text.isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Lütfen ürün adı giriniz.'),
                            backgroundColor: Colors.red,
                          ));
                          return;
                        } else if (localImgPaths.isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Lütfen resim ekleyiniz.'),
                            backgroundColor: Colors.red,
                          ));
                          return;
                        }
                        Product product = Product(
                            titleController.text,
                            statuValue,
                            await uploadImgs(localImgPaths),
                            descriptionController.text,
                            User_.email,
                            _controller.getTags!);
                        product.createProduct();
                      }),
                ))));
  }

  Widget takenPics() => Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: GridView.count(
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          shrinkWrap: true,
          crossAxisCount: 3,
          children: List.generate(
              localImgPaths.length + 1, (index) => getPicPreviews(index)),
        ),
      );

  Widget tagAuto() {
    return Column(
      children: [
        TextFieldTags(
          textfieldTagsController: _controller,
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

  Widget tags() => TextFieldTags(
      textfieldTagsController: tagFieldController,
      validator: (tag) {
        if (tagFieldController.getTags!.contains(tag)) {
          return 'Bu etiket zaten eklenmiştir';
        }
        return null;
      },
      inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
        return (context, sc, tags, onDeleteTag) {
          return Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: tec,
                focusNode: fn,
                decoration: const InputDecoration(
                    isDense: true, border: OutlineInputBorder()),
              ));
        };
      });

  Widget getPicPreviews(int index) {
    if (index < localImgPaths.length) {
      return GestureDetector(
          onLongPress: () => setState(() => localImgPaths.removeAt(index)),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                    image: FileImage(File(localImgPaths[index])),
                    fit: BoxFit.fitWidth,
                    alignment: FractionalOffset.topCenter)),
          ));
    } else {
      (index == localImgPaths.length);
    }
    return ElevatedButton.icon(
      onPressed: () async {
        WidgetsFlutterBinding.ensureInitialized();

        final cameras = await availableCameras();
        // Get a specific camera from the list of available cameras.
        final firstCamera = cameras.first;

        List<String> paths = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TakePictureScreen(
                    camera: firstCamera,
                  )),
        );
        setState(() {
          if (!paths.isEmpty) localImgPaths.addAll(paths);
        });
      },
      icon: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(math.pi),
          child: Icon(Icons.add_a_photo_outlined, size: 22)),
      label: const Text("Resim Ekle"),
    );
  }

  Future<List<String>> uploadImgs(List<String> paths) async {
    List<String> links = [];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    for (int i = 0; i < localImgPaths.length; i++) {
      File file = File(paths[i]);
      final ref =
          FirebaseStorage.instance.ref().child("images/${file.hashCode}}");
      UploadTask uploadtask = ref.putFile(file);

      String url = "";
      await uploadtask.whenComplete(() async {
        url = await ref.getDownloadURL();
      });

      links.add(url);
    }
    Navigator.pop(context);
    Navigator.pop(context);

    print(links);
    return links;
  }
}
