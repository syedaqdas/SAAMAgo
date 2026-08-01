import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_state.dart';
import '../../models/rental_item.dart';
import '../constants/app_colors.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({required this.item, super.key, this.compact = false});

  final RentalItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.itemDetails, arguments: item),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'item-${item.id}',
              child: _ItemThumbnail(item: item, height: compact ? 104 : 128),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        tooltip: item.isFavourite
                            ? 'Remove favourite'
                            : 'Add favourite',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => store.toggleFavourite(item.id),
                        icon: Icon(
                          item.isFavourite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: item.isFavourite
                              ? AppColors.error
                              : AppColors.secondaryText,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${AppFormatters.rupees(item.pricePerDay)} / day',
                    style: const TextStyle(
                      color: AppColors.lightPurple,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_rounded,
                        color: AppColors.secondaryText,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.warning,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
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

class ItemThumbnail extends StatelessWidget {
  const ItemThumbnail({required this.item, super.key, this.height = 130});

  final RentalItem item;
  final double height;

  @override
  Widget build(BuildContext context) =>
      _ItemThumbnail(item: item, height: height);
}

class _ItemThumbnail extends StatelessWidget {
  const _ItemThumbnail({required this.item, required this.height});

  final RentalItem item;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.gradient,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -20,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Icon(
              item.icon,
              size: height * 0.48,
              color: AppColors.primaryText.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}
