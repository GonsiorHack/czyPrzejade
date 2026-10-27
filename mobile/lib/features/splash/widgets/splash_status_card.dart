import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';

/// Półprzezroczysta karta ze stanem ładowania lub błędu intro.
class SplashStatusCard extends StatelessWidget {
  const SplashStatusCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DefaultTextStyle.merge(style: TextStyle(color: scheme.onSurface), child: child),
    );
  }
}
