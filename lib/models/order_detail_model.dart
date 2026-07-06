import 'product_model.dart';

class OrderDetailModel {
  final String id;
  final String status;
  final double totalAmount;
  final String shippingAddress;
  final String? notes;
  final String createdAt;
  final List<OrderItemModel> items;

  OrderDetailModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.shippingAddress,
    this.notes,
    required this.createdAt,
    required this.items,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['order_items'] as List? ?? [];
    List<OrderItemModel> items = itemsList.map((i) => OrderItemModel.fromJson(i)).toList();

    return OrderDetailModel(
      id: json['id']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      totalAmount: json['total_amount'] != null ? double.parse(json['total_amount'].toString()) : 0.0,
      shippingAddress: json['shipping_address'] ?? '',
      notes: json['notes'],
      createdAt: json['created_at'] ?? '',
      items: items,
    );
  }
}

class OrderItemModel {
  final ProductModel product;
  final int quantity;
  final double price;
  final double subtotal;

  OrderItemModel({
    required this.product,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      product: ProductModel.fromJson(json['product'] ?? json['products'] ?? {}),
      quantity: json['quantity'] ?? 0,
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      subtotal: json['subtotal'] != null ? double.parse(json['subtotal'].toString()) : 0.0,
    );
  }
}
