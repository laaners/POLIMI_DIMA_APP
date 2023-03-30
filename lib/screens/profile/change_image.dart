import 'dart:io';

import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';
import 'package:path/path.dart';

class ChangeImage extends StatefulWidget {
  const ChangeImage({super.key});

  @override
  State<ChangeImage> createState() => _ChangeImageState();
}

class _ChangeImageState extends State<ChangeImage> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  File? _photo;
  bool loading = false;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile(context);
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera(BuildContext context) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 30,
    );

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile(context);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile(BuildContext context) async {
    if (_photo == null) return;
    setState(() {
      loading = true;
    });
    final userId = Provider.of<FirebaseUser>(context, listen: false)
        .user
        ?.uid; // basename(_photo!.path);
    final destination = 'profile_pics/$userId';
    try {
      var ref =
          firebase_storage.FirebaseStorage.instance.ref().child(destination);
      await ref.putFile(_photo!);
      String profileUrl = await ref.getDownloadURL();
      // ignore: use_build_context_synchronously
      await Provider.of<FirebaseUser>(context, listen: false)
          .updateProfilePic(context, profileUrl);
      print(url);
      setState(() {
        loading = false;
      });
    } catch (e) {
      print('error occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () {
          _showPicker(context);
        },
        child: Stack(
          children: [
            Consumer<FirebaseUser>(
              builder: (context, value, child) {
                return ProfilePic(
                  userData: value.userData,
                  loading: loading,
                  radius: 90,
                );
              },
            ),
            Positioned(
              right: 10.0,
              bottom: 0.0,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Palette.lightBGColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  iconSize: 20.0,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    _showPicker(context);
                  },
                  icon: const Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(
                    'Gallery',
                    style: TextStyle(
                      color: Provider.of<ThemeSwitch>(context)
                          .themeData
                          .primaryColor,
                    ),
                  ),
                  onTap: () {
                    imgFromGallery(context);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(
                  'Camera',
                  style: TextStyle(
                    color: Provider.of<ThemeSwitch>(context)
                        .themeData
                        .primaryColor,
                  ),
                ),
                onTap: () {
                  imgFromCamera(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
