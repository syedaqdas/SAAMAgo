import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/item_card.dart';
import '../../data/app_state.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    if (_searchController.text != store.searchQuery) {
      _searchController.value = _searchController.value.copyWith(
        text: store.searchQuery,
        selection: TextSelection.collapsed(offset: store.searchQuery.length),
      );
    }
    final items = store.filteredItems;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Explore',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        tooltip: store.showGrid ? 'Show list' : 'Show grid',
                        onPressed: store.toggleGrid,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.elevatedCard,
                        ),
                        icon: Icon(
                          store.showGrid
                              ? Icons.view_list_rounded
                              : Icons.grid_view_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: store.setSearchQuery,
                    decoration: const InputDecoration(
                      hintText: 'Search for items',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: store.categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = store.categories[index];
                        final selected = category == store.selectedCategory;
                        return ChoiceChip(
                          label: Text(category),
                          selected: selected,
                          onSelected: (_) => store.setCategory(category),
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: AppColors.chip,
                          labelStyle: TextStyle(
                            color: selected
                                ? AppColors.primaryText
                                : AppColors.secondaryText,
                            fontWeight: FontWeight.w800,
                          ),
                          side: BorderSide(
                            color: selected
                                ? AppColors.primaryBlue
                                : AppColors.border,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _ActionPill(
                        icon: Icons.tune_rounded,
                        label: 'Filter',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.filters),
                      ),
                      const SizedBox(width: 10),
                      _ActionPill(
                        icon: Icons.sort_rounded,
                        label: store.sortOption,
                        onTap: () => _showSortSheet(context, store),
                      ),
                      const SizedBox(width: 10),
                      _ActionPill(
                        icon: Icons.map_rounded,
                        label: 'Map',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.mapView),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
          if (store.isListingsLoading && items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (store.listingsError != null && items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.wifi_off_rounded,
                title: 'Unable to load items',
                message: store.listingsError!,
                actionLabel: 'Try Again',
                onAction: store.fetchListings,
              ),
            )
          else if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.inventory_2_rounded,
                title: 'No items found',
                message: 'Try adjusting your search or filters.',
                actionLabel: 'Reset Filters',
                onAction: store.resetFilters,
              ),
            )
          else if (store.listingsError != null)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        store.listingsError!,
                        style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: store.fetchListings,
                      child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            )
          else if (store.showGrid)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
              sliver: SliverGrid.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.52,
                ),
                itemBuilder: (context, index) => ItemCard(item: items[index]),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: 290,
                    child: ItemCard(item: items[index]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context, SaamaGoStore store) {
    const options = [
      'Nearest',
      'Price low to high',
      'Price high to low',
      'Highest rated',
      'Newest',
    ];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sort by',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                for (final option in options)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option),
                    trailing: Icon(
                      store.sortOption == option
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: store.sortOption == option
                          ? AppColors.primaryBlue
                          : AppColors.secondaryText,
                    ),
                    onTap: () {
                      store.applyFilters(
                        category: store.selectedCategory,
                        price: store.maxPrice,
                        distance: store.maxDistance,
                        selectedCondition: store.condition,
                        rating: store.minRating,
                        sort: option,
                        available: store.availableOnly,
                      );
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.elevatedCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primaryTeal),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
