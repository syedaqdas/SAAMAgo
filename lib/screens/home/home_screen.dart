import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/activity_card.dart';
import '../../core/widgets/app_panel.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/app_state.dart';
import '../../models/rental_request.dart';

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
        color: AppColors.primaryBlue,
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
                            color: AppColors.primaryTeal,
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
            const SizedBox(height: 28),
            const Text(
              'What do you want\ntoday?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.shell, arguments: 1), // Explore tab
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.search_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Borrow',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Find items nearby',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.listItem),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.elevatedCard,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryTeal, size: 28),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Lend',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'List an item to earn',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            AppPanel(
              padding: const EdgeInsets.all(16),
              onTap: () => Navigator.pushNamed(context, AppRoutes.wallet),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.elevatedCard,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SAAMAgo Wallet',
                          style: TextStyle(color: AppColors.secondaryText, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${store.walletBalance}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Your Dashboard'),
            const SizedBox(height: 14),
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
            if (store.isRequestsLoading && store.requests.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (store.requestsError != null && store.requests.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Text(store.requestsError!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: store.fetchRequests,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (store.requests.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No recent activity', style: TextStyle(color: AppColors.secondaryText)),
                ),
              ),
            if (store.requestsError != null && store.requests.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 14, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        store.requestsError!,
                        style: const TextStyle(fontSize: 12, color: AppColors.error),
                      ),
                    ),
                    TextButton(
                      onPressed: store.fetchRequests,
                      child: const Text('Retry', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            if (store.requests.isNotEmpty)
              ...store.requests.take(4).map((request) {
                Color statusColor;
                String statusText;
              String subtitleText = 'Due on ${request.dateLabel}';
              
              switch (request.status) {
                case RequestStatus.pending:
                  statusColor = AppColors.warning;
                  statusText = 'Pending';
                  subtitleText = 'Pending approval';
                  break;
                case RequestStatus.accepted:
                  statusColor = AppColors.success;
                  statusText = 'Active';
                  break;
                case RequestStatus.completed:
                  statusColor = AppColors.success;
                  statusText = 'Completed';
                  subtitleText = 'Request completed';
                  break;
                case RequestStatus.cancelled:
                  statusColor = AppColors.error;
                  statusText = 'Cancelled';
                  subtitleText = 'Request cancelled';
                  break;
                case RequestStatus.rejected:
                  statusColor = AppColors.error;
                  statusText = 'Rejected';
                  subtitleText = 'Request rejected';
                  break;
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ActivityCard(
                  title: request.item.name,
                  subtitle: subtitleText,
                  icon: request.item.icon,
                  status: statusText,
                  statusColor: statusColor,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.itemDetails,
                    arguments: request.item,
                  ),
                ),
              );
            }),
            const SizedBox(height: 14),
            AppPanel(
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      color: AppColors.primaryTeal,
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
                      color: AppColors.primaryTeal,
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
            if (store.isListingsLoading && nearby.isEmpty)
              const SizedBox(
                height: 245,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (store.listingsError != null && nearby.isEmpty)
              SizedBox(
                height: 245,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        store.listingsError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: store.fetchListings,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (nearby.isEmpty)
              const SizedBox(
                height: 245,
                child: Center(
                  child: Text(
                    'No items nearby',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (store.listingsError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 14, color: AppColors.error),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              store.listingsError!,
                              style: const TextStyle(fontSize: 12, color: AppColors.error),
                            ),
                          ),
                          TextButton(
                            onPressed: store.fetchListings,
                            child: const Text('Retry', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
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
          ],
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
          Icon(icon, color: AppColors.primaryTeal, size: 22),
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
