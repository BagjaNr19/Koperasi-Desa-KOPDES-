class ProductModel {
  final String? id;
  final String name;
  final String? category;
  final double price;
  final int stock;
  final String? description;
  final String? imageUrl;
  final double? rating;

  ProductModel({
    this.id,
    required this.name,
    this.category,
    required this.price,
    required this.stock,
    this.description,
    this.imageUrl,
    this.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? json['category_name'] ?? (json['categories'] is Map ? json['categories']['name'] : null),
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      stock: json['stock'] != null ? int.parse(json['stock'].toString()) : 0,
      description: json['description'],
      imageUrl: json['image_url'] ?? json['image'],
      rating: (json['rating'] ?? json['average_rating']) != null ? double.parse((json['rating'] ?? json['average_rating']).toString()) : null,
    );
  }
}
