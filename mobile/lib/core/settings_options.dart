/// Opcje ustawień użytkownika (enumy z etykietami po polsku).
library;

enum AppTheme { light, dark }

enum TextSizeOption {
  standard(1.0, 'Standard'),
  large(1.125, 'Duży'),
  xLarge(1.25, 'Bardzo duży');

  const TextSizeOption(this.scale, this.label);

  /// Mnożnik skali tekstu przekazywany do `TextScaler`.
  final double scale;
  final String label;
}

enum MobilityProfile {
  manualWheelchair('Wózek manualny', 'Omija schody, strome podjazdy i wysokie krawężniki.'),
  electricWheelchair('Wózek elektryczny', 'Uwzględnia szerokość przejść i dostępne windy.'),
  lowVision('Słaby wzrok', 'Preferuje trasy ze ścieżkami dotykowymi i dźwiękową sygnalizacją.'),
  senior('Senior', 'Krótsze odcinki, ławki do odpoczynku i mniej przesiadek.'),
  stroller('Wózek dziecięcy', 'Omija schody i wybiera równą nawierzchnię.');

  const MobilityProfile(this.label, this.description);
  final String label;
  final String description;
}
