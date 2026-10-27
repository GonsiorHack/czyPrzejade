import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';

/// Pigułka z krótką podpowiedzią nad mapą.
class MapHintBanner extends StatelessWidget {
  const MapHintBanner({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
      elevation: 2,
      borderRadius: BorderRadius.circular(Radii.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.sm),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
