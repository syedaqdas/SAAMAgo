import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/saamago_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardingPageData(
      title: 'Borrow anything nearby.',
      subtitle: 'Find useful items from trusted people around you.',
      icon: Icons.shopping_bag_rounded,
    ),
    _OnboardingPageData(
      title: 'Earn money by lending.',
      subtitle: 'List unused items and earn whenever someone borrows them.',
      icon: Icons.savings_rounded,
    ),
    _OnboardingPageData(
      title: 'Built on trust.',
      subtitle: 'Verified profiles, deposits, ratings and safer handovers.',
      icon: Icons.verified_user_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _pages.length - 1) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            page.title,
                            style: const TextStyle(
                              fontSize: 32,
                              height: 1.08,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            page.subtitle,
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 16,
                              height: 1.45,
                            ),
                          ),
                          const Spacer(),
                          _OnboardingIllustration(
                            icon: page.icon,
                            index: index,
                          ),
                          const Spacer(),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == index
                          ? AppColors.primaryPurple
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: PrimaryButton(
                  label: _page == _pages.length - 1 ? 'Get Started' : 'Next',
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({required this.icon, required this.index});

  final IconData icon;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryPurple.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.24),
              ),
            ),
          ),
          Positioned(
            top: 28,
            right: 38,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.lightPurple.withValues(alpha: 0.7),
            ),
          ),
          Positioned(
            left: 32,
            bottom: 42,
            child: Icon(
              Icons.circle,
              size: 12,
              color: AppColors.primaryPurple.withValues(alpha: 0.8),
            ),
          ),
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(42),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  blurRadius: 36,
                  offset: const Offset(0, 22),
                ),
              ],
            ),
            child: Icon(icon, size: 74, color: AppColors.primaryText),
          ),
          if (index == 0)
            const Positioned(bottom: 8, child: SaamaGoLogo(size: 42))
          else
            Positioned(
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.elevatedCard,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  index == 1
                      ? Icons.currency_rupee_rounded
                      : Icons.shield_rounded,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
