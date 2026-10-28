import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../splash_constants.dart';

/// Przycisk "Pomiń" w prawym dolnym rogu, czytelny na tle wideo.
class SplashSkipButton extends StatelessWidget {
  const SplashSkipButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg, Spacing.lg, Spacing.xl),
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor: AppShadows.chromeOverlay,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.sm),
            ),
            child: const Text(SplashStrings.skip, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
