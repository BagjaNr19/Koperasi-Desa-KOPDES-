import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

class ProductService {
  // Ambil daftar kategori
  Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/categories'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil kategori');
    }
  }

  // Ambil daftar produk dengan opsional search
  Future<List<ProductModel>> getProducts({String? search, String? categoryId, String? sort, int page = 1}) async {
    String url = '${ApiConfig.baseUrl}/products?page=$page';
    if (search != null && search.isNotEmpty) {
      url += '&search=$search'; 
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      url += '&category_id=$categoryId';
    }
    if (sort != null && sort.isNotEmpty) {
      url += '&sort=$sort';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      var data = decoded['data'];
      List items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['products'] != null) {
        items = data['products'];
      }
      return items.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil produk');
    }
  }

  // Ambil detail produk
  Future<ProductModel> getProductDetail(String id) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/products/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return ProductModel.fromJson(data);
    } else {
      throw Exception('Gagal mengambil detail produk');
    }
  }

  // Ambil daftar review produk
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/reviews/product/$productId'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((json) => ReviewModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil review');
    }
  }
}
