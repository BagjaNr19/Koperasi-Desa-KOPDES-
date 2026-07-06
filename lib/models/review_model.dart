class ReviewModel {
  final String? id;
  final String? userId;
  final String? userName;
  final double rating;
  final String comment;
  final String? createdAt;

  ReviewModel({
    this.id,
    this.userId,
    this.userName,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      userName: json['user_name'] ?? json['user']?['full_name'] ?? 'Anonim',
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : 0.0,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'],
    );
  }
}
