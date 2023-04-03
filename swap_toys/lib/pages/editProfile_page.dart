import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swap_toys/main.dart';
import 'package:swap_toys/models/user.dart';
import 'package:swap_toys/pages/error_page.dart';
import 'styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class EditProfile extends StatefulWidget {
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController usernameController = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();

  File? image;

  Future pickImage(ImageSource imageSource) async {
    try {
      final image = await ImagePicker().pickImage(source: imageSource);
      if (image == null) return;

      final imageTemporary = File(image.path);

      setState(() => this.image = imageTemporary);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<String> getDownloadURL(bool removeProfilePicture) async {
    final userMail = User_.email;
    final storage = FirebaseStorage.instance;

    if (!removeProfilePicture) {
      final ref = storage.ref().child('profilePictures/$userMail');

      try {
        return await ref.getDownloadURL();
      } catch (e) {
        return await storage
            .ref()
            .child('profilePictures/default.png')
            .getDownloadURL();
      }
    } else {
      return await storage
          .ref()
          .child('profilePictures/default.png')
          .getDownloadURL();
    }
  }

  bool removeProfilePicture = false;

  @override
  Widget build(BuildContext context) {
    usernameController.text = User_.displayName;

    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Profil Düzenle',
        style: appBar,
      )),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              FutureBuilder<String>(
                  future: getDownloadURL(removeProfilePicture),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Stack(children: [
                        image != null
                            ? CircleAvatar(
                                radius: 60,
                                backgroundImage: FileImage(image!),
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 60,
                                backgroundImage:
                                    CachedNetworkImageProvider(snapshot.data!)),
                        PopupMenuButton(
                            splashRadius: 0.1,
                            tooltip: '',
                            child: CircleAvatar(
                                backgroundColor: Colors.grey.withOpacity(.5),
                                radius: 60,
                                child: const Icon(
                                  Icons.add_a_photo_outlined,
                                  color: Colors.white,
                                  size: 40,
                                )),
                            itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text('Resim çek'),
                                    onTap: () {
                                      removeProfilePicture = false;
                                      pickImage(ImageSource.camera);
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: const Text('Galeriden resim seç'),
                                    onTap: () {
                                      removeProfilePicture = false;
                                      pickImage(ImageSource.gallery);
                                    },
                                  ),
                                  PopupMenuItem(
                                    onTap: () {
                                      image = null;
                                      removeProfilePicture = true;
                                      print(image);
                                      setState(() {});
                                    },
                                    child:
                                        const Text('Profil resmini kaldırın'),
                                  )
                                ])
                      ]);
                    } else if (snapshot.hasError) {
                      return ErrorPage(errorCode: snapshot.error.toString());
                    } else {
                      return const SizedBox(
                        height: 120,
                        width: 120,
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
              TextField(
                  controller: usernameController,
                  decoration:
                      const InputDecoration(label: Text('Kullanıcı Adı'))),
            ],
          )),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        onPressed: () => saveProfile(FirebaseAuth.instance.currentUser!.email!),
        icon: const Icon(Icons.save),
        label: const Text('Kaydet'),
      ),
    );
  }

  Future saveProfile(String imageName) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (image != null) {
      await storage.ref('profilePictures/$imageName').putFile(image!);
    }

    if (removeProfilePicture) {
      await storage.ref().child('profilePictures/${User_.email}').delete();
    }

    await firestore.collection('users').doc(User_.email).update({
      'displayName': usernameController.text,
      'profilePicture': await storage
          .ref()
          .child('profilePictures/$imageName')
          .getDownloadURL()
    });

    Navigator.pop(context);
    Navigator.pop(context);
  }
}
