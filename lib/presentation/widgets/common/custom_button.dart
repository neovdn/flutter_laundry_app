import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/button_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/text_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/button_sizes.dart';


class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double height;
  final double width;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.height = ButtonSizes.defaultHeight, // Use defined default
    this.width = double.infinity, // Default width full
    this.borderRadius = ButtonSizes.borderRadius, // Use defined default
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? ButtonColors.loadingIndicatorDefault,
          foregroundColor: textColor ?? TextColors.lightText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          minimumSize: Size(width, height),
        ),
        child: Text(
          text,
          style: AppTypography.customButtonText, // Use defined typography
        ),
      ),
    );
  }
}