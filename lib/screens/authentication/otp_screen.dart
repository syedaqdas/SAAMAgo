import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_panel.dart';
import '../../data/app_state.dart';
import '../../core/widgets/primary_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    required this.mobile,
    required this.verificationId,
    super.key,
  });

  final String mobile;
  final String verificationId;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _timer;
  int _seconds = 30;
  bool _isLoading = false;
  String? _error;
  late String _verificationId;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        timer.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _verify() async {
    if (_controller.text.length != 6) {
      setState(() => _error = 'Enter the six-digit code');
      return;
    }
    
    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _controller.text,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      try {
        await AppStateScope.of(context).fetchUser();
      } catch (_) {}

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, AppRoutes.location);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Invalid code. Try again.';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Enter OTP',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to ${AppFormatters.maskedMobile(widget.mobile)}.',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 32),
              AppPanel(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _focusNode.requestFocus(),
                      child: Row(
                        children: List.generate(6, (index) {
                          final hasDigit = index < _controller.text.length;
                          return Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              margin: EdgeInsets.only(
                                right: index == 5 ? 0 : 8,
                              ),
                              height: 56,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.input,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: hasDigit
                                      ? AppColors.primaryBlue
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                hasDigit ? _controller.text[index] : '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    Opacity(
                      opacity: 0,
                      child: SizedBox(
                        height: 1,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          onChanged: (_) => setState(() => _error = null),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Verify',
                      onPressed: _verify,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: _seconds == 0
                          ? () async {
                              _startTimer();
                              try {
                                await FirebaseAuth.instance.verifyPhoneNumber(
                                  phoneNumber: '+91${widget.mobile}',
                                  verificationCompleted: (_) {},
                                  verificationFailed: (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.message ?? 'Error')),
                                    );
                                  },
                                  codeSent: (verificationId, _) {
                                    if (!context.mounted) return;
                                    setState(() {
                                      _verificationId = verificationId;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('OTP sent successfully.')),
                                    );
                                  },
                                  codeAutoRetrievalTimeout: (_) {},
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to resend: $e')),
                                );
                              }
                            }
                          : null,
                      child: Text(
                        _seconds == 0
                            ? 'Resend OTP'
                            : 'Resend OTP in 00:${_seconds.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: _seconds == 0
                              ? AppColors.primaryTeal
                              : AppColors.secondaryText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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
