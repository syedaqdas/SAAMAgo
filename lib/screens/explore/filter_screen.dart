import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../data/app_state.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late String _category;
  late double _price;
  late double _distance;
  late double _rating;
  late String _condition;
  late String _sort;
  late bool _available;

  static const _conditions = ['Any', 'Like New', 'Excellent', 'Good'];
  static const _sortOptions = [
    'Nearest',
    'Price low to high',
    'Price high to low',
    'Highest rated',
    'Newest',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = AppStateScope.of(context);
    _category = store.selectedCategory;
    _price = store.maxPrice;
    _distance = store.maxDistance;
    _rating = store.minRating;
    _condition = store.condition;
    _sort = store.sortOption;
    _available = store.availableOnly;
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Filters')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Text(
              'Categories',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in store.categories)
                  ChoiceChip(
                    label: Text(category),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                    selectedColor: AppColors.primaryPurple,
                    backgroundColor: AppColors.chip,
                    side: const BorderSide(color: AppColors.border),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            _SliderBlock(
              label: 'Price Range',
              valueLabel: '₹0 - ₹${_price.round()}',
              value: _price,
              min: 100,
              max: 10000,
              divisions: 99,
              onChanged: (value) => setState(() => _price = value),
            ),
            _SliderBlock(
              label: 'Distance',
              valueLabel: 'Within ${_distance.toStringAsFixed(1)} km',
              value: _distance,
              min: 1,
              max: 10,
              divisions: 18,
              onChanged: (value) => setState(() => _distance = value),
            ),
            _SliderBlock(
              label: 'Minimum Rating',
              valueLabel: '${_rating.toStringAsFixed(1)}+',
              value: _rating,
              min: 0,
              max: 5,
              divisions: 10,
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _condition,
              decoration: const InputDecoration(labelText: 'Item condition'),
              items: _conditions.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(condition),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _condition = value ?? _condition),
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primaryPurple,
              title: const Text('Available today'),
              value: _available,
              onChanged: (value) => setState(() => _available = value),
            ),
            const SizedBox(height: 14),
            const Text(
              'Sort By',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final option in _sortOptions)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(option),
                trailing: Icon(
                  _sort == option
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: _sort == option
                      ? AppColors.primaryPurple
                      : AppColors.secondaryText,
                ),
                onTap: () => setState(() => _sort = option),
              ),
            const SizedBox(height: 18),
            SecondaryButton(
              label: 'Reset',
              icon: Icons.refresh_rounded,
              onPressed: () {
                store.resetFilters();
                setState(() {
                  _category = store.selectedCategory;
                  _price = store.maxPrice;
                  _distance = store.maxDistance;
                  _rating = store.minRating;
                  _condition = store.condition;
                  _sort = store.sortOption;
                  _available = store.availableOnly;
                });
              },
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Apply Filters',
              icon: Icons.check_rounded,
              onPressed: () {
                store.applyFilters(
                  category: _category,
                  price: _price,
                  distance: _distance,
                  selectedCondition: _condition,
                  rating: _rating,
                  sort: _sort,
                  available: _available,
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderBlock extends StatelessWidget {
  const _SliderBlock({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              valueLabel,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.primaryPurple,
          inactiveColor: AppColors.border,
          onChanged: onChanged,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
