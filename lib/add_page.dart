import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_task/widgets/vertical_space.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'home_page.dart';
import 'widgets/box_field.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  XFile? file;
  ImagePicker image = ImagePicker();
  String url = "";
  File? imageFile;
  String? title;
  String? content;
  CollectionReference items = FirebaseFirestore.instance.collection('items');
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> getimage() async {
    try {
      file = await image.pickImage(source: ImageSource.gallery, maxWidth: 1920);

      final String fileName = path.basename(file!.path);
      imageFile = File(file!.path);

      try {
        await storage.ref(fileName).putFile(
              imageFile!,
            );
        url = await storage.ref(fileName).getDownloadURL();

        setState(() {});
      } on FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  Future<void> addItemInFireStore() async {
    await items.add({
      'title': titleController.text,
      'imageUrl': url,
      'descrition': contentController.text
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                const Text('?????????? ????????'),
                const VerticalSpace(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15), // Image border
                      child: SizedBox.fromSize(
                          size: const Size.fromRadius(48), // Image radius
                          child: imageFile == null
                              ? Image.asset(
                                  'assets/images.png',
                                  fit: BoxFit.cover,
                                  
                                )
                              : Image.file(imageFile!, fit: BoxFit.cover,)
                        
                          ),
                    ),
                    TextButton(
                        onPressed: () async {
                          await getimage();
                        },
                        child: const Text('???????? ????????')),
                  ],
                ),
                const VerticalSpace(),
                BoxField(
                  controller: titleController,
                  hinttext: '?????????? ????????????',
                  expand: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '???????? ?????????? ?????????? ????????????';
                    }
                    return null;
                  },
                ),
                const VerticalSpace(),
                Expanded(
                  flex: 4,
                  child: BoxField(
                    controller: contentController,
                    hinttext: '???????????? ????????????',
                    expand: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '???????? ?????????? ???????????? ????????????';
                      }
                      return null;
                    },
                  ),
                ),
                ElevatedButton(
                  child: const Text(
                    '??????????',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() != null) {
                      setState(() {
                        title = titleController.text;
                        content = contentController.text;
                      });
                      await addItemInFireStore();
                       Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const Home()));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )),
                )
                          ],
                        ),
              )),
        ));
  }
}
