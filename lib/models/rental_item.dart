import 'package:flutter/material.dart';

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
    );
  }
}
