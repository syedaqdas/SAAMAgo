import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_panel.dart';
import '../../core/widgets/primary_button.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _searchController = TextEditingController();

  final _faqs = const [
    (
      'How do deposits work?',
      'Deposits are mocked in this frontend demo and shown as held/refunded wallet entries.',
    ),
    (
      'How do I hand over an item?',
      'Agree on pickup details in chat, check item condition, and confirm return timing.',
    ),
    (
      'Can I cancel a request?',
      'Pending request cancellation is represented as a mocked local action.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help and Support')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Text(
              'How can we help you?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search help topics',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Quick Help',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            AppPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SupportTile(
                    icon: Icons.quiz_outlined,
                    label: 'FAQs',
                    onTap: _mock,
                  ),
                  _SupportTile(
                    icon: Icons.contact_support_outlined,
                    label: 'Contact Us',
                    onTap: _mock,
                  ),
                  _SupportTile(
                    icon: Icons.report_problem_outlined,
                    label: 'Report an Issue',
                    onTap: _mock,
                  ),
                  _SupportTile(
                    icon: Icons.health_and_safety_outlined,
                    label: 'Safety Tips',
                    onTap: _mock,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('FAQ', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            for (final faq in _faqs)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppPanel(
                  padding: EdgeInsets.zero,
                  child: ExpansionTile(
                    title: Text(
                      faq.$1,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          faq.$2,
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Need more help?',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'We usually reply within 24 hours.',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: 'Chat with Support',
                    icon: Icons.support_agent_rounded,
                    onPressed: _mock,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mock() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Support action is mocked.')));
  }
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.secondaryText),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.secondaryText,
      ),
      onTap: onTap,
    );
  }
}
