import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_task/widgets/vertical_space.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

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
  String? title;
  String? content;
  CollectionReference items = FirebaseFirestore.instance.collection('items');
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> getimage() async {
    try {
      file = await image.pickImage(source: ImageSource.gallery, maxWidth: 1920);

      final String fileName = path.basename(file!.path);
      File imageFile = File(file!.path);

      try {
        await storage.ref(fileName).putFile(
              imageFile,
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

  Future<void> addTaskInFireStore() async {
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
              body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('اضافة عنصر'),
              const VerticalSpace(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                  ),
                  TextButton(
                      onPressed: () async {
                        await getimage();
                      },
                      child: const Text('اختر صورة')),
                ],
              ),
              const VerticalSpace(),
              BoxField(
                controller: titleController,
                hinttext: 'عنوان العنصر',
                expand: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى ادخال عنوان العنصر';
                  }
                  return null;
                },
              ),
              const VerticalSpace(),
              Expanded(
                flex: 4,
                child: BoxField(
                  controller: contentController,
                  hinttext: 'تفاصيل العنصر',
                  expand: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى ادخال تفاصيل العنصر';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                child: const Text(
                  'اضافة',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() != null) {
                    setState(() {
                      title = titleController.text;
                      content = contentController.text;
                    });
                    await addTaskInFireStore();
                  }
                },
                style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )),
              )
            ],
          )),
        ));
  }
}
