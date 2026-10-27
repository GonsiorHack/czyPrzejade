import 'package:flutter/material.dart';

/// Odstępy (spacing) używane w całej aplikacji.
abstract final class Spacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Promienie zaokrągleń (border radius).
abstract final class Radii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 999;
}

/// Czasy animacji, timeoutów i symulowanych opóźnień.
abstract final class AppDurations {
  static const fade = Duration(milliseconds: 300);
  static const fadeFast = Duration(milliseconds: 150);
  static const sheetResize = Duration(milliseconds: 280);
  static const cameraMove = Duration(milliseconds: 600);
  static const apiTimeout = Duration(seconds: 10);
  static const demoLatency = Duration(milliseconds: 400);
  static const locationTimeout = Duration(seconds: 10);
  static const photoProcessing = Duration(seconds: 2);
}

/// Kolory cieni i półprzezroczystych nakładek niezależne od motywu.
abstract final class AppShadows {
  static const overlay = Color(0x2E0F172A);
  static const marker = Color(0x590F172A);
  static const chromeOverlay = Color(0x990F172A);
}

/// Minimalne rozmiary elementów dotykowych (a11y).
abstract final class TouchTargets {
  static const double min = 48;
}
