import 'package:latlong2/latlong.dart';

/// Polskie miasto dostępne jako "Domyślne miasto" w ustawieniach.
class PolishCity {
  const PolishCity(this.name, this.center);
  final String name;
  final LatLng center;
}

/// Lista miast (duże ośrodki wojewódzkie i powiatowe); alfabetycznie po polsku nie jest wymagane,
/// kolejność odpowiada wielkości miast.
const polishCities = <PolishCity>[
  PolishCity('Kraków', LatLng(50.0614, 19.9372)),
  PolishCity('Warszawa', LatLng(52.2297, 21.0122)),
  PolishCity('Łódź', LatLng(51.7592, 19.4560)),
  PolishCity('Wrocław', LatLng(51.1079, 17.0385)),
  PolishCity('Poznań', LatLng(52.4064, 16.9252)),
  PolishCity('Gdańsk', LatLng(54.3520, 18.6466)),
  PolishCity('Szczecin', LatLng(53.4285, 14.5528)),
  PolishCity('Bydgoszcz', LatLng(53.1235, 18.0084)),
  PolishCity('Lublin', LatLng(51.2465, 22.5684)),
  PolishCity('Białystok', LatLng(53.1325, 23.1688)),
  PolishCity('Katowice', LatLng(50.2649, 19.0238)),
  PolishCity('Gdynia', LatLng(54.5189, 18.5305)),
  PolishCity('Częstochowa', LatLng(50.8118, 19.1203)),
  PolishCity('Radom', LatLng(51.4027, 21.1471)),
  PolishCity('Rzeszów', LatLng(50.0412, 21.9991)),
  PolishCity('Toruń', LatLng(53.0138, 18.5984)),
  PolishCity('Sosnowiec', LatLng(50.2863, 19.1041)),
  PolishCity('Kielce', LatLng(50.8661, 20.6286)),
  PolishCity('Gliwice', LatLng(50.2945, 18.6714)),
  PolishCity('Olsztyn', LatLng(53.7784, 20.4801)),
  PolishCity('Bielsko-Biała', LatLng(49.8224, 19.0584)),
  PolishCity('Zielona Góra', LatLng(51.9356, 15.5062)),
  PolishCity('Rybnik', LatLng(50.0971, 18.5463)),
  PolishCity('Opole', LatLng(50.6751, 17.9213)),
  PolishCity('Tarnów', LatLng(50.0121, 20.9858)),
  PolishCity('Płock', LatLng(52.5463, 19.7065)),
  PolishCity('Elbląg', LatLng(54.1522, 19.4088)),
  PolishCity('Wałbrzych', LatLng(50.7714, 16.2843)),
  PolishCity('Gorzów Wielkopolski', LatLng(52.7368, 15.2288)),
  PolishCity('Koszalin', LatLng(54.1943, 16.1721)),
  PolishCity('Nowy Sącz', LatLng(49.6249, 20.6915)),
  PolishCity('Zakopane', LatLng(49.2992, 19.9496)),
];

/// Miasto domyślne (zgodne z dotychczasowym zachowaniem aplikacji).
final defaultCity = polishCities.first;

PolishCity cityByName(String? name) =>
    polishCities.firstWhere((c) => c.name == name, orElse: () => defaultCity);

const _diacritics = {
  'ą': 'a', 'ć': 'c', 'ę': 'e', 'ł': 'l', 'ń': 'n', 'ó': 'o', 'ś': 's', 'ź': 'z', 'ż': 'z', //
};

/// Normalizuje tekst do wyszukiwania: małe litery bez polskich znaków diakrytycznych.
String normalizeForSearch(String text) =>
    text.toLowerCase().split('').map((c) => _diacritics[c] ?? c).join();

/// Miasta pasujące do zapytania (puste zapytanie zwraca wszystkie).
List<PolishCity> searchCities(String query) {
  final q = normalizeForSearch(query.trim());
  if (q.isEmpty) return polishCities;
  return polishCities.where((c) => normalizeForSearch(c.name).contains(q)).toList();
}
