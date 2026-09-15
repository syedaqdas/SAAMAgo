import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_panel.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/app_state.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppPanel(
              child: Row(
                children: [
                  const Text(
                    '4.9',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: const [
                        _RatingBar(label: '5', value: 0.86),
                        _RatingBar(label: '4', value: 0.48),
                        _RatingBar(label: '3', value: 0.18),
                        _RatingBar(label: '2', value: 0.08),
                        _RatingBar(label: '1', value: 0.02),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final review in store.reviews) ...[
              AppPanel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.elevatedCard,
                      child: Text(
                        review.reviewerName.isEmpty
                            ? '?'
                            : review.reviewerName[0],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  review.reviewerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.warning,
                                size: 16,
                              ),
                              Text(review.rating.toStringAsFixed(1)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            review.date,
                            style: const TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            review.text,
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Write a Review',
              icon: Icons.rate_review_rounded,
              onPressed: () => _showReviewSheet(context, store),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewSheet(BuildContext context, SaamaGoStore store) {
    final controller = TextEditingController();
    var rating = 5.0;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.viewInsetsOf(context).bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Write a Review',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      divisions: 8,
                      label: rating.toStringAsFixed(1),
                      activeColor: AppColors.primaryBlue,
                      onChanged: (value) => setSheetState(() => rating = value),
                    ),
                    TextField(
                      controller: controller,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Share your experience',
                      ),
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      label: 'Submit Review',
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isEmpty) {
                          return;
                        }
                        store.submitReview(text, rating);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Review submitted.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 18, child: Text(label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 7,
                color: AppColors.primaryBlue,
                backgroundColor: AppColors.border,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
