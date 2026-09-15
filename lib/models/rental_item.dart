import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RentalItem {
  const RentalItem({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePerDay,
    required this.distanceKm,
    required this.rating,
    required this.deposit,
    required this.condition,
    required this.availability,
    required this.description,
    required this.ownerName,
    required this.ownerTrustScore,
    required this.icon,
    required this.gradient,
    this.isFavourite = false,
    this.imagePath,
    this.ownerId = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String category;
  final int pricePerDay;
  final double distanceKm;
  final double rating;
  final int deposit;
  final String condition;
  final String availability;
  final String description;
  final String ownerName;
  final int ownerTrustScore;
  final IconData icon;
  final List<Color> gradient;
  final bool isFavourite;
  final String? imagePath;
  final String ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isAvailable => availability.toLowerCase() != 'unavailable';

  RentalItem copyWith({
    String? id,
    String? name,
    String? category,
    int? pricePerDay,
    double? distanceKm,
    double? rating,
    int? deposit,
    String? condition,
    String? availability,
    String? description,
    String? ownerName,
    int? ownerTrustScore,
    IconData? icon,
    List<Color>? gradient,
    bool? isFavourite,
    String? imagePath,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RentalItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      distanceKm: distanceKm ?? this.distanceKm,
      rating: rating ?? this.rating,
      deposit: deposit ?? this.deposit,
      condition: condition ?? this.condition,
      availability: availability ?? this.availability,
      description: description ?? this.description,
      ownerName: ownerName ?? this.ownerName,
      ownerTrustScore: ownerTrustScore ?? this.ownerTrustScore,
      icon: icon ?? this.icon,
      gradient: gradient ?? this.gradient,
      isFavourite: isFavourite ?? this.isFavourite,
      imagePath: imagePath ?? this.imagePath,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'pricePerDay': pricePerDay,
      'distanceKm': distanceKm,
      'rating': rating,
      'deposit': deposit,
      'condition': condition,
      'availability': availability,
      'description': description,
      'ownerName': ownerName,
      'ownerTrustScore': ownerTrustScore,
      'icon': icon.codePoint,
      'gradient': gradient.map((c) => c.toARGB32()).toList(),
      'isFavourite': isFavourite,
      'imagePath': imagePath,
      'ownerId': ownerId,
    };
  }

  factory RentalItem.fromJson(Map<String, dynamic> json) {
    return RentalItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      pricePerDay: json['pricePerDay'] as int,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      deposit: json['deposit'] as int,
      condition: json['condition'] as String,
      availability: json['availability'] as String,
      description: json['description'] as String,
      ownerName: json['ownerName'] as String,
      ownerTrustScore: json['ownerTrustScore'] as int,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      gradient: (json['gradient'] as List).map((c) => Color(c as int)).toList(),
      isFavourite: json['isFavourite'] as bool? ?? false,
      imagePath: json['imagePath'] as String?,
      ownerId: json['ownerId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'title': name,
      'description': description,
      'category': category,
      'condition': condition,
      'pricePerDay': pricePerDay,
      'location': distanceKm.toString(),
      'imageUrl': imagePath,
      'isAvailable': isAvailable,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      
      'distanceKm': distanceKm,
      'rating': rating,
      'deposit': deposit,
      'availability': availability,
      'ownerTrustScore': ownerTrustScore,
      'icon': icon.codePoint,
      'gradient': gradient.map((c) => c.toARGB32()).toList(),
    };
  }

  factory RentalItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return RentalItem(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? 'User',
      name: data['title'] as String? ?? data['name'] as String? ?? 'Item',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'Other',
      condition: data['condition'] as String? ?? 'Used',
      pricePerDay: (data['pricePerDay'] as num?)?.toInt() ?? 0,
      imagePath: data['imageUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 2.0,
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      deposit: (data['deposit'] as num?)?.toInt() ?? 0,
      availability: data['isAvailable'] == false ? 'Unavailable' : (data['availability'] as String? ?? 'Today'),
      ownerTrustScore: (data['ownerTrustScore'] as num?)?.toInt() ?? 100,
      icon: data['icon'] != null ? IconData(data['icon'] as int, fontFamily: 'MaterialIcons') : Icons.inventory_2_rounded,
      gradient: data['gradient'] != null 
          ? (data['gradient'] as List).map((c) => Color(c as int)).toList() 
          : const [Color(0xFFA78BFA), Color(0xFF312E81)],
    );
  }
}
