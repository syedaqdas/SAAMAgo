import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_panel.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/widgets/section_header.dart';
import '../../data/app_state.dart';
import '../../models/rental_item.dart';

class ItemDetailsScreen extends StatelessWidget {
  const ItemDetailsScreen({required this.item, super.key});

  final RentalItem item;

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    final current = store.items.firstWhere(
      (candidate) => candidate.id == item.id,
      orElse: () => item,
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: current.isFavourite ? 'Remove favourite' : 'Add favourite',
            onPressed: () => store.toggleFavourite(current.id),
            icon: Icon(
              current.isFavourite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: current.isFavourite
                  ? AppColors.error
                  : AppColors.primaryText,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Chat',
                icon: Icons.chat_bubble_rounded,
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.chat,
                  arguments: current,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: 'Borrow Now',
                icon: Icons.shopping_bag_rounded,
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.borrowConfirmation,
                  arguments: current,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Hero(
              tag: 'item-${current.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: ItemThumbnail(item: current, height: 260),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  width: index == 0 ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: index == 0
                        ? AppColors.primaryBlue
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              current.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _InfoPill(
                  icon: Icons.category_rounded,
                  label: current.category,
                ),
                const SizedBox(width: 8),
                _InfoPill(
                  icon: Icons.star_rounded,
                  label: current.rating.toStringAsFixed(1),
                ),
                const SizedBox(width: 8),
                _InfoPill(
                  icon: Icons.place_rounded,
                  label: '${current.distanceKm.toStringAsFixed(1)} km',
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _DetailStat(
                    label: 'Price',
                    value: '${AppFormatters.rupees(current.pricePerDay)} / day',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DetailStat(
                    label: 'Deposit',
                    value: AppFormatters.rupees(current.deposit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DetailStat(
                    label: 'Availability',
                    value: current.availability,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DetailStat(
                    label: 'Condition',
                    value: current.condition,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'About Item'),
            const SizedBox(height: 10),
            Text(
              current.description,
              style: const TextStyle(
                color: AppColors.secondaryText,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 24),
            AppPanel(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.elevatedCard,
                    child: Text(
                      'AI',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current.ownerName,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${current.ownerTrustScore}% trust score',
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.reviews),
                    child: const Text('Reviews'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppPanel(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_rounded, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Safety information',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Use verified profiles, document item condition, and confirm handover details inside chat.',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.elevatedCard,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryTeal),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
