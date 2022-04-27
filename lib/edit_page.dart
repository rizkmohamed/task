import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_task/add_page.dart';
import 'package:crud_task/widgets/vertical_space.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'home_page.dart';
import 'widgets/box_field.dart';

class EditPage extends StatefulWidget {
   
  final DocumentSnapshot docid;
  const EditPage({Key? key, required this.docid,}) : super(key: key);

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  XFile? file;
  ImagePicker image = ImagePicker();
  String url = "";
  File? imageFile;
  
  FirebaseStorage storage = FirebaseStorage.instance;

  @override
  void initState() {
    title = TextEditingController(text: widget.docid.get('title'));
    content = TextEditingController(text: widget.docid.get('descrition'));
    url = widget.docid.get('imageUrl');
    super.initState();
  }

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

  Future<void> updateItemInFireStore() async {
    await widget.docid.reference.update({
      'title': title.text,
      'descrition': content.text,
      'imageUrl': url,
    }).whenComplete(() {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const Home()));
    });
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
              const Text('تعديل عنصر'),
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
                            ? Image.network(
                                url,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                imageFile!,
                                fit: BoxFit.cover,
                              )
                        //  Image.network('imageUrl', fit: BoxFit.cover),
                        ),
                  ),
                  TextButton(
                      onPressed: () async {
                        await getimage();
                      },
                      child: const Text('تعديل الصورة')),
                ],
              ),
              const VerticalSpace(),
              BoxField(
                controller: title,
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
                  controller: content,
                  hinttext: 'تفاصيل قصيرة عن العنصر',
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
                  'حفظ',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() != null) {
                    setState(() {});
                    await updateItemInFireStore();
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
