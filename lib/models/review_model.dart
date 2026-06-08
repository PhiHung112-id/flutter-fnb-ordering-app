class ReviewModel {
  final int id;
  final int orderId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}


