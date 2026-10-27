import 'package:flutter/material.dart';

/// Kolory aplikacji, które nie mieszczą się w [ColorScheme].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.routeAccessible,
    required this.routeStandard,
    required this.routeInactive,
    required this.userLocation,
    required this.brand,
    required this.markerStartFill,
    required this.markerStartText,
    required this.markerEndFill,
    required this.success,
    required this.successBg,
    required this.caution,
    required this.cautionBg,
    required this.ratingStar,
    required this.scrim,
    required this.activeRouteWidth,
    required this.inactiveRouteWidth,
  });

  /// Wariant zależny od trybu ciemnego i wysokiego kontrastu.
  factory AppColors.resolve({required bool dark, required bool highContrast}) {
    return AppColors(
      routeAccessible: highContrast ? const Color(0xFF0040DD) : const Color(0xFF007AFF),
      routeStandard: highContrast ? const Color(0xFF5B21B6) : const Color(0xFF7C3AED),
      routeInactive: highContrast ? const Color(0xFF4B5563) : const Color(0xFF94A3B8),
      userLocation: const Color(0xFF0EA5E9),
      brand: const Color(0xFF3063AB),
      markerStartFill: Colors.white,
      markerStartText: highContrast ? Colors.black : const Color(0xFF3063AB),
      markerEndFill: highContrast ? const Color(0xFF0040DD) : const Color(0xFF3063AB),
      success: dark
          ? const Color(0xFF4ADE80)
          : (highContrast ? const Color(0xFF006B1F) : const Color(0xFF15803D)),
      successBg: dark
          ? const Color(0xFF052E16)
          : (highContrast ? Colors.white : const Color(0xFFF0FDF4)),
      caution: dark
          ? const Color(0xFFFCD34D)
          : (highContrast ? Colors.black : const Color(0xFF92400E)),
      cautionBg: dark
          ? const Color(0xFF451A03)
          : (highContrast ? Colors.white : const Color(0xFFFEF3C7)),
      ratingStar: highContrast ? const Color(0xFFB45309) : const Color(0xFFF59E0B),
      scrim: dark ? const Color(0xA6000000) : const Color(0x800F172A),
      activeRouteWidth: highContrast ? 7 : 6,
      inactiveRouteWidth: highContrast ? 6 : 5,
    );
  }

  final Color routeAccessible;
  final Color routeStandard;
  final Color routeInactive;
  final Color userLocation;
  final Color brand;
  final Color markerStartFill;
  final Color markerStartText;
  final Color markerEndFill;
  final Color success;
  final Color successBg;
  final Color caution;
  final Color cautionBg;
  final Color ratingStar;
  final Color scrim;
  final double activeRouteWidth;
  final double inactiveRouteWidth;

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) => this;
}

extension AppColorsContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
