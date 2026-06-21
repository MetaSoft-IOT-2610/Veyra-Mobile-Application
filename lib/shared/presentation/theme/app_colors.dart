import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF1468A8);
  static const primaryDark = Color(0xFF0B426F);
  static const primaryLight = Color(0xFFDCEEFF);
  static const clinicalBlue = Color(0xFF2187C7);
  static const cyan = Color(0xFF24A6B8);
  static const success = Color(0xFF23855B);
  static const successSoft = Color(0xFFE1F4EB);
  static const warning = Color(0xFFD88417);
  static const warningSoft = Color(0xFFFFF1D9);
  static const danger = Color(0xFFC94B55);
  static const dangerSoft = Color(0xFFFFE8EA);

  static const background = Color(0xFFF3F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF7FAFC);
  static const border = Color(0xFFDDE7ED);
  static const textPrimary = Color(0xFF17344D);
  static const textSecondary = Color(0xFF617788);
  static const textMuted = Color(0xFF8A9BA8);

  static const clinicalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, clinicalBlue],
  );

  static List<BoxShadow> get softShadow => [
    const BoxShadow(
      color: Color(0x120B426F),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
}
