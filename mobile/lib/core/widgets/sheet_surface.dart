import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';

/// Wspólna powierzchnia dolnych arkuszy (bottomSheet): zaokrąglona góra, obrys i cień.
class SheetSurface extends StatelessWidget {
  const SheetSurface({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.lg)),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(color: AppShadows.overlay, blurRadius: 24, offset: Offset(0, -4)),
        ],
      ),
      child: child,
    );
  }
}
