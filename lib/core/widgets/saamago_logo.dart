import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class SaamaGoLogo extends StatelessWidget {
  const SaamaGoLogo({super.key, this.size = 82, this.showContainer = false});

  final double size;
  final bool showContainer;

  @override
  Widget build(BuildContext context) {
    final mark = CustomPaint(
      size: Size.square(size),
      painter: const _SaamaMarkPainter(),
    );

    if (!showContainer) {
      return mark;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(size * 0.24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.26),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.14),
      child: mark,
    );
  }
}

class _SaamaMarkPainter extends CustomPainter {
  const _SaamaMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final shader = AppColors.purpleGradient.createShader(Offset.zero & size);
    final stroke = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * 0.17;

    final path = Path()
      ..moveTo(size.width * 0.68, size.height * 0.15)
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.1,
        size.width * 0.22,
        size.height * 0.28,
        size.width * 0.32,
        size.height * 0.45,
      )
      ..cubicTo(
        size.width * 0.43,
        size.height * 0.62,
        size.width * 0.76,
        size.height * 0.46,
        size.width * 0.78,
        size.height * 0.67,
      )
      ..cubicTo(
        size.width * 0.8,
        size.height * 0.87,
        size.width * 0.48,
        size.height * 0.9,
        size.width * 0.28,
        size.height * 0.78,
      );
    canvas.drawPath(path, stroke);

    final linePaint = Paint()
      ..shader = shader
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawLine(
        Offset(size.width * 0.05, size.height * 0.42),
        Offset(size.width * 0.34, size.height * 0.42),
        linePaint,
      )
      ..drawLine(
        Offset(size.width * 0.1, size.height * 0.57),
        Offset(size.width * 0.42, size.height * 0.57),
        linePaint,
      )
      ..drawCircle(
        Offset(size.width * 0.06, size.height * 0.66),
        size.width * 0.04,
        linePaint,
      );

    final dotPaint = Paint()..shader = shader;
    canvas.drawCircle(
      Offset(size.width * 0.83, size.height * 0.14),
      size.width * 0.06,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
