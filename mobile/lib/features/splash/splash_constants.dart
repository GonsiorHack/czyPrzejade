import 'package:flutter/painting.dart' show Alignment;

/// Stałe i teksty ekranu startowego (intro wideo).
abstract final class SplashConstants {
  static const asset = 'assets/media/intro.mp4';

  /// Po tylu sekundach bez postępu odtwarzania intro uznajemy za nieudane.
  static const stallTimeout = Duration(seconds: 12);

  /// Częstotliwość sprawdzania, czy wideo się nie zawiesiło.
  static const stallCheckInterval = Duration(milliseconds: 200);

  /// Margines końca wideo, po którym splash się kończy (kompensuje niedokładność pozycji).
  static const endMargin = Duration(milliseconds: 80);

  static const brandFontSize = 44.0;

  /// Pionowe wyrównanie kart statusu względem środka ekranu.
  static const statusAlignment = Alignment(0, 0.3);
}

abstract final class SplashStrings {
  static const loading = 'Ładowanie intro…';
  static const failed = 'Nie udało się załadować intro. Spróbuj ponownie lub wybierz „Pomiń”.';
  static const retry = 'Spróbuj ponownie';
  static const skip = 'Pomiń';
}
