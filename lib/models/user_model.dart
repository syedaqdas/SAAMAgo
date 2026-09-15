import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel({
    required this.uid,
    required this.phoneNumber,
    required this.displayName,
    this.email,
    this.profileImageUrl,
    this.location,
    required this.createdAt,
    required this.updatedAt,
    this.rating = 4.9,
    this.trustScore = 98,
    this.itemsListed = 0,
    this.itemsBorrowed = 0,
    this.itemsLent = 0,
  });

  final String uid;
  final String phoneNumber;
  final String displayName;
  final String? email;
  final String? profileImageUrl;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Mock fields for the existing UI
  final double rating;
  final int trustScore;
  final int itemsListed;
  final int itemsBorrowed;
  final int itemsLent;

  String get handle => '@';
  String get name => displayName;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      phoneNumber: data['phoneNumber'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'SAAMAgo User',
      email: data['email'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      location: data['location'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? email,
    String? profileImageUrl,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
