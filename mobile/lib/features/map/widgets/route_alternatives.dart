import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../map_strings.dart';
import '../models/route_info.dart';
import '../utils/formatters.dart';

/// Kolor linii trasy zależny od jej typu.
Color routeColor(AppColors colors, RouteInfo route) =>
    route.type == RouteType.wheelchair ? colors.routeAccessible : colors.routeStandard;

/// Lista tras alternatywnych rozwijana w [RouteSheet].
class RouteAlternatives extends StatelessWidget {
  const RouteAlternatives({
    super.key,
    required this.alternatives,
    required this.active,
    required this.onSelect,
  });

  final List<RouteInfo> alternatives;
  final RouteInfo active;
  final ValueChanged<String> onSelect;

  String _timeDifference(RouteInfo route) {
    final diff = route.durationMinutes.round() - active.durationMinutes.round();
    if (diff == 0) return MapStrings.sameTime;
    return '${diff.abs()} min ${diff < 0 ? MapStrings.faster : MapStrings.slower}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        for (final alt in alternatives)
          Card(
            child: ListTile(
              onTap: () => onSelect(alt.id),
              leading: Icon(Icons.alt_route, color: routeColor(colors, alt)),
              title: Text(alt.name),
              subtitle: Text('${formatDistance(alt.distanceMeters)} · ${_timeDifference(alt)}'),
              trailing: Text(
                formatDuration(alt.durationMinutes),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}
