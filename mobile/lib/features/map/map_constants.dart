import 'package:flutter/material.dart';

/// Stałe liczbowe i kolory warstwy mapy (poza konfiguracją środowiskową z `AppConfig`).
abstract final class MapConstants {
  static const double minZoom = 3;
  static const double maxZoom = 19;
  static const double fitMaxZoom = 18;
  static const double zoomStep = 1;

  /// Kolor tła widoczny pod kafelkami, zanim się załadują.
  static const backgroundColor = Color(0xFFE2E8F0);

  /// Margines (padding) kamery przy dopasowaniu do tras; góra i dół omijają panele UI.
  static const fitPadding = EdgeInsets.fromLTRB(40, 220, 40, 360);

  /// Minimalny obszar trafienia (hitbox) polilinii, wygodny dla palca.
  static const double routeHitbox = 24;

  /// Filtr dystansu strumienia GPS podczas nawigacji (metry).
  static const int gpsDistanceFilterMeters = 5;

  /// Minimalna długość adresu przed wysłaniem zapytania geokodowania.
  static const int minAddressLength = 3;

  static const double userMarkerSize = 22;

  /// Rozmiar znacznika użytkownika z wachlarzem kierunku (stożek jest większy niż kropka).
  static const double userHeadingMarkerSize = 72;

  /// Poniżej tego zoomu znaczniki obiektów są ukryte, aby nie zaśmiecać mapy.
  static const double facilityMinZoom = 13;
  static const double routeDotSize = 12;
  static const double waypointMarkerSize = 36;
  static const double facilityMarkerSize = 32;
  static const double waypointBadgeSize = 32;
  static const double plannerBadgeSize = 26;
  static const double attributionFontSize = 10;

  /// Krycie tła atrybucji: mapa pod spodem pozostaje czytelna.
  static const double attributionOpacity = 0.45;
}
