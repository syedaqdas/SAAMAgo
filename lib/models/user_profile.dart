class UserProfile {
  const UserProfile({
    required this.name,
    required this.handle,
    required this.rating,
    required this.trustScore,
    required this.itemsListed,
    required this.itemsBorrowed,
    required this.itemsLent,
  });

  final String name;
  final String handle;
  final double rating;
  final int trustScore;
  final int itemsListed;
  final int itemsBorrowed;
  final int itemsLent;
}
