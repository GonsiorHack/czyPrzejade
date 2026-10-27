import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../models/facility.dart';

/// Miniatura obiektu; gdy brak zdjęcia lub nie da się go pobrać, pokazuje ikonę kategorii.
class FacilityThumbnail extends StatelessWidget {
  const FacilityThumbnail({
    super.key,
    required this.facility,
    this.size = 96,
    this.width,
    this.rounded = true,
  });
  final Facility facility;
  final double size;

  /// Szerokość; domyślnie kwadrat o boku [size].
  final double? width;

  /// Czy zaokrąglać rogi (wyłączane, gdy zdjęcie jest przycinane przez rodzica).
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    final url = facility.photoUrl;
    final fallback = _Fallback(category: facility.category);
    return ClipRRect(
      borderRadius: rounded ? BorderRadius.circular(Radii.sm) : BorderRadius.zero,
      child: SizedBox(
        width: width ?? size,
        height: size,
        child: url == null
            ? fallback
            : Image.network(
                url,
                fit: BoxFit.cover,
                semanticLabel: facility.name,
                errorBuilder: (_, _, _) => fallback,
                loadingBuilder: (_, child, progress) => progress == null ? child : fallback,
              ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.category});
  final FacilityCategory category;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary.withValues(alpha: 0.25), scheme.primary.withValues(alpha: 0.08)],
        ),
      ),
      child: Center(child: Icon(category.icon, size: 36, color: scheme.primary)),
    );
  }
}
