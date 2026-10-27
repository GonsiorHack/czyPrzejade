import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import 'map_attribution.dart';

/// Warstwa nad dolnym arkuszem: przyciski mapy po prawej i atrybucja po lewej.
/// Jest przypięta tuż nad uchwytem arkusza, dzięki czemu niczego nie zasłania.
class MapFloatingLayer extends StatelessWidget {
  const MapFloatingLayer({super.key, required this.controls});
  final Widget controls;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.sm,
        children: [
          Align(alignment: Alignment.centerRight, child: controls),
          const Align(alignment: Alignment.centerLeft, child: MapAttribution()),
        ],
      ),
    );
  }
}
