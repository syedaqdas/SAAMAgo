import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/activity_card.dart';
import '../../core/widgets/app_panel.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/app_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    final nearby = store.items.take(4).toList();

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primaryPurple,
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.elevatedCard,
                  child: Text(
                    'AI',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, Aqdas',
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton.filled(
                      tooltip: 'Notifications',
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.notifications),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.elevatedCard,
                      ),
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                    if (store.unreadNotifications > 0)
                      Positioned(
                        right: 6,
                        top: 4,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            store.unreadNotifications.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 22),
            AppPanel(
              gradient: AppColors.purpleGradient,
              onTap: () => Navigator.pushNamed(context, AppRoutes.wallet),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'SAAMAgo Wallet',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Container(
                        width: 58,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '₹2,589',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Available balance',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _WalletAction(
                        icon: Icons.add_rounded,
                        label: 'Add Money',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.wallet),
                      ),
                      const SizedBox(width: 10),
                      _WalletAction(
                        icon: Icons.history_rounded,
                        label: 'History',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.wallet),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Your Activity'),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: _MetricCard(
                    label: 'Borrowed',
                    value: '2',
                    icon: Icons.shopping_bag_rounded,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'Lending',
                    value: '1',
                    icon: Icons.handshake_rounded,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'Requests',
                    value: '3',
                    icon: Icons.receipt_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Recent Activity',
              actionLabel: 'View All',
              onAction: () => Navigator.pushNamed(context, AppRoutes.requests),
            ),
            const SizedBox(height: 12),
            ActivityCard(
              title: 'Borrowed Canon DSLR',
              subtitle: 'Due on 28 May',
              icon: Icons.photo_camera_rounded,
              status: 'Active',
              statusColor: AppColors.success,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.itemDetails,
                arguments: store.items[0],
              ),
            ),
            const SizedBox(height: 10),
            ActivityCard(
              title: 'Lending Camping Tent',
              subtitle: 'Due on 30 May',
              icon: Icons.terrain_rounded,
              status: 'Active',
              statusColor: AppColors.success,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.itemDetails,
                arguments: store.items[3],
              ),
            ),
            const SizedBox(height: 10),
            ActivityCard(
              title: 'Rich Dad Poor Dad',
              subtitle: 'Request accepted',
              icon: Icons.menu_book_rounded,
              status: 'Completed',
              statusColor: AppColors.success,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.itemDetails,
                arguments: store.items[9],
              ),
            ),
            const SizedBox(height: 10),
            ActivityCard(
              title: 'Requested Drill Machine',
              subtitle: 'Pending approval',
              icon: Icons.construction_rounded,
              status: 'Pending',
              statusColor: AppColors.warning,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.itemDetails,
                arguments: store.items[1],
              ),
            ),
            const SizedBox(height: 24),
            AppPanel(
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      color: AppColors.lightPurple,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invite your friends',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Earn SAAMA Coins when friends complete their first borrow.',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refer',
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.refer),
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.lightPurple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Nearby Items',
              actionLabel: 'Explore',
              onAction: () =>
                  Navigator.pushNamed(context, AppRoutes.shell, arguments: 1),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 245,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: nearby.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 176,
                    child: ItemCard(item: nearby[index], compact: true),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  const _WalletAction({
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.lightPurple, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
