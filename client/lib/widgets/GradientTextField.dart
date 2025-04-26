import 'package:flutter/material.dart';

class GradientLabelTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final int? minLines;
  final bool obscureText;
  final String? Function(String?)? validator;

  const GradientLabelTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.minLines,
    this.obscureText = false,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.indigo.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        minLines: minLines ?? 1,
        maxLines: obscureText ? 1 : null, // null allows it to expand
        obscureText: obscureText,
        style: TextStyle(color: Colors.indigo),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 16, color: Colors.indigo),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16.0),
        ),
      ),
    );
  }
}
