import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../app/config.dart';
import '../../../app/design_tokens.dart';
import '../map_constants.dart';
import '../map_strings.dart';
import '../models/geocode_result.dart';
import '../models/route_info.dart';
import 'api_exception.dart';
import 'route_parser.dart';

const _demoRoutesAsset = 'assets/data/demo_routes.json';

const _headers = {
  'Accept': 'application/geo+json, application/json',
  // Darmowe tunele ngrok zwracają stronę HTML z ostrzeżeniem bez tego nagłówka.
  'ngrok-skip-browser-warning': 'true',
};

/// Klient istniejącego backendu FastAPI (trasy + geokodowanie).
class MapApi {
  MapApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  /// Pobiera równolegle trasę dostępną i standardową.
  /// Gdy serwer jest nieosiągalny, wraca do wbudowanej trasy demo.
  Future<List<RouteInfo>> fetchRouteComparison(LatLng start, LatLng destination) async {
    if (AppConfig.apiBase.isEmpty) {
      await Future<void>.delayed(AppDurations.demoLatency);
      return loadOfflineDemoRoutes();
    }

    final results = await Future.wait([
      _settle(() => _requestRoute(AppConfig.apiAccessibleRoute, start, destination)),
      _settle(() => _requestRoute(AppConfig.apiStandardRoute, start, destination)),
    ]);

    final routes = <RouteInfo>[];
    final errors = <ApiException>[];
    for (final result in results) {
      final error = result.error;
      if (error != null) {
        errors.add(error);
      } else {
        routes.addAll(parseRouteResponse(result.value));
      }
    }

    if (routes.isNotEmpty) {
      sortAccessibleFirst(routes);
      return [
        for (var i = 0; i < routes.length; i++) routes[i].copyWith(id: '${routes[i].routeType}-$i'),
      ];
    }

    final error = _mostRelevantError(errors);
    if (error.kind == ApiErrorKind.noRoute) throw error;
    return loadOfflineDemoRoutes();
  }

  /// Wczytuje zapisane trasy demonstracyjne z assetów.
  Future<List<RouteInfo>> loadOfflineDemoRoutes() async {
    final raw = await rootBundle.loadString(_demoRoutesAsset);
    final routes = parseRouteResponse(jsonDecode(raw));
    return [for (final r in routes) r.copyWith(offline: true)];
  }

  /// Zwraca pasujące miejsca w Krakowie lub pustą listę, gdy nic nie znaleziono.
  Future<List<GeocodeResult>> geocode(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < MapConstants.minAddressLength) return const [];
    if (AppConfig.apiBase.isEmpty) {
      throw ApiException(ApiErrorKind.network, MapStrings.serverNotConfigured);
    }
    final uri = Uri.parse('${AppConfig.apiBase}${AppConfig.apiGeocode}')
        .replace(queryParameters: {'query': trimmed});
    try {
      return _parseGeocode(await _getJson(uri));
    } on ApiException catch (e) {
      if (e.kind == ApiErrorKind.noRoute) return const [];
      rethrow;
    }
  }

  void dispose() => _client.close();

  // --------------------------------------------------------------- prywatne

  /// Błąd o najwyższym priorytecie: brak trasy > sieć > serwer.
  ApiException _mostRelevantError(List<ApiException> errors) {
    const priority = [ApiErrorKind.noRoute, ApiErrorKind.network, ApiErrorKind.server];
    if (errors.isEmpty) {
      return ApiException(ApiErrorKind.noRoute, 'Backend returned no usable route');
    }
    final sorted = [...errors]..sort((a, b) => priority.indexOf(a.kind) - priority.indexOf(b.kind));
    return sorted.first;
  }

  Future<dynamic> _requestRoute(String path, LatLng start, LatLng end) {
    final uri = Uri.parse('${AppConfig.apiBase}$path').replace(
      queryParameters: {
        'start_lng': '${start.longitude}',
        'start_lat': '${start.latitude}',
        'end_lng': '${end.longitude}',
        'end_lat': '${end.latitude}',
      },
    );
    return _getJson(uri);
  }

  List<GeocodeResult> _parseGeocode(dynamic json) {
    final items = json is List ? json : [json];
    final seen = <String>{};
    final results = <GeocodeResult>[];
    for (final item in items) {
      if (item is! Map) continue;
      final name = item['name'];
      final lat = item['lat'];
      final lng = item['lng'];
      if (name is! String || name.trim().isEmpty || lat is! num || lng is! num) continue;
      final key = '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}';
      if (seen.add(key)) {
        results.add(GeocodeResult(name: name, lat: lat.toDouble(), lng: lng.toDouble()));
      }
    }
    return results;
  }

  Future<dynamic> _getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri, headers: _headers).timeout(AppDurations.apiTimeout);
    } on TimeoutException {
      throw ApiException(ApiErrorKind.network, 'Server timed out');
    } catch (e) {
      throw ApiException(ApiErrorKind.network, 'Network error: $e');
    }

    final json = _tryDecode(response);
    if (response.statusCode != 200) throw _errorFor(response.statusCode, json);
    if (json == null) throw ApiException(ApiErrorKind.server, 'Server returned non-JSON');
    return json;
  }

  dynamic _tryDecode(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      return null;
    }
  }

  ApiException _errorFor(int statusCode, dynamic json) {
    final detail = json is Map ? json['detail'] : null;
    // JSON `detail` przy 400/404 oznacza, że backend nie połączył punktów lub nie znalazł miejsca.
    final notFound = (statusCode == 400 || statusCode == 404) && detail is String;
    return notFound
        ? ApiException(ApiErrorKind.noRoute, detail)
        : ApiException(ApiErrorKind.server, 'Server responded with $statusCode');
  }
}

/// Wynik wywołania, który nie rzuca wyjątku (potrzebny przy `Future.wait`).
class _Settled {
  _Settled(this.value, this.error);
  final dynamic value;
  final ApiException? error;
}

Future<_Settled> _settle(Future<dynamic> Function() action) async {
  try {
    return _Settled(await action(), null);
  } on ApiException catch (e) {
    return _Settled(null, e);
  } catch (e) {
    return _Settled(null, ApiException(ApiErrorKind.server, '$e'));
  }
}
