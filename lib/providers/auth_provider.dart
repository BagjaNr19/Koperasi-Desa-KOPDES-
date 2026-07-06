import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String _errorMessage = '';
  UserModel? _user;
  String? _token;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  UserModel? get user => _user;
  String? get token => _token;

  // Fungsi untuk set loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fungsi registrasi
  Future<bool> register(String fullName, String email, String password) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      await _authService.register(fullName, email, password);
      _setLoading(false);
      return true; // Berhasil
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false; // Gagal
    }
  }

  // Fungsi login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      _token = await _authService.login(email, password);
      if (_token != null) {
        await TokenStorage.saveToken(_token!); // Simpan ke SharedPreferences
        await getProfile(); // Ambil data profil setelah login
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Fungsi ambil profil
  Future<bool> getProfile() async {
    _setLoading(true);
    _errorMessage = '';
    try {
      _user = await _authService.getProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Fungsi update profil
  Future<bool> updateProfile(String fullName, String phone) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      await _authService.updateProfile(fullName, phone);
      await getProfile(); // Refresh profil setelah update
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Fungsi logout
  Future<void> logout() async {
    await TokenStorage.removeToken();
    _token = null;
    _user = null;
    notifyListeners();
  }

  // Fungsi cek status login saat awal buka aplikasi
  Future<bool> checkLogin() async {
    _token = await TokenStorage.getToken();
    if (_token != null) {
      // Jika token ada, coba ambil profil
      bool success = await getProfile();
      return success;
    }
    return false;
  }
}
