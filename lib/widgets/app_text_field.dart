import 'package:flutter/material.dart';

/// Shared text input used by the Login and Report Form screens.
///
/// Keeping the decoration, spacing, and validation hook in one place means the
/// report form does not duplicate input styling from Activity 8.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.enabled = true,
    this.obscureText = false,
    this.autofillHints,
    this.onFieldSubmitted,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? helperText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final bool enabled;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      obscureText: obscureText,
      autofillHints: autofillHints,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: prefixIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 4, right: 8),
                child: Icon(prefixIcon, size: 20),
              ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
