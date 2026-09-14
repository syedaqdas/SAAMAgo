import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_panel.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_header.dart';
import '../../data/app_state.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key, this.showAppBar = false});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    final body = SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          showAppBar ? 8 : 12,
          20,
          showAppBar ? 24 : 112,
        ),
        children: [
          if (!showAppBar)
            const Text(
              'My Wallet',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
          if (!showAppBar) const SizedBox(height: 18),
          AppPanel(
            gradient: AppColors.purpleGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${store.walletBalance}',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Add Money',
                  icon: Icons.add_card_rounded,
                  height: 48,
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add money is mocked for this demo.'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: _WalletMiniStat(label: 'Deposits', value: '₹5,000'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _WalletMiniStat(label: 'Refunds', value: '₹2,411'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _WalletMiniStat(label: 'Rewards', value: '₹250'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppPanel(
            child: Row(
              children: const [
                Icon(Icons.stars_rounded, color: AppColors.warning),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '250 SAAMA Coins available for discounts and referral rewards.',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Recent Transactions',
            actionLabel: 'Filters',
            onAction: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction filters are mocked.')),
            ),
          ),
          const SizedBox(height: 10),
          for (final transaction in store.transactions) ...[
            AppPanel(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(transaction.icon, color: AppColors.lightPurple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction.subtitle,
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${transaction.isPositive ? '+' : '-'}${AppFormatters.rupees(transaction.amount)}',
                    style: TextStyle(
                      color: transaction.isPositive
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );

    if (!showAppBar) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: body,
    );
  }
}

class _WalletMiniStat extends StatelessWidget {
  const _WalletMiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
