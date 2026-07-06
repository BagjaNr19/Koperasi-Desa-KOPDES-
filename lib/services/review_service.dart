import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../utils/token_storage.dart';

class ReviewService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Sesi telah habis, silakan login kembali');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Create Review
  Future<void> createReview(String productId, double rating, String comment) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/reviews/product/$productId'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'rating': rating.toInt(),
        'comment': comment,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal mengirim ulasan');
    }
  }

  // Delete Review
  Future<void> deleteReview(String reviewId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/reviews/$reviewId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus ulasan');
    }
  }
}
