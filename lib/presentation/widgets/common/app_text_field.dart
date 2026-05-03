import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 22) : null,
      ),
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }
}
