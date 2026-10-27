import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'accessibility_grade.dart';

enum FacilityCategory {
  museums('Muzea', Icons.museum_outlined),
  sport('Sport', Icons.sports_basketball_outlined),
  monuments('Zabytki', Icons.account_balance_outlined),
  food('Gastronomia', Icons.local_cafe_outlined);

  const FacilityCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum AmenityIcon {
  wheelchair(Icons.accessible),
  lift(Icons.elevator_outlined),
  parking(Icons.local_parking),
  restroom(Icons.wc),
  changingRoom(Icons.bed_outlined),
  ear(Icons.hearing),
  digital(Icons.headphones_outlined);

  const AmenityIcon(this.icon);
  final IconData icon;
}

class FacilityBadge {
  const FacilityBadge(this.label, this.icon);
  final String label;
  final AmenityIcon icon;
}

class AccessibilityDetails {
  const AccessibilityDetails({
    this.parking,
    this.entrance,
    this.verticalTransport,
    this.cloakroom,
    this.restrooms,
    this.equipmentRental,
    this.digitalAccess,
    this.notes,
  });
  final String? parking;
  final String? entrance;
  final String? verticalTransport;
  final String? cloakroom;
  final String? restrooms;
  final String? equipmentRental;
  final String? digitalAccess;
  final String? notes;

  /// Liczba udokumentowanych sekcji dostępności (bez uwag).
  int get documentedCount => [
    parking,
    entrance,
    verticalTransport,
    cloakroom,
    restrooms,
    equipmentRental,
    digitalAccess,
  ].whereType<String>().length;
}

class Facility {
  const Facility({
    required this.id,
    required this.name,
    required this.category,
    required this.distance,
    required this.address,
    required this.verified,
    required this.verifiedSource,
    required this.badges,
    required this.details,
    required this.coordinates,
    required this.rating,
    required this.ratingCount,
    this.photoUrl,
    this.sponsored = false,
  });
  final String id;
  final String name;
  final FacilityCategory category;
  final String distance;
  final String address;
  final bool verified;
  final String verifiedSource;
  final List<FacilityBadge> badges;
  final AccessibilityDetails details;
  final LatLng coordinates;

  /// Ocena użytkowników (1-5) i liczba ocen. Dane demonstracyjne do czasu podpięcia backendu.
  final double rating;
  final int ratingCount;

  /// Miniatura obiektu; gdy brak lub nie da się pobrać, pokazywany jest zastępnik z ikoną.
  final String? photoUrl;

  /// Czy obiekt jest promowany (karta "Sponsorowane" na górze listy).
  final bool sponsored;

  /// Wynik dostępności 0-100: weryfikacja (40/20) + udogodnienia (do 40) + udokumentowane sekcje (do 20).
  int get accessibilityScore {
    final verification = verified ? 40 : 20;
    final amenities = badges.length.clamp(0, 4) * 10;
    final documented = details.documentedCount.clamp(0, 5) * 4;
    return verification + amenities + documented;
  }

  /// Ocena A-F pokazywana w interfejsie zamiast wyniku liczbowego.
  AccessibilityGrade get accessibilityGrade => AccessibilityGrade.fromScore(accessibilityScore);
}
