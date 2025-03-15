import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/border_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/button_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/border_sizes.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final String? labelText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.labelText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.onSaved,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  CustomTextFormFieldState createState() => CustomTextFormFieldState();
}

class CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        validator: widget.validator,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        inputFormatters: widget.inputFormatters,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          labelStyle: AppTypography.label,
          prefixIcon:
              widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon: widget.suffixIcon,
          filled: true,
          fillColor: BackgroundColors.formFieldFill,
          contentPadding: const EdgeInsets.symmetric(
            vertical: PaddingSizes.formFieldVertical,
            horizontal: PaddingSizes.formFieldHorizontal,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ButtonSizes.borderRadius),
            borderSide: const BorderSide(
              color: BorderColors.defaultBorder,
              width: BorderSizes.thin,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ButtonSizes.borderRadius),
            borderSide: BorderSide(
              color: isHovered
                  ? BorderColors.focusedBorder
                  : BorderColors.defaultBorder,
              width: BorderSizes.thin,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ButtonSizes.borderRadius),
            borderSide: const BorderSide(
              color: BorderColors.focusedBorder,
              width: BorderSizes.medium,
            ),
          ),
        ),
      ),
    );
  }
}
