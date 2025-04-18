import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.controller,
    this.labelText,
    this.obscureText = false,
    this.onChanged,
    this.keyboardType,
    this.validator,
    this.forceErrorText,
    this.prefixIcon, this.maxLines,
  });

  final TextEditingController? controller;
  final String? labelText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final String? Function(String? value)? validator;
  final String? forceErrorText;
  final Widget? prefixIcon;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        filled: true,
        labelText: labelText,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: keyboardType ?? TextInputType.text,
      obscureText: obscureText,
    );
  }
}
