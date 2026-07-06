import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../models/user_model.dart';
import '../utils/token_storage.dart';

class AuthService {
  // Fungsi register
  Future<void> register(String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal melakukan registrasi: ${response.body}');
    }
  }

  // Fungsi login
  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['access_token']; // Kembalikan token jika sukses
    } else {
      throw Exception('Login gagal, periksa email atau password Anda');
    }
  }

  // Fungsi get profile
  Future<UserModel> getProfile() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data['data']);
    } else {
      throw Exception('Gagal mengambil data profil');
    }
  }

  // Fungsi update profile
  Future<void> updateProfile(String fullName, String phone) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'full_name': fullName,
        'phone': phone,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengupdate profil');
    }
  }
}
