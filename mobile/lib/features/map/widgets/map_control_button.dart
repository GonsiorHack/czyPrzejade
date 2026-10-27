import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';

/// Okrągły przycisk nakładki mapy (zoom, lokalizacja) z min. obszarem dotyku 48 dp.
class MapControlButton extends StatelessWidget {
  const MapControlButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 3,
      shape: CircleBorder(side: BorderSide(color: scheme.outline)),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: scheme.onSurface),
        constraints: const BoxConstraints(minWidth: TouchTargets.min, minHeight: TouchTargets.min),
      ),
    );
  }
}
