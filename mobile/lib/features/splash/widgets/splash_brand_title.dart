import 'package:flutter/material.dart';

import '../../../app/config.dart';
import '../splash_constants.dart';

/// Nazwa marki widoczna pod wideo, dopóki nie pojawi się pierwsza klatka.
class SplashBrandTitle extends StatelessWidget {
  const SplashBrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Text.rich(
        TextSpan(
          text: AppConfig.name,
          children: [TextSpan(text: '?', style: TextStyle(color: scheme.primary))],
        ),
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: SplashConstants.brandFontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
