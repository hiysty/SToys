import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/Managers/cameraManager.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/pages/photogrammetryInput_page.dart';
import 'package:swap_toys/pages/styles.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'dart:math' as math;
import '../models/product.dart';
import 'createProduct_page.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:swap_toys/models/product.dart';
import '../Managers/cameraManager.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

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
  Product? localProduct;
  List<String>? photogrametryPaths;
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextfieldTagsController tagFieldController = TextfieldTagsController();
  TextfieldTagsController _controller = TextfieldTagsController();
  String? dropdownValue;
  List<String>? imgLinks;

  static late List<String> localImgPaths_ = [];

  void startPhotogrammetry() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://tchange.pythonanywhere.com/'));
    request.fields['user-productId'] = User_.email;

    for (var path in photogrametryPaths!) {
      request.files.add(await http.MultipartFile.fromPath('photos', path));
    }
    var response = await request.send();

    Navigator.pop(context);

    if (response.statusCode == HttpStatus.ok) {
      print('Request sent successfully.');
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    titleController.text = productUpdate_.title;
    descriptionController.text = productUpdate_.description;
    dropdownValue = statusList[productUpdate_.status];
    imgLinks = productUpdate_.imgLinksURLs.toList();
    _controller.init(
        (tag) => null,
        LetterCase.normal,
        productUpdate_.tags.map((e) => e as String).toList(),
        TextEditingController(),
        FocusNode(),
        const [' ', ',']);
  }

  // ignore: empty_constructor_bodies
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Montserrat',
        ),
        scaffoldMessengerKey: _scaffoldKey,
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () {
                    localImgPaths_ = [];
                    Navigator.pop(context, productUpdate_);
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
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        minLines: 3,
                        controller: descriptionController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Ürün Açıklaması'),
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
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList()),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: () async {
                            photogrametryPaths = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PhotogrammetryInputPage()));
                          },
                          child: const Text("3D Model Oluştur")),
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
                    if (titleController.text.isEmpty) {
                      _scaffoldKey.currentState!.showSnackBar(const SnackBar(
                        content: Text('Lütfen ürün adı giriniz.'),
                        backgroundColor: Colors.red,
                      ));
                      return;
                    } else if (descriptionController.text.isEmpty) {
                      _scaffoldKey.currentState!.showSnackBar(const SnackBar(
                        content: Text('Lütfen ürün açıklaması giriniz.'),
                        backgroundColor: Colors.red,
                      ));
                      return;
                    } else if (localImgPaths_.isEmpty && imgLinks!.isEmpty) {
                      _scaffoldKey.currentState!.showSnackBar(const SnackBar(
                        content: Text('Lütfen resim ekleyiniz.'),
                        backgroundColor: Colors.red,
                      ));
                      return;
                    } else if (!_controller.hasTags) {
                      _scaffoldKey.currentState!.showSnackBar(const SnackBar(
                        content: Text('En az bir etiket giriniz.'),
                        backgroundColor: Colors.red,
                      ));
                      return;
                    }

                    if (photogrametryPaths != null) {
                      startPhotogrammetry();
                    }

                    update_Button(imgLinks);
                    localImgPaths_ = [];
                    Navigator.pop(context, localProduct);
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
      return GestureDetector(
          onLongPress: () => setState(() {
                ImgLinks.removeAt(index);
              }),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                    image: NetworkImage(ImgLinks[index]),
                    fit: BoxFit.fitWidth,
                    alignment: FractionalOffset.topCenter)),
          ));
    } else if (index <= ImgLinks.length + ImgPaths.length - 1) {
      return GestureDetector(
        onLongPress: () => setState(() {
          ImgPaths.removeAt(index - ImgLinks.length);
        }),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                    image: FileImage(File(ImgPaths[index - ImgLinks.length])),
                    fit: BoxFit.fitWidth,
                    alignment: FractionalOffset.topCenter))),
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
        icon: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: Icon(Icons.add_a_photo_outlined, size: 22)),
        label: const Text("Resim Ekle"),
      );
    }

    throw const Text("upload error!");
  }

  Future<String> saveImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final fileName = imageUrl.split('/').last;
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/$fileName');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  Future update_Button(List<String>? links) async {
    List<String> map;

    bool isFirstImageLink = imgLinks!.isNotEmpty ? true : false;

    localProduct = Product(
        titleController.text,
        statusList.indexOf(dropdownValue!),
        imgLinks!,
        descriptionController.text,
        productUpdate_.email,
        _controller.getTags!,
        productUpdate_.category,
        productUpdate_.likes);

    localProduct!.id = productUpdate_.id;

    map = await localProduct!.PathsToLinks(localImgPaths_);
    imgLinks!.addAll(map);

    if (isFirstImageLink) {
      localProduct!.category =
          await imageLabelingTag(await saveImage(imgLinks!.first));
    } else {
      localProduct!.category = await imageLabelingTag(imgLinks!.first);
    }

    localProduct!.updateProduct();
  }

  Future<String> imageLabelingTag(String image) async {
    var request = http.MultipartRequest('POST',
        Uri.parse('http://tchange.pythonanywhere.com/object-recognition'));
    request.fields['user-productId'] = '${User_.email}or';
    request.files.add(await http.MultipartFile.fromPath('photo', image));

    var response = await request.send();
    return response.stream.transform(utf8.decoder).join();
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
                        ? Row(
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
                            }).toList(),
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
