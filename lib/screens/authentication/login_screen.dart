import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_panel.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/widgets/saamago_logo.dart';
import '../../core/widgets/saamago_wordmark.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController(text: '9876543210');
  bool _isLoading = false;

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);
    Navigator.pushNamed(
      context,
      AppRoutes.otp,
      arguments: _mobileController.text.trim(),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: SaamaGoLogo(size: 76)),
                const SizedBox(height: 22),
                const Center(
                  child: SaamaGoWordmark(fontSize: 34, center: true),
                ),
                const SizedBox(height: 38),
                const Text(
                  'Welcome to SAAMAgo',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login or signup to continue.',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 24),
                AppPanel(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _mobileController,
                          label: 'Mobile number',
                          hint: '98765 43210',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: Validators.mobile,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          suffix: Container(
                            width: 56,
                            alignment: Alignment.center,
                            child: const Text(
                              '+91',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        PrimaryButton(
                          label: 'Continue',
                          onPressed: _continue,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'or continue with',
                                style: TextStyle(
                                  color: AppColors.secondaryText.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: SecondaryButton(
                                label: 'Google',
                                icon: Icons.g_mobiledata_rounded,
                                onPressed: () => _mockProvider('Google'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SecondaryButton(
                                label: 'Apple',
                                icon: Icons.apple_rounded,
                                onPressed: () => _mockProvider('Apple'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'By continuing, you agree to our Terms and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mockProvider(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-in is mocked for this demo.')),
    );
  }
}
