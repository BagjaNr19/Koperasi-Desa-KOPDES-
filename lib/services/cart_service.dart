import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../utils/token_storage.dart';
import '../models/cart_item_model.dart';

class CartService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Sesi telah habis, silakan login kembali');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get Cart
  Future<List<CartItemModel>> getCart() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cart'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? decoded;
      final List items = (data is Map && data['items'] != null) ? data['items'] : [];
      return items.map((json) => CartItemModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil keranjang');
    }
  }

  // Add to Cart
  Future<void> addToCart(String productId, int quantity) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cart'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal menambahkan ke keranjang');
    }
  }

  // Update Cart Item (Quantity)
  Future<void> updateCart(String cartItemId, int quantity) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/cart/$cartItemId'),
      headers: await _getHeaders(),
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengubah jumlah barang');
    }
  }

  // Delete Cart Item
  Future<void> deleteCartItem(String cartItemId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cart/$cartItemId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus barang dari keranjang');
    }
  }

  // Clear Cart
  Future<void> clearCart() async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cart'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengosongkan keranjang');
    }
  }
}
