import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_task/widgets/vertical_space.dart';
import 'package:flutter/material.dart';


import 'home_page.dart';
import 'widgets/box_field.dart';

class EditPage extends StatefulWidget {
  final DocumentSnapshot docid;
  const EditPage({Key? key, required this.docid}) : super(key: key);

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();

  @override
  void initState() {
    title = TextEditingController(text: widget.docid.get('title'));
    content = TextEditingController(text: widget.docid.get('content'));
    super.initState();
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
                  Container(
                    height: 100,
                    width: 100,
                  ),
                  TextButton(
                      onPressed: () {}, child: const Text('تعديل الصورة')),
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
              Expanded(flex: 4,
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
                onPressed: () {
                  widget.docid.reference.update({
                    'title': title.text,
                    'content': content.text,
                  }).whenComplete(() {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const Home()));
                  });
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
