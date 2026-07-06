import '../models/product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  final int quantity;
  final double subtotal;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.subtotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString() ?? '',
      product: ProductModel.fromJson(json['product'] ?? json['products'] ?? {}),
      quantity: json['quantity'] ?? 0,
      subtotal: json['subtotal'] != null ? double.parse(json['subtotal'].toString()) : 0.0,
    );
  }
}
