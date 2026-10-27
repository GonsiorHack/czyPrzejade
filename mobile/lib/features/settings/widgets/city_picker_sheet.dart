import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../core/cities.dart';
import '../settings_strings.dart';

/// Otwiera pełnoekranowy wybór miasta z wyszukiwarką (bez rozróżniania polskich znaków).
Future<void> showCityPicker(
  BuildContext context, {
  required PolishCity selected,
  required ValueChanged<PolishCity> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => SizedBox(
      height: MediaQuery.sizeOf(context).height,
      child: _CityPicker(selected: selected, onSelected: onSelected),
    ),
  );
}

class _CityPicker extends StatefulWidget {
  const _CityPicker({required this.selected, required this.onSelected});
  final PolishCity selected;
  final ValueChanged<PolishCity> onSelected;

  @override
  State<_CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends State<_CityPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final cities = searchCities(_query);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.md),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: SettingsStrings.citySearchHint,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: cities.isEmpty
                ? const Center(child: Text(SettingsStrings.cityNoResults))
                : ListView.builder(
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      final isSelected = city.name == widget.selected.name;
                      return ListTile(
                        title: Text(city.name),
                        selected: isSelected,
                        trailing: isSelected ? const Icon(Icons.check) : null,
                        onTap: () {
                          widget.onSelected(city);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
