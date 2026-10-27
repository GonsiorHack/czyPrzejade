import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum FacilityCategory {
  museums('Muzea', Icons.museum_outlined),
  sport('Sport', Icons.sports_basketball_outlined),
  zabytki('Zabytki', Icons.account_balance_outlined);

  const FacilityCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum AmenityIcon {
  wheelchair(Icons.accessible),
  lift(Icons.elevator_outlined),
  parking(Icons.local_parking),
  restroom(Icons.wc),
  changingRoom(Icons.bed_outlined),
  ear(Icons.hearing),
  digital(Icons.headphones_outlined);

  const AmenityIcon(this.icon);
  final IconData icon;
}

class FacilityBadge {
  const FacilityBadge(this.label, this.icon);
  final String label;
  final AmenityIcon icon;
}

class AccessibilityDetails {
  const AccessibilityDetails({
    this.parking,
    this.entrance,
    this.verticalTransport,
    this.cloakroom,
    this.restrooms,
    this.equipmentRental,
    this.digitalAccess,
    this.notes,
  });
  final String? parking;
  final String? entrance;
  final String? verticalTransport;
  final String? cloakroom;
  final String? restrooms;
  final String? equipmentRental;
  final String? digitalAccess;
  final String? notes;
}

class Facility {
  const Facility({
    required this.id,
    required this.name,
    required this.category,
    required this.distance,
    required this.address,
    required this.verified,
    required this.verifiedSource,
    required this.badges,
    required this.details,
    required this.coordinates,
  });
  final String id;
  final String name;
  final FacilityCategory category;
  final String distance;
  final String address;
  final bool verified;
  final String verifiedSource;
  final List<FacilityBadge> badges;
  final AccessibilityDetails details;
  final LatLng coordinates;
}

const facilities = <Facility>[
  Facility(
    id: 'tauron-arena',
    name: 'TAURON Arena Kraków',
    category: FacilityCategory.sport,
    distance: '110 m',
    address: 'ul. Stanisława Lema 7',
    verified: true,
    verifiedSource: 'Audyt Miejski UMK & Operator Areny 2026',
    badges: [
      FacilityBadge('Wejście bezprogowe', AmenityIcon.wheelchair),
      FacilityBadge("Windy z Braille'em", AmenityIcon.lift),
      FacilityBadge('Parking OzN', AmenityIcon.parking),
      FacilityBadge('Toalety z SOS', AmenityIcon.restroom),
    ],
    coordinates: LatLng(50.06757, 19.99149),
    details: AccessibilityDetails(
      parking:
          'Dedykowany parking podziemny (wjazd bramą nr 2) z oznakowanymi kopertami bezpośrednio przy windach.',
      entrance:
          'Wejścia bezprogowe przez bramę 1 i 3, automatyczne drzwi przesuwne, obniżone barierki kontroli biletowej.',
      verticalTransport:
          "Szybkie windy towarowo-osobowe z zapowiedziami głosowymi i oznaczeniami w alfabecie Braille'a.",
      restrooms: 'Dostosowane toalety na każdym poziomie z systemem powiadamiania ratunkowego SOS.',
      notes:
          'Widownia: specjalne platformy dla wózków inwalidzkich na poziomie płyty oraz sektora A z asystą stewardów.',
    ),
  ),
  Facility(
    id: 'mnk-gmach-glowny',
    name: 'Gmach Główny (Muzeum Narodowe w Krakowie)',
    category: FacilityCategory.museums,
    distance: '4,8 km',
    address: 'al. 3 Maja 1',
    verified: true,
    verifiedSource: 'Wydział Polityki Społecznej UMK & Audytor MNK',
    badges: [
      FacilityBadge('Windy i platformy', AmenityIcon.lift),
      FacilityBadge('Komfortka', AmenityIcon.changingRoom),
      FacilityBadge('Parking OzN', AmenityIcon.parking),
      FacilityBadge('Wypożyczalnia wózków', AmenityIcon.wheelchair),
    ],
    coordinates: LatLng(50.06036, 19.92353),
    details: AccessibilityDetails(
      parking:
          'Płatny parking podziemny z miejscami dla OzN bezpośrednio przy wejściu oraz 2 dodatkowe koperty w pobliżu Błoń.',
      verticalTransport:
          'Winda zewnętrzna przy wejściu głównym, windy wewnętrzne, platformy schodowe oraz szyny przenośne (dostęp do niemal całego budynku z wyjątkiem antresoli na 2. piętrze).',
      cloakroom:
          'Dedykowana szatnia na parterze przy sklepiku (alternatywa dla szatni na poziomie -1 dostępnej po schodach).',
      restrooms:
          'Przystosowane toalety na każdym piętrze; na 1. piętrze dostępna komfortka (łóżko do przewijania dorosłych).',
      equipmentRental: 'Wózki dla zwiedzających dostępne na parterze.',
    ),
  ),
  Facility(
    id: 'sukiennice',
    name: 'Sukiennice (Galeria Sztuki Polskiej XIX wieku)',
    category: FacilityCategory.zabytki,
    distance: '3,8 km',
    address: 'Rynek Główny 1–3',
    verified: true,
    verifiedSource: 'Audyt Dostępności Historycznej UMK',
    badges: [
      FacilityBadge('Wejście bezprogowe', AmenityIcon.wheelchair),
      FacilityBadge('Winda na taras', AmenityIcon.lift),
      FacilityBadge('Toaleta dostosowana', AmenityIcon.restroom),
    ],
    coordinates: LatLng(50.06168, 19.93732),
    details: AccessibilityDetails(
      entrance:
          'Bezprogowe wejście do budynku, bezprogowe przejścia między salami oraz łagodny podjazd prowadzący na taras.',
      verticalTransport: 'Winda zapewniająca dostęp do galerii i tarasów.',
      cloakroom:
          'Obniżone lady recepcji, sklepu muzealnego i stanowiska strażnika dostosowane do osób na wózkach. Dedykowana szatnia z szafkami bagażowymi przy sklepie na parterze (omijająca schody do szatni głównej).',
      restrooms:
          'W pełni dostosowana (opuszczane uchwyty, specjalna armatura, pochylone lustro, elementy dla osób ze spastycznością rąk); do pokonania schodów przed toaletą obsługa rozkłada mobilne rampy aluminiowe.',
    ),
  ),
  Facility(
    id: 'kamienica-szolayskich',
    name: 'Kamienica Szołayskich im. Feliksa Jasieńskiego',
    category: FacilityCategory.museums,
    distance: '3,7 km',
    address: 'pl. Szczepański 9',
    verified: true,
    verifiedSource: 'Zespół ds. Dostępności MNK',
    badges: [
      FacilityBadge('Wejście z asystą', AmenityIcon.wheelchair),
      FacilityBadge('Winda', AmenityIcon.lift),
      FacilityBadge('2 dostosowane toalety', AmenityIcon.restroom),
    ],
    coordinates: LatLng(50.06475, 19.93859),
    details: AccessibilityDetails(
      entrance:
          'Wejście alternatywne: dedykowane wejście od ul. Szczepańskiej z domofonem do wezwania asysty pracownika muzeum przy pokonywaniu zabytkowego progu.',
      verticalTransport: 'Winda.',
      restrooms: 'Dwie dostosowane toalety (na parterze przy wejściu oraz na 1. piętrze).',
    ),
  ),
  Facility(
    id: 'willa-atma',
    name: 'Muzeum Karola Szymanowskiego w willi „Atma” (Zakopane)',
    category: FacilityCategory.museums,
    distance: '86 km',
    address: 'ul. Kasprusie 19, Zakopane',
    verified: false,
    verifiedSource: 'Deklaracja dostępności obiektu (wymaga asysty)',
    badges: [
      FacilityBadge('Wjazd na posesję', AmenityIcon.parking),
      FacilityBadge('Podjazdy wewnątrz', AmenityIcon.wheelchair),
      FacilityBadge('Dostępna toaleta', AmenityIcon.restroom),
    ],
    coordinates: LatLng(49.28997, 19.96433),
    details: AccessibilityDetails(
      parking: 'Możliwość wjazdu samochodem na posesję po wcześniejszym kontakcie z pracownikami.',
      entrance: 'Szerokie drzwi oraz podjazdy wewnątrz budynku.',
      restrooms: 'Dostępna toaleta.',
      notes: 'Wejście na teren posesji wymaga asysty ze względu na stromy zjazd i wysoki próg.',
    ),
  ),
  Facility(
    id: 'dom-mehoffera',
    name: 'Dom Józefa Mehoffera',
    category: FacilityCategory.museums,
    distance: '4,4 km',
    address: 'ul. Krupnicza 26',
    verified: false,
    verifiedSource: 'Częściowa dostępność architektoniczna',
    badges: [FacilityBadge('Pochylnia do ogrodu', AmenityIcon.wheelchair)],
    coordinates: LatLng(50.06288, 19.92818),
    details: AccessibilityDetails(
      entrance:
          'Po pokonaniu dwóch stopni przy wejściu dostępny jest parter (salon, sklepik) oraz ogród wraz z kawiarnią, do którego prowadzi pochylnia z poręczą.',
      verticalTransport: 'Brak windy na piętro.',
    ),
  ),
  Facility(
    id: 'palac-ciolka',
    name: 'Pałac Biskupa Erazma Ciołka',
    category: FacilityCategory.zabytki,
    distance: '3,9 km',
    address: 'ul. Kanonicza 17',
    verified: true,
    verifiedSource: 'Certyfikat Małopolska Bez Barier',
    badges: [
      FacilityBadge('Wejście bezprogowe', AmenityIcon.wheelchair),
      FacilityBadge('Winda i schodołaz', AmenityIcon.lift),
      FacilityBadge('Toaleta przy windzie', AmenityIcon.restroom),
    ],
    coordinates: LatLng(50.05637, 19.93769),
    details: AccessibilityDetails(
      entrance: 'Wejście bezprogowe.',
      verticalTransport: 'Winda na 1. piętro.',
      equipmentRental:
          'Schodołaz, platformy schodowe i przenośne szyny aluminiowe obsługiwane przez pracowników do pokonywania schodów do bocznych sal, galerii oraz poziomu -1.',
      restrooms: 'Dostępna toaleta usytuowana obok windy.',
    ),
  ),
  Facility(
    id: 'muzeum-wyspianskiego',
    name: 'Muzeum Stanisława Wyspiańskiego',
    category: FacilityCategory.museums,
    distance: '4,3 km',
    address: 'pl. Sikorskiego 6',
    verified: true,
    verifiedSource: 'Kompleksowy Audyt Dostępności UMK 2025',
    badges: [
      FacilityBadge('Wejście bezprogowe', AmenityIcon.wheelchair),
      FacilityBadge('Winda', AmenityIcon.lift),
      FacilityBadge('Spacer wirtualny z AD i ETR', AmenityIcon.digital),
      FacilityBadge('Toaleta przy windzie', AmenityIcon.restroom),
    ],
    coordinates: LatLng(50.06176, 19.93062),
    details: AccessibilityDetails(
      entrance:
          'Bezprogowe wejście główne poprzedzone niewielką pochylnią zabezpieczoną guzami. Bezprogowe przejścia pomiędzy salami.',
      verticalTransport: 'Winda obsługująca ekspozycję.',
      cloakroom: 'Lady recepcji, kasy, sklepu oraz szafki depozytowe przystosowane do wysokości wózków.',
      restrooms: 'Dostępna toaleta zlokalizowana w pobliżu windy.',
      digitalAccess:
          'Wirtualny spacer po wystawie z audiodeskrypcją oraz w tekście łatwym do czytania (ETR).',
    ),
  ),
];
