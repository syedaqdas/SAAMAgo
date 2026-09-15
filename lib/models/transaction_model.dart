import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TransactionType { deposit, refund, reward, payment, withdrawal, escrowHold }
enum TransactionStatus { pending, completed, failed }

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    this.gatewayTransactionId,
    required this.createdAt,
    this.description,
  });

  final String id;
  final String userId;
  final int amount;
  final TransactionType type;
  final TransactionStatus status;
  final String? gatewayTransactionId;
  final DateTime createdAt;
  final String? description;

  bool get isPositive {
    return type == TransactionType.deposit ||
        type == TransactionType.refund ||
        type == TransactionType.reward;
  }

  IconData get icon {
    switch (type) {
      case TransactionType.deposit:
        return Icons.add_card_rounded;
      case TransactionType.refund:
        return Icons.refresh_rounded;
      case TransactionType.reward:
        return Icons.stars_rounded;
      case TransactionType.payment:
        return Icons.payment_rounded;
      case TransactionType.withdrawal:
        return Icons.money_off_rounded;
      case TransactionType.escrowHold:
        return Icons.lock_rounded;
    }
  }

  String get title {
    switch (type) {
      case TransactionType.deposit:
        return 'Added Money';
      case TransactionType.refund:
        return 'Refund Received';
      case TransactionType.reward:
        return 'Cashback Reward';
      case TransactionType.payment:
        return 'Payment';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.escrowHold:
        return 'Security Deposit Held';
    }
  }

  String get subtitle {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    // Very simple formatting if no description is provided.
    // In a real app we'd use intl package to format createdAt.
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final year = createdAt.year;
    return '$day-$month-$year';
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    int? amount,
    TransactionType? type,
    TransactionStatus? status,
    String? gatewayTransactionId,
    DateTime? createdAt,
    String? description,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      gatewayTransactionId: gatewayTransactionId ?? this.gatewayTransactionId,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'type': type.name,
      'status': status.name,
      if (gatewayTransactionId != null) 'gatewayTransactionId': gatewayTransactionId,
      'createdAt': Timestamp.fromDate(createdAt),
      if (description != null) 'description': description,
    };
  }

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      amount: data['amount'] as int? ?? 0,
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.payment,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TransactionStatus.pending,
      ),
      gatewayTransactionId: data['gatewayTransactionId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.name,
      'status': status.name,
      'gatewayTransactionId': gatewayTransactionId,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: json['amount'] as int,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.payment,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      gatewayTransactionId: json['gatewayTransactionId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
    );
  }
}
