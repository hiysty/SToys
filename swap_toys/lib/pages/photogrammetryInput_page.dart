import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart';
import 'package:swap_toys/main.dart';

import '../Managers/cameraManager.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class photogrammetryInputPage extends StatefulWidget {
  @override
  State<photogrammetryInputPage> createState() => _photogrammetryInputPage();
}

List<String> localImgPaths = [];

class _photogrammetryInputPage extends State<photogrammetryInputPage> {
  List<String> paths = [];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    Widget getPicPreviews(int index) {
      if (!localImgPaths.isEmpty) {
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
      } else
        return Text("empty");
    }

    Widget takenPics() => Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: GridView.count(
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
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Container(
              alignment: Alignment.center,
              color: Colors.black54,
              width: screenWidth,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: const Text(
                "Ürünün modelini oluşturmak için ürünün fotoğrafları kullanılır. Ürün etrafında dolanarak 360 dereceden fotoğrafları çekilir. Fotoğraflar arası fazla aralık olmamalıdır. Yaklaşık 25-30 fotoğraf yeterlidir.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
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
                  if (path != null) setState(() => localImgPaths.addAll(path));
                });
              },
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text("Fotoğrafları Çek"),
            ),
            const SizedBox(
              height: 30,
            ),
            takenPics(),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  startPhotogrammetry();
                },
                child: Text("Tamamla"))
          ],
        )));
  }

  void startPhotogrammetry() async {
    print("baslamk");

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://tchange.pythonanywhere.com/'));
    request.fields['user-productId'] = '${User_.email}';

    for (var path in localImgPaths) {
      request.files.add(await http.MultipartFile.fromPath('photos', path));
    }
    var response = await request.send();

    if (response.statusCode == HttpStatus.ok) {
      print('Request sent successfully.');
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }
}
