class OrderModel {
  final String id;
  final String status;
  final double totalAmount;
  final String createdAt;

  OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      totalAmount: json['total_amount'] != null ? double.parse(json['total_amount'].toString()) : 0.0,
      createdAt: json['created_at'] ?? '',
    );
  }
}
