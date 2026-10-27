// ignore_for_file: prefer_initializing_formals (named parametry nie mogą być prywatne)
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/config.dart';
import '../../../core/navigation_state.dart';
import '../map_strings.dart';
import '../models/route_info.dart';
import '../models/waypoint.dart';
import '../services/api_exception.dart';
import '../services/location_service.dart';
import '../services/map_api.dart';
import '../services/place_label.dart';
import '../services/route_parser.dart';
import '../utils/formatters.dart';
import 'map_effect.dart';

/// Wynik próby ustawienia punktu trasy.
enum _AssignResult { rejected, routing, placed }

/// Logika ekranu mapy: punkty trasy, routing, lokalizacja i nawigacja.
/// Widok reaguje na zmiany stanu (`notifyListeners`) oraz na zdarzenia [effects].
class MapViewModel extends ChangeNotifier {
  MapViewModel({required MapApi api, required LocationService location})
      : _api = api,
        _location = location;

  final MapApi _api;
  final LocationService _location;
  final _effects = StreamController<MapEffect>.broadcast();

  /// Kontrolery pól adresu; ich tekst jest synchronizowany z [start] i [destination].
  final startController = TextEditingController();
  final destinationController = TextEditingController();

  Waypoint? _start;
  Waypoint? _destination;
  List<RouteInfo> _routes = const [];
  String? _activeRouteId;
  bool _identicalRoutes = false;
  bool _navigating = false;
  bool _loading = false;
  bool _locating = false;
  bool _disposed = false;
  LatLng? _userLocation;
  StreamSubscription<LatLng>? _positionSub;

  /// Numer ostatniego zapytania; odpowiedzi ze starszych zapytań są ignorowane.
  int _requestId = 0;

  Stream<MapEffect> get effects => _effects.stream;
  Waypoint? get start => _start;
  Waypoint? get destination => _destination;
  List<RouteInfo> get routes => _routes;
  String? get activeRouteId => _activeRouteId;
  bool get identicalRoutes => _identicalRoutes;
  bool get navigating => _navigating;
  bool get loading => _loading;
  bool get locating => _locating;
  LatLng? get userLocation => _userLocation;

  /// Aktywna trasa; gdy nic nie wybrano, pierwsza z listy.
  RouteInfo? get activeRoute {
    for (final route in _routes) {
      if (route.id == _activeRouteId) return route;
    }
    return _routes.isEmpty ? null : _routes.first;
  }

  /// Podpowiedź wyświetlana nad mapą (pusta, gdy nie jest potrzebna).
  String get hint {
    if (_loading) return MapStrings.hintRouting;
    if (_start == null && _destination == null) return MapStrings.hintPickStart;
    if (_start == null) return MapStrings.hintStartOnly;
    if (_destination == null) return MapStrings.hintPickDestination;
    final active = activeRoute;
    if (_navigating && active != null) {
      return MapStrings.hintNavigating(formatDuration(active.durationMinutes));
    }
    return '';
  }

  // ------------------------------------------------------------ punkty trasy

  /// Dotknięcie mapy ustawia najpierw punkt A, potem B.
  void onMapTap(LatLng point) {
    if (_loading) return;
    final waypoint = Waypoint(point, MapStrings.mapPointLabel);
    if (_start == null) {
      _assign(WaypointKind.start, waypoint);
    } else if (_destination == null) {
      _assign(WaypointKind.destination, waypoint);
    }
  }

  /// Długie przytrzymanie przesuwa najbliższy znacznik (zamiast dragowania).
  void onMapLongPress(LatLng point) {
    if (_loading || (_start == null && _destination == null)) return;
    final kind = _nearestWaypoint(point);
    _assign(kind, Waypoint(point, MapStrings.mapPointLabel));
  }

  /// Geokoduje adres wpisany w polu i ustawia odpowiedni punkt trasy.
  Future<void> submitAddress(WaypointKind kind, String text) async {
    final query = text.trim();
    if (query.length < 3) {
      _message(MapStrings.addressTooShort);
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    _setLoading(true);
    try {
      final results = await _api.geocode(query);
      if (_disposed) return;
      _setLoading(false);
      if (results.isEmpty) {
        _message(MapStrings.addressNotFound);
        return;
      }
      final place = results.first;
      final result = _assign(kind, Waypoint(place.point, shortPlaceLabel(place.name)));
      if (result == _AssignResult.placed) {
        _emit(MoveCamera(place.point, zoom: AppConfig.defaultZoom));
      }
    } on ApiException {
      if (_disposed) return;
      _setLoading(false);
      _message(MapStrings.connectionLost);
    }
  }

  /// Czyści punkty, trasy i zatrzymuje nawigację.
  void reset() {
    _requestId++;
    _stopNavigation();
    _start = null;
    _destination = null;
    _routes = const [];
    _activeRouteId = null;
    _identicalRoutes = false;
    _loading = false;
    startController.clear();
    destinationController.clear();
    notifyListeners();
  }

  // ----------------------------------------------------------------- routing

  void selectRoute(String id) {
    if (_routes.any((r) => r.id == id)) {
      _activeRouteId = id;
      notifyListeners();
    }
  }

  Future<void> _requestRoutes() async {
    final start = _start;
    final destination = _destination;
    if (start == null || destination == null) return;

    final id = ++_requestId;
    _stopNavigation();
    _routes = const [];
    _activeRouteId = null;
    _setLoading(true);

    try {
      final fetched = await _api.fetchRouteComparison(start.point, destination.point);
      if (_disposed || id != _requestId) return;
      final collapsed = collapseIdenticalRoutes(fetched);
      _routes = collapsed.routes;
      _identicalRoutes = collapsed.identical;
      _activeRouteId = collapsed.routes.first.id;
      _loading = false;
      notifyListeners();
      _emit(const FitRoutes());
      if (collapsed.routes.first.offline) _message(MapStrings.offlineDemo);
    } on ApiException catch (e) {
      if (_disposed || id != _requestId) return;
      _setLoading(false);
      _message(e.kind == ApiErrorKind.noRoute ? MapStrings.routeNotFound : MapStrings.connectionLost);
    }
  }

  // -------------------------------------------------------------- lokalizacja

  /// Centruje mapę na pozycji użytkownika (tylko w granicach Krakowa).
  Future<void> centerOnUser() async {
    final point = await _locate();
    if (point == null || _disposed) return;
    if (!AppConfig.krakowBounds.contains(point)) {
      _message(MapStrings.outsideKrakow);
      _recenterFallback();
      return;
    }
    _emit(MoveCamera(point, zoom: AppConfig.userLocationZoom, keepHigherZoom: true));
  }

  /// Ustawia bieżącą lokalizację jako punkt startowy.
  Future<void> useLocationAsStart() async {
    final point = await _locate();
    if (point == null || _disposed) return;
    if (!AppConfig.krakowBounds.contains(point)) {
      _message(MapStrings.outsideKrakow);
      return;
    }
    final result = _assign(WaypointKind.start, Waypoint(point, MapStrings.userLocationLabel));
    if (result == _AssignResult.placed) {
      _emit(MoveCamera(point, zoom: AppConfig.userLocationZoom));
    }
  }

  /// Cel wybrany w "Odkrywaj" ("Nawiguj"): start z lokalizacji użytkownika, jeśli dostępna.
  Future<void> navigateTo(NavigationTarget target) async {
    reset();
    _setWaypoint(WaypointKind.destination, Waypoint(target.point, target.name));
    final user = _userLocation ?? await _locate();
    if (_disposed) return;
    final canStartFromUser =
        user != null && AppConfig.krakowBounds.contains(user) && !_tooClose(user, target.point);
    _setWaypoint(
      WaypointKind.start,
      canStartFromUser
          ? Waypoint(user, MapStrings.userLocationLabel)
          : const Waypoint(AppConfig.fallbackStart, AppConfig.fallbackStartLabel),
    );
    unawaited(_requestRoutes());
  }

  // ---------------------------------------------------------------- nawigacja

  Future<void> toggleNavigation() async {
    if (_navigating) {
      _stopNavigation();
      notifyListeners();
      return;
    }
    final Stream<LatLng> positions;
    try {
      positions = await _location.track();
    } on LocationException catch (e) {
      _message(_locationMessage(e.failure));
      return;
    }
    if (_disposed) return;

    _navigating = true;
    notifyListeners();
    _positionSub = positions.listen(
      _onNavigationPosition,
      onError: (_) => _message(MapStrings.gpsLost),
    );
    final active = activeRoute;
    if (active != null) {
      _emit(MoveCamera(active.coordinates.first, zoom: AppConfig.navigationZoom));
    }
  }

  void _onNavigationPosition(LatLng point) {
    _userLocation = point;
    notifyListeners();
    if (_navigating) {
      _emit(MoveCamera(point, zoom: AppConfig.navigationZoom, animated: false));
    }
  }

  void _stopNavigation() {
    _positionSub?.cancel();
    _positionSub = null;
    _navigating = false;
  }

  // ---------------------------------------------------------------- pomocnicze

  /// Ustawia punkt, jeśli nie koliduje z drugim; uruchamia routing, gdy są oba punkty.
  _AssignResult _assign(WaypointKind kind, Waypoint waypoint) {
    final other = kind == WaypointKind.start ? _destination : _start;
    if (other != null && _tooClose(waypoint.point, other.point)) {
      _message(MapStrings.pointsTooClose);
      return _AssignResult.rejected;
    }
    _setWaypoint(kind, waypoint);
    if (_start != null && _destination != null) {
      unawaited(_requestRoutes());
      return _AssignResult.routing;
    }
    return _AssignResult.placed;
  }

  void _setWaypoint(WaypointKind kind, Waypoint waypoint) {
    switch (kind) {
      case WaypointKind.start:
        _start = waypoint;
        startController.text = waypoint.label;
      case WaypointKind.destination:
        _destination = waypoint;
        destinationController.text = waypoint.label;
    }
    notifyListeners();
  }

  WaypointKind _nearestWaypoint(LatLng point) {
    final start = _start;
    final destination = _destination;
    if (start == null) return WaypointKind.destination;
    if (destination == null) return WaypointKind.start;
    const distance = Distance();
    return distance(point, start.point) <= distance(point, destination.point)
        ? WaypointKind.start
        : WaypointKind.destination;
  }

  bool _tooClose(LatLng a, LatLng b) =>
      const Distance().as(LengthUnit.Meter, a, b) < AppConfig.minRouteDistanceMeters;

  Future<LatLng?> _locate() async {
    if (_locating) return null;
    _locating = true;
    notifyListeners();
    try {
      final point = await _location.currentPosition();
      if (!_disposed) _userLocation = point;
      return point;
    } on LocationException catch (e) {
      _message(_locationMessage(e.failure));
      return null;
    } finally {
      if (!_disposed) {
        _locating = false;
        notifyListeners();
      }
    }
  }

  String _locationMessage(LocationFailure failure) => switch (failure) {
        LocationFailure.serviceDisabled => MapStrings.locationDisabled,
        LocationFailure.permissionDenied => MapStrings.locationDenied,
        LocationFailure.unavailable => MapStrings.locationUnavailable,
      };

  /// Gdy użytkownik jest poza Krakowem: wróć do tras, startu albo centrum miasta.
  void _recenterFallback() {
    if (_routes.isNotEmpty) {
      _emit(const FitRoutes());
    } else {
      _emit(MoveCamera(_start?.point ?? AppConfig.krakowCenter, zoom: AppConfig.defaultZoom));
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _message(String text) => _emit(ShowMessage(text));

  void _emit(MapEffect effect) {
    if (!_disposed && !_effects.isClosed) _effects.add(effect);
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _positionSub?.cancel();
    _effects.close();
    startController.dispose();
    destinationController.dispose();
    _api.dispose();
    super.dispose();
  }
}
