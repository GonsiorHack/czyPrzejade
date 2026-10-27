/// Rodzaj błędu zwracanego przez [MapApi].
enum ApiErrorKind { noRoute, network, server }

class ApiException implements Exception {
  ApiException(this.kind, this.message);
  final ApiErrorKind kind;

  /// Komunikat techniczny (dla logów), nie jest pokazywany użytkownikowi.
  final String message;

  @override
  String toString() => 'ApiException($kind): $message';
}
