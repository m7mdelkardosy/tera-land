import 'package:flutter/material.dart';

class MyFormField extends StatelessWidget {
  final String hinttt;
  final TextEditingController controller;
  const MyFormField({required this.hinttt, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
      child: TextFormField(
        controller: controller,

        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromARGB(255, 239, 242, 242),
          hintText: hinttt,

          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.grey,
            fontSize: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: const Color.fromARGB(255, 230, 244, 252),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(
              color: const Color.fromARGB(255, 212, 213, 213),
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}
