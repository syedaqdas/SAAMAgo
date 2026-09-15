import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_panel.dart';
import '../../core/widgets/secondary_button.dart';

class ReferAndEarnScreen extends StatelessWidget {
  const ReferAndEarnScreen({super.key});

  static const _code = 'SAAMA1234';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refer and Earn')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const SizedBox(height: 10),
            const _ReferralIllustration(),
            const SizedBox(height: 24),
            const Text(
              'Invite your friends and earn SAAMAgo Coins',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 18),
            AppPanel(
              gradient: AppColors.brandGradient,
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Referral Code',
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _code,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: _code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Referral code copied.')),
                      );
                    },
                    child: const Text('Copy'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: const [
                Expanded(
                  child: _RewardCard(label: 'You Earn', value: '₹100'),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _RewardCard(
                    label: 'Successful Referrals',
                    value: '12',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SecondaryButton(
              label: 'Share Placeholder',
              icon: Icons.share_rounded,
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Native sharing can be added later.'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'How it Works',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const _HowItWorksRow(
              number: '1',
              text: 'Share your code with friends.',
            ),
            const _HowItWorksRow(
              number: '2',
              text: 'Your friend signs up and borrows an item.',
            ),
            const _HowItWorksRow(
              number: '3',
              text: 'You both get ₹100 in SAAMA Coins.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferralIllustration extends StatelessWidget {
  const _ReferralIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 190,
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(38),
          border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.24),
          ),
        ),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 42,
              child: CircleAvatar(
                radius: 28,
                child: Icon(Icons.person_rounded),
              ),
            ),
            Positioned(
              right: 42,
              child: CircleAvatar(
                radius: 28,
                child: Icon(Icons.person_rounded),
              ),
            ),
            Positioned(
              bottom: 28,
              child: Icon(
                Icons.currency_rupee_rounded,
                color: AppColors.warning,
                size: 42,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.label, required this.value});

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
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksRow extends StatelessWidget {
  const _HowItWorksRow({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primaryBlue,
            child: Text(
              number,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}
