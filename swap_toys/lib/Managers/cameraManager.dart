import 'dart:async';
import 'dart:io';
import 'package:swap_toys/pages/createProduct_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:swap_toys/pages/createProduct_page.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

List<String> takenImgPaths = [];

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget takenPics() => Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: takenImgPaths.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                        image: FileImage(File(takenImgPaths[index])),
                        fit: BoxFit.fitWidth,
                        alignment: FractionalOffset.topCenter),
                  ),
                  width: 150,
                ),
              );
            },
          ),
        );

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: AppBar(
          title: const Text('Resim çek'),
          leading: IconButton(
            onPressed: () async {
              takenImgPaths = List.empty(growable: true);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              takenPics(),
            ],
          ),
        ),
        floatingActionButton: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: FloatingActionButton.extended(
                        heroTag: UniqueKey(),
                        onPressed: () {
                          var takens = takenImgPaths;
                          takenImgPaths = [];
                          Navigator.pop(context, takens);
                        },
                        label: const Text("Ekle"),
                      )),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        heroTag: UniqueKey(),
                        // Provide an onPressed callback.
                        onPressed: () async {
                          // Take the Picture in a try / catch block. If anything goes wrong,
                          // catch the error.
                          try {
                            // Ensure that the camera is initialized.
                            await _initializeControllerFuture;

                            // Attempt to take a picture and get the file `image`
                            // where it was saved.
                            final image = await _controller.takePicture();

                            if (!mounted) return;

                            setState(() {
                              takenImgPaths.add(image.path);
                            });

                            // If the picture was taken, display it on a new screen.
                          } catch (e) {
                            // If an error occurs, log the error to the console.
                            print(e);
                          }
                        },
                        child: const Icon(Icons.camera_alt),
                      )),
                ])));
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
