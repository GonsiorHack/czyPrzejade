import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';

/// Minimalna prędkość gestu (px/s), która zamyka panel.
const _dismissVelocity = 300.0;

/// Krawędź ekranu, z której wsuwa się panel.
enum SlideEdge { left, right }

/// Pełnoekranowy panel wsuwany z krawędzi. Wejście i wyjście używają tej samej
/// animacji poziomej, niezależnie od tego, co je wywołało (pasek nawigacji lub gest).
/// Zamyka go przesunięcie w stronę mapy: panel z lewej w prawo, panel z prawej w lewo.
class SlidePanel extends StatelessWidget {
  const SlidePanel({
    super.key,
    required this.visible,
    required this.onDismiss,
    required this.child,
    this.edge = SlideEdge.left,
  });

  final bool visible;

  /// Wywoływane po geście zamknięcia (powrót do mapy).
  final VoidCallback onDismiss;
  final Widget child;
  final SlideEdge edge;

  @override
  Widget build(BuildContext context) {
    final fromLeft = edge == SlideEdge.left;
    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : Offset(fromLeft ? -1 : 1, 0),
          duration: AppDurations.panelSlide,
          curve: Curves.easeOutCubic,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (fromLeft ? velocity > _dismissVelocity : velocity < -_dismissVelocity) {
                onDismiss();
              }
            },
            child: Material(color: Theme.of(context).colorScheme.surface, child: child),
          ),
        ),
      ),
    );
  }
}
