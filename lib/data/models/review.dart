class Review {
  final String id;
  final String productId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime date;
  final List<String> images;
  final bool verified;

  const Review({
    required this.id,
    required this.productId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    this.images = const [],
    this.verified = true,
  });
}
