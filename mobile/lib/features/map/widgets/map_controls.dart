import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../map_strings.dart';
import 'map_control_button.dart';
import 'report_obstacle_button.dart';

/// Kolumna przycisków przy prawej krawędzi: aparat (zgłoszenie), zoom +/- i lokalizacja.
class MapControls extends StatelessWidget {
  const MapControls({
    super.key,
    required this.locating,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onLocate,
  });

  final bool locating;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onLocate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.sm,
      children: [
        const ReportObstacleButton(),
        MapControlButton(icon: Icons.add, tooltip: MapStrings.zoomIn, onPressed: onZoomIn),
        MapControlButton(icon: Icons.remove, tooltip: MapStrings.zoomOut, onPressed: onZoomOut),
        MapControlButton(
          icon: locating ? Icons.hourglass_top : Icons.my_location,
          tooltip: MapStrings.showMyLocation,
          onPressed: onLocate,
        ),
      ],
    );
  }
}
