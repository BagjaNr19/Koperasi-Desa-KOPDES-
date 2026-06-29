/// Represents a product from the API.
///
/// API response shape:
/// {
///   "id": "uuid-string",
///   "name": "...",
///   "slug": "...",
///   "description": "...",
///   "price": 15000000,
///   "stock": 50,
///   "category_id": "uuid",
///   "image_url": "https://...",      ← single string, not array
///   "is_active": true,
///   "created_at": "...",
///   "categories": { "id": "...", "name": "...", "slug": "..." }
/// }
class ProductModel {
  final String id;         // UUID string
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final int stock;
  final String? category;
  final List<String> images;
  final double? rating;
  final int? reviewCount;
  final bool isWishlisted;
  final bool isActive;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    required this.stock,
    this.category,
    this.images = const [],
    this.rating,
    this.reviewCount,
    this.isWishlisted = false,
    this.isActive = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse images — API returns single 'image_url' string
    List<String> parseImages() {
      // Try image_url first (actual API field)
      final imageUrl = json['image_url'];
      if (imageUrl is String && imageUrl.isNotEmpty) {
        return [imageUrl];
      }
      // Fallback: images array or single image field
      final raw = json['images'] ?? json['image'] ?? json['photo'];
      if (raw == null) return [];
      if (raw is List) {
        return raw
            .map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (raw is String && raw.isNotEmpty) return [raw];
      return [];
    }

    // Extract category name from nested 'categories' object or flat 'category'
    String? parseCategory() {
      final cats = json['categories'];
      if (cats is Map) {
        return cats['name']?.toString();
      }
      return json['category']?.toString() ??
          json['category_name']?.toString();
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _parseDouble(json['price']),
      originalPrice: json['original_price'] != null
          ? _parseDouble(json['original_price'])
          : null,
      discountPercent: json['discount_percent'] as int? ??
          json['discount'] as int?,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      category: parseCategory(),
      images: parseImages(),
      rating: json['rating'] != null ? _parseDouble(json['rating']) : null,
      reviewCount: (json['review_count'] as num?)?.toInt() ??
          (json['reviews'] as num?)?.toInt(),
      isWishlisted: json['is_wishlisted'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  String get thumbnail => images.isNotEmpty ? images.first : '';

  bool get hasDiscount =>
      discountPercent != null && discountPercent! > 0;

  bool get isInStock => stock > 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category': category,
        'image_url': thumbnail,
        'rating': rating,
      };

  ProductModel copyWith({bool? isWishlisted}) {
    return ProductModel(
      id: id,
      name: name,
      description: description,
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      stock: stock,
      category: category,
      images: images,
      rating: rating,
      reviewCount: reviewCount,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      isActive: isActive,
    );
  }

  @override
  String toString() => 'ProductModel(id: $id, name: $name, price: $price)';
}
