/// Teksty UI panelu "Odkrywaj" (po polsku).
abstract final class DiscoverStrings {
  static const title = 'Odkrywaj';
  static const subtitle = 'Zweryfikowane miejsca dostępne dla wszystkich.';
  static const allCategories = 'Wszystkie';
  static const verifiedOnly = 'Zweryfikowane';
  static const routeTo = 'Wyznacz trasę';
  static const close = 'Zamknij';
  static const accessibilityLabel = 'Dostępność';
  static String accessibilityGradeSemantics(String letter) => 'Dostępność: ocena $letter';
  static const sponsored = 'Sponsorowane';
  static String noPlacesInCity(String city) => 'Brak zweryfikowanych miejsc w mieście: $city.';
  static const noPlacesHint = 'Zmień miasto w Ustawieniach lub wybierz inne filtry.';
  static String ratingSemantics(String rating, String count) =>
      'Ocena $rating na 5, liczba ocen: $count';
  static const emptyTitle = 'Brak pasujących miejsc';
  static const emptyHint = 'Zmień filtry, aby zobaczyć więcej miejsc.';
  static String verifiedBy(String source) => 'Zweryfikowane: $source';

  // Arkusz szczegółów
  static const sectionParking = 'Parking i dojazd';
  static const sectionEntrance = 'Wejście i ciągi komunikacyjne';
  static const sectionVertical = 'Komunikacja pionowa (windy / platformy)';
  static const sectionCloakroom = 'Szatnie i obsługa klienta';
  static const sectionRestrooms = 'Toalety i komfortki';
  static const sectionEquipment = 'Wypożyczalnia sprzętu i udogodnienia cyfrowe';
  static const importantNotes = 'Ważne informacje';
}
