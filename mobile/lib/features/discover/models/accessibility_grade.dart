import 'package:flutter/material.dart';

/// Ocena dostępności w skali A-F (`accessibilityGrade`) wyliczana z wyniku 0-100.
/// Kolory mają wysoki kontrast względem białego tekstu: od szmaragdowego (A) do czerwonego (F).
enum AccessibilityGrade {
  a('A', 85, Color(0xFF047857)),
  b('B', 70, Color(0xFF4D7C0F)),
  c('C', 55, Color(0xFFA16207)),
  d('D', 40, Color(0xFFC2410C)),
  e('E', 25, Color(0xFFB91C1C)),
  f('F', 0, Color(0xFF7F1D1D));

  const AccessibilityGrade(this.letter, this.minScore, this.color);

  final String letter;

  /// Dolna granica przedziału (włącznie) dla wyniku 0-100.
  final int minScore;
  final Color color;

  /// Mapuje wynik 0-100 na ocenę; wartości spoza zakresu są obcinane.
  static AccessibilityGrade fromScore(int score) {
    for (final grade in values) {
      if (score >= grade.minScore) return grade;
    }
    return f;
  }
}
