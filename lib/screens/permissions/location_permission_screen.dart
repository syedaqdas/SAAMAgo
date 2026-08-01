import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  void _continue(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.shell,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                const _LocationIllustration(),
                const SizedBox(height: 44),
                const Text(
                  'Allow Location',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                const Text(
                  'To find items around you and show nearby results.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    height: 1.45,
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Allow Location',
                  icon: Icons.my_location_rounded,
                  onPressed: () => _continue(context),
                ),
                const SizedBox(height: 14),
                SecondaryButton(
                  label: 'Not Now',
                  onPressed: () => _continue(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationIllustration extends StatelessWidget {
  const _LocationIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 230,
      child: CustomPaint(
        painter: _LocationPainter(),
        child: const Center(
          child: Icon(
            Icons.location_pin,
            color: AppColors.primaryPurple,
            size: 76,
          ),
        ),
      ),
    );
  }
}

class _LocationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final grid = Paint()
      ..color = AppColors.primaryPurple.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fill = Paint()
      ..color = AppColors.primaryPurple.withValues(alpha: 0.08);

    canvas.drawCircle(center, size.width * 0.42, fill);
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, size.width * i * 0.105, grid);
    }
    canvas
      ..drawLine(
        Offset(center.dx, 14),
        Offset(center.dx, size.height - 14),
        grid,
      )
      ..drawLine(
        Offset(14, center.dy),
        Offset(size.width - 14, center.dy),
        grid,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
