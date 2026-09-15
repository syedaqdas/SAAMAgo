import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/app_state.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    final items = store.filteredItems.isEmpty
        ? store.items
        : store.filteredItems;
    final selected = items[_selectedIndex % items.length];
    const pins = [
      Offset(0.22, 0.18),
      Offset(0.72, 0.24),
      Offset(0.54, 0.42),
      Offset(0.28, 0.64),
      Offset(0.78, 0.72),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: CustomPaint(painter: _MockMapPainter()),
                      ),
                      for (var i = 0; i < pins.length; i++)
                        Positioned(
                          left:
                              pins[i].dx * MediaQuery.sizeOf(context).width -
                              20,
                          top:
                              pins[i].dy *
                              MediaQuery.sizeOf(context).height *
                              0.6,
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _selectedIndex = i % items.length,
                            ),
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 180),
                              scale: _selectedIndex == i % items.length
                                  ? 1.18
                                  : 1,
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  gradient: AppColors.brandGradient,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primaryText,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(Icons.location_pin, size: 24),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 16,
                        right: 16,
                        top: 16,
                        child: PrimaryButton(
                          height: 46,
                          label: 'Search this area',
                          icon: Icons.my_location_rounded,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Area refreshed with mock nearby items.',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 84,
                      height: 74,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ItemThumbnail(item: selected, height: 74),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selected.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${AppFormatters.rupees(selected.pricePerDay)} / day',
                            style: const TextStyle(
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${selected.distanceKm.toStringAsFixed(1)} km away',
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.itemDetails,
                        arguments: selected,
                      ),
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockMapPainter extends CustomPainter {
  const _MockMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFF111827);
    canvas.drawRect(Offset.zero & size, background);

    final road = Paint()
      ..color = AppColors.elevatedCard
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final thinRoad = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    for (final y in [0.16, 0.34, 0.58, 0.78]) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * (y + 0.04)),
        road,
      );
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * (y + 0.04)),
        thinRoad,
      );
    }
    for (final x in [0.18, 0.42, 0.67, 0.86]) {
      canvas.drawLine(
        Offset(size.width * x, 0),
        Offset(size.width * (x - 0.08), size.height),
        road,
      );
      canvas.drawLine(
        Offset(size.width * x, 0),
        Offset(size.width * (x - 0.08), size.height),
        thinRoad,
      );
    }

    final park = Paint()..color = AppColors.success.withValues(alpha: 0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.08,
          size.height * 0.42,
          size.width * 0.28,
          size.height * 0.18,
        ),
        const Radius.circular(24),
      ),
      park,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
