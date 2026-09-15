import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'rental_item.dart';

enum RequestStatus { pending, accepted, rejected, completed, cancelled }

class RentalRequest {
  const RentalRequest({
    required this.id,
    required this.item,
    required this.durationDays,
    required this.amount,
    required this.personName,
    required this.status,
    required this.dateLabel,
    this.listingId = '',
    this.listingTitle = '',
    this.borrowerId = '',
    this.borrowerName = '',
    this.ownerId = '',
    this.ownerName = '',
    this.startDate,
    this.endDate,
    this.message,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final RentalItem item;
  final int durationDays;
  final int amount;
  final String personName;
  final RequestStatus status;
  final String dateLabel;
  
  final String listingId;
  final String listingTitle;
  final String borrowerId;
  final String borrowerName;
  final String ownerId;
  final String ownerName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RentalRequest copyWith({String? id, RequestStatus? status}) {
    return RentalRequest(
      id: id ?? this.id,
      item: item,
      durationDays: durationDays,
      amount: amount,
      personName: personName,
      status: status ?? this.status,
      dateLabel: dateLabel,
      listingId: listingId,
      listingTitle: listingTitle,
      borrowerId: borrowerId,
      borrowerName: borrowerName,
      ownerId: ownerId,
      ownerName: ownerName,
      startDate: startDate,
      endDate: endDate,
      message: message,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': item.toJson(),
      'durationDays': durationDays,
      'amount': amount,
      'personName': personName,
      'status': status.name,
      'dateLabel': dateLabel,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'borrowerId': borrowerId,
      'borrowerName': borrowerName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'message': message,
    };
  }

  factory RentalRequest.fromJson(Map<String, dynamic> json) {
    return RentalRequest(
      id: json['id'] as String,
      item: RentalItem.fromJson(json['item'] as Map<String, dynamic>),
      durationDays: json['durationDays'] as int,
      amount: json['amount'] as int,
      personName: json['personName'] as String,
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      dateLabel: json['dateLabel'] as String,
      listingId: json['listingId'] as String? ?? '',
      listingTitle: json['listingTitle'] as String? ?? '',
      borrowerId: json['borrowerId'] as String? ?? '',
      borrowerName: json['borrowerName'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'borrowerId': borrowerId,
      'borrowerName': borrowerName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'status': status.name,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'message': message,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      
      // UI fallback fields
      'durationDays': durationDays,
      'amount': amount,
      'dateLabel': dateLabel,
    };
  }

  factory RentalRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final bId = data['borrowerId'] as String? ?? '';
    final oId = data['ownerId'] as String? ?? '';
    final bName = data['borrowerName'] as String? ?? '';
    final oName = data['ownerName'] as String? ?? '';
    
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final displayPersonName = currentUid == bId ? oName : bName;

    final dummyItem = RentalItem(
      id: data['listingId'] as String? ?? '',
      name: data['listingTitle'] as String? ?? 'Item',
      category: 'Other',
      pricePerDay: 0,
      distanceKm: 0.0,
      rating: 5.0,
      deposit: 0,
      condition: 'Good',
      availability: 'Today',
      description: '',
      ownerName: oName,
      ownerTrustScore: 100,
      ownerId: oId,
      icon: Icons.inventory_2_rounded,
      gradient: const [Color(0xFFA78BFA), Color(0xFF312E81)],
    );

    return RentalRequest(
      id: doc.id,
      item: dummyItem,
      durationDays: (data['durationDays'] as num?)?.toInt() ?? 1,
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      personName: displayPersonName,
      status: RequestStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => RequestStatus.pending,
      ),
      dateLabel: data['dateLabel'] as String? ?? 'Today',
      
      listingId: data['listingId'] as String? ?? '',
      listingTitle: data['listingTitle'] as String? ?? '',
      borrowerId: bId,
      borrowerName: bName,
      ownerId: oId,
      ownerName: oName,
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      message: data['message'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
