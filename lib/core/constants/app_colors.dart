import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF080D1A);
  static const secondaryBackground = Color(0xFF0D1323);
  static const cardSurface = Color(0xFF151B2C);
  static const elevatedCard = Color(0xFF1C2337);
  static const primaryPurple = Color(0xFF8B5CF6);
  static const lightPurple = Color(0xFFA78BFA);
  static const darkPurple = Color(0xFF5B2DCB);
  static const primaryText = Color(0xFFFFFFFF);
  static const secondaryText = Color(0xFFA8AFC0);
  static const mutedText = Color(0xFF727C92);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const border = Color(0xFF242B40);
  static const input = Color(0xFF111827);
  static const chip = Color(0xFF20283A);

  static const purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightPurple, primaryPurple, darkPurple],
  );

  static const darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF151936), background, Color(0xFF050814)],
  );
}
