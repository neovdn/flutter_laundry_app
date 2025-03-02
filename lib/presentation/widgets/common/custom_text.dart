import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/colors/text_colors.dart';

class CustomText extends StatelessWidget {
  final String normalText;
  final String highlightedText;
  final VoidCallback? onTap;

  const CustomText({
    super.key,
    required this.normalText,
    required this.highlightedText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: normalText,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black, // Warna hitam untuk teks biasa
            ),
          ),
          TextSpan(
            text: highlightedText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TextColors.quinary, // Warna biru muda untuk "Register"
            ),
            recognizer: TapGestureRecognizer()..onTap = onTap, // Hilangkan padding default
          ),
        ],
      ),
    );
  }
}
