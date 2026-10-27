import 'package:flutter/material.dart';

import '../../core/settings.dart';
import '../design_tokens.dart';
import 'app_colors.dart';
import 'app_palette.dart';

/// Buduje [ThemeData] na podstawie ustawień użytkownika.
abstract final class AppThemeFactory {
  static ThemeData build(AppTheme mode, {required bool highContrast}) {
    final dark = mode == AppTheme.dark;
    final palette = AppPalette.resolve(dark: dark, highContrast: highContrast);
    final colors = AppColors.resolve(dark: dark, highContrast: highContrast);

    final scheme = ColorScheme(
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: palette.accent,
      onPrimary: palette.onAccent,
      secondary: palette.accent,
      onSecondary: palette.onAccent,
      error: dark ? const Color(0xFFFECACA) : const Color(0xFF991B1B),
      onError: dark ? Colors.black : Colors.white,
      surface: palette.card,
      onSurface: palette.text,
      onSurfaceVariant: palette.textSecondary,
      surfaceContainerHighest: palette.secondaryBackground,
      outline: palette.border,
      outlineVariant: palette.border,
    );

    final side = BorderSide(color: palette.border, width: highContrast ? 2 : 1);
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: side,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      extensions: [colors],
      dividerColor: palette.border,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.card,
        foregroundColor: palette.text,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: palette.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: side,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.card,
        indicatorColor: palette.accent.withValues(alpha: 0.2),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: palette.text, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? palette.accent : palette.textSecondary,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        side: side,
        backgroundColor: palette.card,
        selectedColor: palette.accent,
        labelStyle: TextStyle(color: palette.text),
        secondaryLabelStyle: TextStyle(color: palette.onAccent),
        checkmarkColor: palette.onAccent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: palette.onAccent,
          minimumSize: const Size(TouchTargets.min, TouchTargets.min),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.card,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: palette.accent, width: 2),
        ),
      ),
    );
  }
}
