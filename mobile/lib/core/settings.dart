import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_options.dart';

export 'settings_options.dart';

/// Preferencje użytkownika zapisywane lokalnie (`shared_preferences`).
class AppSettings extends ChangeNotifier {
  /// Klucz zachowany z wersji webowej, aby nie utracić zapisanych ustawień.
  static const _storageKey = 'krakow-dostepny:ustawienia';

  AppTheme _theme = AppTheme.dark;
  bool _highContrast = false;
  TextSizeOption _textSize = TextSizeOption.standard;
  MobilityProfile _mobilityProfile = MobilityProfile.manualWheelchair;
  bool _visualTransitAlerts = true;

  AppTheme get theme => _theme;
  bool get highContrast => _highContrast;
  TextSizeOption get textSize => _textSize;
  MobilityProfile get mobilityProfile => _mobilityProfile;
  bool get visualTransitAlerts => _visualTransitAlerts;

  /// Wczytuje zapisane ustawienia; uszkodzone dane są ignorowane.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) return;
      _theme = AppTheme.values.asNameMap()[data['theme']] ?? _theme;
      _textSize = TextSizeOption.values.asNameMap()[data['textSize']] ?? _textSize;
      _mobilityProfile =
          MobilityProfile.values.asNameMap()[data['mobilityProfile']] ?? _mobilityProfile;
      if (data['highContrast'] is bool) _highContrast = data['highContrast'] as bool;
      if (data['visualTransitAlerts'] is bool) {
        _visualTransitAlerts = data['visualTransitAlerts'] as bool;
      }
      notifyListeners();
    } catch (_) {
      // Uszkodzone preferencje pomijamy - zostają wartości domyślne.
    }
  }

  void setTheme(AppTheme value) => _update(() => _theme = value);
  void setHighContrast(bool value) => _update(() => _highContrast = value);
  void setTextSize(TextSizeOption value) => _update(() => _textSize = value);
  void setMobilityProfile(MobilityProfile value) => _update(() => _mobilityProfile = value);
  void setVisualTransitAlerts(bool value) => _update(() => _visualTransitAlerts = value);

  void _update(VoidCallback change) {
    change();
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode({
        'theme': _theme.name,
        'highContrast': _highContrast,
        'textSize': _textSize.name,
        'mobilityProfile': _mobilityProfile.name,
        'visualTransitAlerts': _visualTransitAlerts,
      }),
    );
  }
}
