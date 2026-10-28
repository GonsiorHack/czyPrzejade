/// Formatuje dystans: metry poniżej 1 km, w przeciwnym razie kilometry z przecinkiem.
String formatDistance(double meters) => meters < 1000
    ? '${meters.round()} m'
    : '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';

/// Formatuje czas przejazdu (minimum 1 min), np. "45 min" lub "1 h 5 min".
String formatDuration(double minutes) {
  final total = minutes.round().clamp(1, 1 << 30);
  return total < 60 ? '$total min' : '${total ~/ 60} h ${total % 60} min';
}
