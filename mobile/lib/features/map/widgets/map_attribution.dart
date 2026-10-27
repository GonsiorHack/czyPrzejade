import 'package:flutter/material.dart';

import '../../../app/config.dart';
import '../../../app/design_tokens.dart';
import '../map_constants.dart';

/// Kompaktowa, jednowierszowa atrybucja źródła kafelków (wymagana licencją OSM / CARTO).
/// Półprzezroczyste tło i ciemny tekst nie zasłaniają mapy.
class MapAttribution extends StatelessWidget {
  const MapAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: MapConstants.attributionOpacity),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs),
        child: Text(
          AppConfig.mapAttribution,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textScaler: TextScaler.noScaling,
          style: TextStyle(color: Colors.black87, fontSize: MapConstants.attributionFontSize),
        ),
      ),
    );
  }
}
