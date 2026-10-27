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
      borderRadius: BorderRadius.circular(Radii.md),
      borderSide: side,
    );
    const minTarget = Size(TouchTargets.min, TouchTargets.min);
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm));

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md), side: side),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(minimumSize: minTarget)),
      chipTheme: ChipThemeData(
        side: side,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.sm),
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
          minimumSize: minTarget,
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.text,
          side: side,
          minimumSize: minTarget,
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: minTarget, shape: buttonShape),
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
