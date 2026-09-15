import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label = 'Loading'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primaryBlue),
          const SizedBox(height: 14),
          Text(label, style: const TextStyle(color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}
