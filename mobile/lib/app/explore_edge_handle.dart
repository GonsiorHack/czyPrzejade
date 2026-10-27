import 'package:flutter/material.dart';

import '../app/design_tokens.dart';
import 'shell_strings.dart';

const _handleWidth = 22.0;
const _handleHeight = 72.0;

/// Minimalna prędkość przeciągnięcia (px/s) na zewnątrz, która otwiera panel.
const _openVelocity = 150.0;

/// Wąski uchwyt ("dzyngiel") przy lewej krawędzi mapy: dotknięcie lub przeciągnięcie
/// w prawo otwiera panel "Odkrywaj".
class ExploreEdgeHandle extends StatelessWidget {
  const ExploreEdgeHandle({super.key, required this.visible, required this.onOpen});

  final bool visible;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: AppDurations.fadeFast,
          child: Semantics(
            button: true,
            label: ShellStrings.openExplore,
            child: GestureDetector(
              onTap: onOpen,
              onHorizontalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) > _openVelocity) onOpen();
              },
              child: Container(
                width: _handleWidth,
                height: _handleHeight,
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: GlassStyle.opacity),
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(Radii.sm)),
                  boxShadow: const [BoxShadow(color: AppShadows.overlay, blurRadius: 8)],
                ),
                child: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
