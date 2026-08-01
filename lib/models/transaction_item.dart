import 'package:flutter/material.dart';

class TransactionItem {
  const TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final int amount;
  final bool isPositive;
  final IconData icon;
}
