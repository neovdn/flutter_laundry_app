import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/colors/text_colors.dart';

class AppTypography {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight bold = FontWeight.w700;

  static TextStyle heading1 = TextStyle(
    fontSize: 36,
    fontWeight: bold,
    color: TextColors.quaternary, // Pakai warna dari text_colors.dart
  );
  static TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: regular,
    color: TextColors.quaternary, // Pakai warna dari text_colors.dart
  );
  static TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: bold,
    color: TextColors.primary, // Pakai warna dari text_colors.dart
  );
  static TextStyle heading4 = TextStyle(
    fontSize: 18,
    fontWeight: bold,
    color: TextColors.quaternary, // Pakai warna dari text_colors.dart
  );

  static TextStyle subTitle1 = TextStyle(
    fontSize: 28,
    fontWeight: regular,
    color: TextColors.secondary,
  );

  static TextStyle subTitle2 = TextStyle(
    fontSize: 24,
    fontWeight: regular,
    color: TextColors.tertiary,
  );

  static TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    color: TextColors.secondary,
  );

  static TextStyle date = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    color: TextColors.secondary,
  );

  static TextStyle price = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    color: TextColors.primary,
  );
}
