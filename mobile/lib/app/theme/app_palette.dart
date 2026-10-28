import 'package:flutter/material.dart';

/// Bazowa paleta powierzchni i tekstu dla jednego z czterech wariantów motywu
/// (jasny / ciemny x standardowy / wysoki kontrast).
@immutable
class AppPalette {
  const AppPalette({
    required this.accent,
    required this.onAccent,
    required this.background,
    required this.card,
    required this.secondaryBackground,
    required this.text,
    required this.textSecondary,
    required this.border,
  });

  factory AppPalette.resolve({required bool dark, required bool highContrast}) {
    if (dark && highContrast) return _darkHighContrast;
    if (dark) return _dark;
    if (highContrast) return _lightHighContrast;
    return _light;
  }

  final Color accent;
  final Color onAccent;
  final Color background;
  final Color card;
  final Color secondaryBackground;
  final Color text;
  final Color textSecondary;
  final Color border;

  static const _darkHighContrast = AppPalette(
    accent: Color(0xFF4DA3FF),
    onAccent: Colors.black,
    background: Colors.black,
    card: Colors.black,
    secondaryBackground: Color(0xFF262626),
    text: Colors.white,
    textSecondary: Color(0xFFE5E5E5),
    border: Colors.white,
  );

  static const _dark = AppPalette(
    accent: Color(0xFF0A84FF),
    onAccent: Colors.white,
    background: Color(0xFF0B1120),
    card: Color(0xFF1E293B),
    secondaryBackground: Color(0xFF334155),
    text: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    border: Color(0xFF334155),
  );

  static const _lightHighContrast = AppPalette(
    accent: Color(0xFF0040DD),
    onAccent: Colors.white,
    background: Colors.white,
    card: Colors.white,
    secondaryBackground: Color(0xFFE5E7EB),
    text: Colors.black,
    textSecondary: Color(0xFF1F2937),
    border: Colors.black,
  );

  static const _light = AppPalette(
    accent: Color(0xFF007AFF),
    onAccent: Colors.white,
    background: Color(0xFFF8FAFC),
    card: Colors.white,
    secondaryBackground: Color(0xFFF1F5F9),
    text: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    border: Color(0xFFE2E8F0),
  );
}
