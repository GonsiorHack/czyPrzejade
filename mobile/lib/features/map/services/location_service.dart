import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/design_tokens.dart';
import '../map_constants.dart';

/// Powód, dla którego nie udało się uzyskać lokalizacji.
enum LocationFailure { serviceDisabled, permissionDenied, unavailable }

class LocationException implements Exception {
  const LocationException(this.failure);
  final LocationFailure failure;

  @override
  String toString() => 'LocationException($failure)';
}

/// Pozycja GPS z kierunkiem ruchu ([heading] w stopniach od północy, null gdy nieznany).
class GpsFix {
  const GpsFix(this.point, this.heading);
  final LatLng point;
  final double? heading;
}

/// Cienka warstwa nad `geolocator`: uprawnienia, pozycja jednorazowa i strumień GPS.
class LocationService {
  /// Pobiera bieżącą pozycję; rzuca [LocationException] przy braku zgody lub sygnału.
  Future<LatLng> currentPosition() async {
    await _ensurePermission();
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: AppDurations.locationTimeout,
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      throw const LocationException(LocationFailure.unavailable);
    }
  }

  /// Strumień pozycji na czas nawigacji; uprawnienia są sprawdzane przed startem.
  Future<Stream<GpsFix>> track() async {
    await _ensurePermission();
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: MapConstants.gpsDistanceFilterMeters,
      ),
    ).map((p) => GpsFix(LatLng(p.latitude, p.longitude), p.heading >= 0 ? p.heading : null));
  }

  Future<void> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationFailure.serviceDisabled);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    final denied =
        permission == LocationPermission.denied || permission == LocationPermission.deniedForever;
    if (denied) throw const LocationException(LocationFailure.permissionDenied);
  }
}
