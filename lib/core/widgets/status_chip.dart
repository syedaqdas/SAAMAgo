import 'package:flutter/material.dart';

import '../../models/rental_request.dart';
import '../constants/app_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({required this.label, required this.color, super.key});

  factory StatusChip.forRequest(RequestStatus status) {
    return switch (status) {
      RequestStatus.pending => const StatusChip(
        label: 'Pending',
        color: AppColors.warning,
      ),
      RequestStatus.accepted => const StatusChip(
        label: 'Accepted',
        color: AppColors.success,
      ),
      RequestStatus.completed => const StatusChip(
        label: 'Completed',
        color: AppColors.success,
      ),
      RequestStatus.cancelled => const StatusChip(
        label: 'Cancelled',
        color: AppColors.error,
      ),
    };
  }

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
