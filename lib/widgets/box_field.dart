import 'package:flutter/material.dart';

class BoxField extends StatelessWidget {
  const BoxField({
    Key? key,
    required this.controller,
    required this.hinttext,
    required this.expand,
    this.lines,
    required this.validator,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? hinttext;
  final bool expand;
  final int? lines;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
          expands: expand,
          maxLines: lines,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            hintText: hinttext,
            border: const OutlineInputBorder(),
            // errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15),
          ),
          controller: controller,
          validator: validator),
    );
  }
}
