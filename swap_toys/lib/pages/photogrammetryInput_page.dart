import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/pages/error_page.dart';

import '../Managers/cameraManager.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class PhotogrammetryInputPage extends StatefulWidget {
  @override
  State<PhotogrammetryInputPage> createState() => _PhotogrammetryInputPage();
}

List<String> localImgPaths = [];

class _PhotogrammetryInputPage extends State<PhotogrammetryInputPage> {
  List<String> paths = [];

  @override
  Widget build(BuildContext context) {
    Widget getPicPreviews(int index) {
      if (localImgPaths.isNotEmpty) {
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
        return const ErrorPage(errorCode: "No Image");
      }
    }

    Widget takenPics() => Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            shrinkWrap: true,
            crossAxisCount: 3,
            children: List.generate(
                localImgPaths.length, (index) => getPicPreviews(index)),
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text("3D Model Oluştur"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => const AlertDialog(
                          title: Text("Yardım"),
                          content: Text(
                              "Ürünün modelini oluşturmak için ürünün fotoğrafları kullanılır. Ürün etrafında dolanarak 360 dereceden fotoğrafları çekilir. Fotoğraflar arası fazla aralık olmamalıdır. Yaklaşık 25-30 fotoğraf yeterlidir."),
                        ));
              },
              icon: const Icon(Icons.question_mark_rounded))
        ],
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
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
                    print(path);
                    if (path != null)
                      setState(() => localImgPaths.addAll(path));
                  });
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text("Fotoğrafları Çek"),
              ),
              takenPics(),
            ],
          )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, localImgPaths),
        label: const Text("Tamamla"),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
