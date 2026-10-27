import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';

/// Okrągły przycisk nakładki mapy (zoom, lokalizacja, aparat) z obszarem dotyku min. 48 dp.
/// [emphasized] wyróżnia akcję główną kolorem akcentu.
class MapControlButton extends StatelessWidget {
  const MapControlButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.emphasized = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: emphasized ? scheme.primary : scheme.surface,
      elevation: Elevations.control,
      shadowColor: AppShadows.overlay,
      shape: CircleBorder(side: BorderSide(color: scheme.outline.withValues(alpha: 0.6))),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: emphasized ? scheme.onPrimary : scheme.onSurface),
        constraints: const BoxConstraints(minWidth: TouchTargets.min, minHeight: TouchTargets.min),
      ),
    );
  }
}
