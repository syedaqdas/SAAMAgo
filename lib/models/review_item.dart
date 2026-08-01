class ReviewItem {
  const ReviewItem({
    required this.reviewerName,
    required this.date,
    required this.rating,
    required this.text,
  });

  final String reviewerName;
  final String date;
  final double rating;
  final String text;
}
