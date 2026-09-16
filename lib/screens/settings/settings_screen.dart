import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_panel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.person_rounded,
                    label: 'Account Settings',
                    onTap: _showUnavailable,
                  ),
                  _SettingsTile(
                    icon: Icons.lock_rounded,
                    label: 'Privacy and Security',
                    onTap: _showUnavailable,
                  ),
                  _SettingsTile(
                    icon: Icons.credit_card_rounded,
                    label: 'Payment Methods',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.wallet);
                    },
                  ),
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.notifications_rounded,
                      color: AppColors.secondaryText,
                    ),
                    title: const Text('Notifications'),
                    value: _notifications,
                    activeThumbColor: AppColors.primaryBlue,
                    onChanged: (value) =>
                        setState(() => _notifications = value),
                  ),
                  _SettingsTile(
                    icon: Icons.language_rounded,
                    label: 'Language',
                    trailingText: 'English',
                    onTap: _showUnavailable,
                  ),
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.dark_mode_rounded,
                      color: AppColors.secondaryText,
                    ),
                    title: const Text('Dark Mode'),
                    value: _darkMode,
                    activeThumbColor: AppColors.primaryBlue,
                    onChanged: (value) {
                      setState(() => _darkMode = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Dark mode remains enabled.',
                            ),
                          ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.help_outline_rounded,
                    label: 'Help and Support',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.help),
                  ),
                  _SettingsTile(
                    icon: Icons.article_outlined,
                    label: 'Terms and Conditions',
                    onTap: _showUnavailable,
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    label: 'About SAAMAgo',
                    onTap: _showUnavailable,
                  ),
                  _SettingsTile(
                    icon: Icons.person_pin_rounded,
                    label: 'About the Developer',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.aboutDeveloper),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppPanel(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.error,
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This settings action is not yet available.')),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.secondaryText),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      trailing: trailingText == null
          ? const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryText,
            )
          : Text(
              trailingText!,
              style: const TextStyle(color: AppColors.secondaryText),
            ),
      onTap: onTap,
    );
  }
}
