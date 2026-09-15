import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class SaamaGoWordmark extends StatelessWidget {
  const SaamaGoWordmark({
    super.key,
    this.fontSize = 28,
    this.showTagline = false,
    this.center = false,
  });

  final double fontSize;
  final bool showTagline;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final wordmark = RichText(
      textAlign: center ? TextAlign.center : TextAlign.start,
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          height: 1,
        ),
        children: const [
          TextSpan(
            text: 'SAAMA',
            style: TextStyle(color: AppColors.primaryText),
          ),
          TextSpan(
            text: 'go',
            style: TextStyle(color: AppColors.primaryBlue),
          ),
        ],
      ),
    );

    if (!showTagline) {
      return Semantics(label: AppStrings.appName, child: wordmark);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Semantics(label: AppStrings.appName, child: wordmark),
        const SizedBox(height: 8),
        const Text(
          AppStrings.tagline,
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
