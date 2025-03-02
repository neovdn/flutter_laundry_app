import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String svgPath;
  final double radius;
  final Color backgroundColor;
  final Color borderColor;

  const CustomCircleAvatar({
    super.key,
    required this.svgPath,
    this.radius = 64,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.lightBlueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: ClipOval(
        child: SvgPicture.asset(
          svgPath,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
