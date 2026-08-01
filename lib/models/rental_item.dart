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
    );
  }
}
