import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextInputType Ktype;
  final bool IsPassword;
  final bool isObscure;
  final VoidCallback? onToggle;
  final String hintt;
  final Widget icona;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  
  
  MyTextField({
    required this.Ktype,
    required this.IsPassword,
    required this.isObscure,
    this.onToggle,
    required this.hintt,
    required this.icona,
    this.controller,
    this.validator,
    this.onFieldSubmitted,
    
    this.textInputAction,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: TextFormField(
        onFieldSubmitted: onFieldSubmitted,
        textInputAction: textInputAction,
        keyboardType: Ktype,
        obscureText: IsPassword ? isObscure : false,
        controller: controller,
        validator: validator,
        focusNode: focusNode,

        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hintt,
          hintStyle: TextStyle(fontFamily: 'Cairo'),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(color: Colors.grey, width: 1.2),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(color: Colors.grey, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(color: Colors.blue, width: 1.8),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(color: Colors.blue, width: 1.8),
          ),
          suffixIcon: icona,
          contentPadding: EdgeInsets.all(20),
        ),
      ),
    );
  }
}
