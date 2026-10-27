import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum FacilityCategory {
  museums('Muzea', Icons.museum_outlined),
  sport('Sport', Icons.sports_basketball_outlined),
  monuments('Zabytki', Icons.account_balance_outlined);

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
}

