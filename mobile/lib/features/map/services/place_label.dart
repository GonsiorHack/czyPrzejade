final _noiseSegment = RegExp(r'^(województwo|polska$|\d{2}-\d{3}$)', caseSensitive: false);
final _houseNumber = RegExp(r'^\d+[a-z]?$', caseSensitive: false);
const _cityName = 'Kraków';

/// Segmenty nazwy miejsca bez szumu (województwo, kraj, kod pocztowy).
List<String> _meaningfulParts(String name) => name
    .split(',')
    .map((p) => p.trim())
    .where((p) => p.isNotEmpty && !_noiseSegment.hasMatch(p))
    .toList();

/// Dzieli pełną nazwę miejsca na część główną i opis dodatkowy.
({String primary, String secondary}) splitPlaceName(String name) {
  final parts = _meaningfulParts(name);
  if (parts.isEmpty) return (primary: name, secondary: '');
  return (primary: parts.first, secondary: parts.skip(1).join(', '));
}

/// Krótka etykieta dla pól "Skąd" / "Dokąd", np. "Wawel, Kraków".
String shortPlaceLabel(String name) {
  final parts = _meaningfulParts(name);
  if (parts.isEmpty) return name;
  if (parts.length == 1) return parts.first;
  if (parts.length > 2 && _houseNumber.hasMatch(parts[1])) {
    return '${parts[0]} ${parts[1]}, ${parts[2]}';
  }
  if (parts.contains(_cityName) && parts[0] != _cityName) return '${parts[0]}, $_cityName';
  return '${parts[0]}, ${parts[1]}';
}
