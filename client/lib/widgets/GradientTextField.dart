import 'package:flutter/material.dart';

class GradientLabelTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final int? minLines;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const GradientLabelTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.minLines,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.suffixIcon,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: !enabled ?
      BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ])
      : BoxDecoration(
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
    ),]
    ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        enabled: enabled,
        readOnly: readOnly,
        minLines: minLines ?? 1,
        maxLines: obscureText ? 1 : null,
        obscureText: obscureText,
        style: TextStyle(color: enabled ? Colors.indigo : Colors.black87),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 16, color: enabled ? Colors.indigo : Colors.black87),
          filled: true,
          fillColor: Colors.transparent,
          border: enabled ? InputBorder.none : OutlineInputBorder(),
          contentPadding: const EdgeInsets.all(16.0),
          suffixIcon: suffixIcon
          ),
      ),
    );
  }
}
