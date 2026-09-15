import 'dart:io';

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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'item-${item.id}',
              child: _ItemThumbnail(item: item, height: compact ? 116 : 148),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: item.isFavourite ? 'Remove favourite' : 'Add favourite',
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () => store.toggleFavourite(item.id),
                        icon: Icon(
                          item.isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: item.isFavourite ? AppColors.error : AppColors.mutedText,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        AppFormatters.rupees(item.pricePerDay),
                        style: const TextStyle(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        ' / day',
                        style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.place_rounded, color: AppColors.secondaryText, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        '${item.distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(color: AppColors.secondaryText, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Icon(
                        item.isAvailable ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: item.isAvailable ? AppColors.success : AppColors.error,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.isAvailable ? 'Available' : 'Unavailable',
                        style: TextStyle(
                          color: item.isAvailable ? AppColors.success : AppColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 36,
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: item.isAvailable ? () => Navigator.pushNamed(context, AppRoutes.itemDetails, arguments: item) : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.elevatedCard,
                          disabledBackgroundColor: AppColors.elevatedCard.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          item.isAvailable ? 'Borrow Now' : 'Not Available',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: item.isAvailable ? AppColors.primaryTeal : AppColors.mutedText,
                          ),
                        ),
                      ),
                    ),
                  ],
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
    if (item.imagePath != null) {
      final isNetwork = item.imagePath!.startsWith('http');
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: isNetwork 
                ? NetworkImage(item.imagePath!) as ImageProvider 
                : FileImage(File(item.imagePath!)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
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
