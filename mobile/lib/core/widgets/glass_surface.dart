import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';

/// Półprzezroczysta powierzchnia z rozmyciem tła (glass / frosted effect).
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(Radii.lg)),
    this.opacity = GlassStyle.opacity,
    this.elevated = true,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double opacity;

  /// Czy rysować cień pod powierzchnią (wyłączane np. dla dolnego paska).
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: elevated
            ? const [BoxShadow(color: AppShadows.overlay, blurRadius: 14, offset: Offset(0, 3))]
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: GlassStyle.blurSigma, sigmaY: GlassStyle.blurSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: opacity),
              borderRadius: borderRadius,
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
