import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_circle_avatar.dart';

class AppLogoWidget extends StatelessWidget {
  final double size;
  final String appName;
  final TextStyle? textStyle;

  const AppLogoWidget({
    super.key,
    this.size = 80,
    this.appName = 'LaundryGo',
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomCircleAvatar(svgPath: 'assets/svg/logo.svg'),
        const SizedBox(height: 12),
        SvgPicture.asset(
          'assets/svg/LaundryGo.svg',
          width: 160, // Sesuaikan ukuran sesuai kebutuhan
        ),
      ],
    );
  }
}
