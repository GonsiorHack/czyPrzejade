import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../app/theme.dart';
import '../map_constants.dart';
import '../models/waypoint.dart';

/// Okrągła odznaka "A" / "B" używana na mapie i w panelu planowania.
class MapMarkerBadge extends StatelessWidget {
  const MapMarkerBadge({super.key, required this.kind, this.size = MapConstants.waypointBadgeSize});
  final WaypointKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isStart = kind == WaypointKind.start;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isStart ? colors.markerStartFill : colors.markerEndFill,
        border: Border.all(color: isStart ? colors.brand : Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: AppShadows.marker, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        isStart ? 'A' : 'B',
        style: TextStyle(
          color: isStart ? colors.markerStartText : Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.45,
        ),
      ),
    );
  }
}

/// Niebieska kropka z obwódką pokazująca pozycję użytkownika.
class UserLocationDot extends StatelessWidget {
  const UserLocationDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.userLocation,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: AppShadows.marker, blurRadius: 6)],
      ),
    );
  }
}
