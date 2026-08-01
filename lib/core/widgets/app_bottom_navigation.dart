import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 12,
            right: 12,
            bottom: 8,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _NavButton(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    active: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavButton(
                    icon: Icons.explore_rounded,
                    label: 'Explore',
                    active: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  const Spacer(),
                  _NavButton(
                    icon: Icons.receipt_long_rounded,
                    label: 'Requests',
                    active: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                  _NavButton(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    active: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: currentIndex == 2 ? 1.06 : 1,
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.primaryText,
                    size: 34,
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            top: 62,
            child: Text(
              'List',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryPurple : AppColors.secondaryText;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
