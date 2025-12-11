// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextFieldBox extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isObscure;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const TextFieldBox({
    Key? key,
    required this.hint,
    required this.icon,
    this.isObscure = false,
    required this.controller,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
