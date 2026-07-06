import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../utils/token_storage.dart';
import '../models/order_model.dart';
import '../models/order_detail_model.dart';

class OrderService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Sesi telah habis, silakan login kembali');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get Orders (History)
  Future<List<OrderModel>> getOrders({int page = 1}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/orders?page=$page'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      var data = decoded['data'];
      List items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['orders'] != null) {
        items = data['orders'];
      }
      return items.map((json) => OrderModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil daftar pesanan');
    }
  }

  // Get Order Detail
  Future<OrderDetailModel> getOrderDetail(String id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/orders/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return OrderDetailModel.fromJson(data);
    } else {
      throw Exception('Gagal mengambil detail pesanan');
    }
  }

  // Create Order (Checkout)
  Future<void> createOrder(String shippingAddress, String? notes) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/orders'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'shipping_address': shippingAddress,
        'notes': notes,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal membuat pesanan');
    }
  }
}
