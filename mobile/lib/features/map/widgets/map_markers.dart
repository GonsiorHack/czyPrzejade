import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../app/theme.dart';
import '../map_constants.dart';
import '../../discover/models/facility.dart';
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
        color: isStart ? colors.brand : colors.markerEndFill,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: AppShadows.marker, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Text(
        isStart ? 'A' : 'B',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.45),
      ),
    );
  }
}

/// Kropka pozycji użytkownika; z [heading] dorysowuje półprzezroczysty wachlarz kierunku.
/// Znacznik obraca się razem z mapą, więc [heading] (od północy) pozostaje poprawny.
class UserLocationDot extends StatelessWidget {
  const UserLocationDot({super.key, this.heading});
  final double? heading;

  @override
  Widget build(BuildContext context) {
    final heading = this.heading;
    final dot = _dot(context);
    if (heading == null) return dot;
    final color = context.appColors.userLocation;
    return Transform.rotate(
      angle: heading * math.pi / 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: _HeadingConePainter(color))),
          // Kropka pozostaje w środku, więc stożek nie przesuwa punktu.
          SizedBox(
            width: MapConstants.userMarkerSize,
            height: MapConstants.userMarkerSize,
            child: Transform.rotate(angle: -heading * math.pi / 180, child: dot),
          ),
        ],
      ),
    );
  }

  Widget _dot(BuildContext context) {
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

/// Wachlarz kierunku (±30°) z gradientem promienistym, skierowany w górę.
class _HeadingConePainter extends CustomPainter {
  const _HeadingConePainter(this.color);
  final Color color;

  static const _halfAngle = math.pi / 6;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(colors: [color.withValues(alpha: 0.55), color.withValues(alpha: 0)])
          .createShader(rect);
    canvas.drawArc(rect, -math.pi / 2 - _halfAngle, 2 * _halfAngle, true, paint);
  }

  @override
  bool shouldRepaint(_HeadingConePainter old) => old.color != color;
}

/// Mała kropka na trasie, wskazująca jej przebieg.
class RouteDotMarker extends StatelessWidget {
  const RouteDotMarker({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: AppShadows.marker, blurRadius: 3)],
      ),
    );
  }
}

/// Znacznik obiektu (POI) na mapie; dotknięcie otwiera okno ze szczegółami.
class FacilityMarker extends StatelessWidget {
  const FacilityMarker({super.key, required this.facility, required this.onTap});
  final Facility facility;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      label: facility.name,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: colors.brand, width: 2),
            boxShadow: const [
              BoxShadow(color: AppShadows.marker, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Icon(facility.category.icon, size: 18, color: colors.brand),
        ),
      ),
    );
  }
}
