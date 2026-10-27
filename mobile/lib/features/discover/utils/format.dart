/// Ocena z polskim separatorem dziesiętnym, np. `4,7`.
String formatRating(double rating) => rating.toStringAsFixed(1).replaceAll('.', ',');

/// Liczba ocen z twardą spacją jako separatorem tysięcy, np. `18 432`.
String formatCount(int count) {
  final digits = count.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('\u00A0');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
