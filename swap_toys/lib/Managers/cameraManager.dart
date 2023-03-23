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
    Widget getPicPreviews(int index) {
      if (!takenImgPaths.isEmpty) {
        return GestureDetector(
            onLongPress: () => setState(() => takenImgPaths.removeAt(index)),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                      image: FileImage(File(takenImgPaths[index])),
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
                takenImgPaths.length, (index) => getPicPreviews(index)),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, takenImgPaths);
              },
              child: Text('My Button'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
      ),
    );
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
