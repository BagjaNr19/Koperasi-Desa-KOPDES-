import 'package:flutter/foundation.dart';

import '../core/api_constants.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/token_storage.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────────────────────────
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────────────────────
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // ── Init ──────────────────────────────────────────────────────────────────────
  Future<void> checkAuthStatus() async {
    _setStatus(AuthStatus.loading);
    try {
      final hasToken = await TokenStorage.hasToken();
      if (!hasToken) {
        _setStatus(AuthStatus.unauthenticated);
        return;
      }

      // Try fetching current user profile to validate token
      // GET /api/auth/profile
      final response = await ApiService.instance.get(ApiConstants.me);
      final userData = _extractUserData(response);
      if (userData != null) {
        _user = UserModel.fromJson(userData);
        _setStatus(AuthStatus.authenticated);
      } else {
        await TokenStorage.clearAll();
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (_) {
      // Token expired or invalid
      await TokenStorage.clearAll();
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────────
  /// Response format:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "access_token": "...",
  ///     "refresh_token": "...",
  ///     "user": { "id": "uuid", "email": "...", "full_name": "...", ... }
  ///   }
  /// }
  Future<bool> login(String email, String password) async {
    _setLoading();
    try {
      final response = await ApiService.instance.post(
        ApiConstants.login,
        body: {'email': email, 'password': password},
        requiresAuth: false,
      );

      // Check success flag
      if (response is Map && response['success'] == false) {
        _setError(response['message']?.toString() ?? 'Login gagal');
        return false;
      }

      // Extract token — API returns data.access_token
      final data = response['data'] ?? response;
      final token = data['access_token']?.toString() ??
          data['token']?.toString();

      if (token == null || token.isEmpty) {
        _setError('Token tidak ditemukan dalam respons');
        return false;
      }

      await TokenStorage.saveToken(token);

      // Extract user
      final userData = _extractUserData(data) ?? _extractUserData(response);
      if (userData != null) {
        _user = UserModel.fromJson(userData);
        await _cacheUserData(_user!);
      }

      _setStatus(AuthStatus.authenticated);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Login gagal. Periksa email dan password Anda.');
      return false;
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────────
  /// Request body: { full_name, email, password }
  /// Response: { success: true, data: { user: {...} } }  — NO token returned
  /// → Must login separately after register
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading();
    try {
      final body = <String, dynamic>{
        'full_name': fullName,   // ← API uses 'full_name', not 'name'
        'email': email,
        'password': password,
      };
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;

      final response = await ApiService.instance.post(
        ApiConstants.register,
        body: body,
        requiresAuth: false,
      );

      if (response is Map && response['success'] == false) {
        // Extract validation errors if any
        final errors = response['errors'];
        String msg = response['message']?.toString() ?? 'Registrasi gagal';
        if (errors is List && errors.isNotEmpty) {
          msg = errors
              .map((e) => e['message']?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .join(', ');
        }
        _setError(msg);
        return false;
      }

      // This API does NOT return a token on register — redirect to login
      _setStatus(AuthStatus.unauthenticated);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Registrasi gagal. Coba lagi.');
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await ApiService.instance.post(ApiConstants.logout);
    } catch (_) {
      // Ignore logout API error — clear local session regardless
    } finally {
      await TokenStorage.clearAll();
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // ── Refresh User ──────────────────────────────────────────────────────────────
  Future<void> refreshUser() async {
    try {
      final response = await ApiService.instance.get(ApiConstants.me);
      final userData = _extractUserData(response);
      if (userData != null) {
        _user = UserModel.fromJson(userData);
        await _cacheUserData(_user!);
        notifyListeners();
      }
    } catch (_) {
      // Silently fail
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  /// Tries to find the user map from various possible response shapes.
  Map<String, dynamic>? _extractUserData(dynamic response) {
    if (response is! Map) return null;

    final data = response['data'];

    // Shape from /auth/profile: { success, data: { id, email, full_name, ... } }
    if (data is Map && data.containsKey('email')) {
      return Map<String, dynamic>.from(data);
    }

    // Shape from /auth/login: { data: { access_token, user: {...} } }
    if (data is Map && data['user'] is Map) {
      return Map<String, dynamic>.from(data['user'] as Map);
    }

    // Shape: { user: {...} }
    if (response['user'] is Map) {
      return Map<String, dynamic>.from(response['user'] as Map);
    }

    // Shape: already-flat user object { email: ..., full_name: ... }
    if (response.containsKey('email') && response.containsKey('id')) {
      return Map<String, dynamic>.from(response);
    }

    return null;
  }

  Future<void> _cacheUserData(UserModel user) async {
    await TokenStorage.saveUserData(
      userId: user.id,      // String UUID
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatar: user.avatar,
      role: user.role,
    );
  }

  void _setLoading() {
    _errorMessage = null;
    _setStatus(AuthStatus.loading);
  }

  void _setError(String message) {
    _errorMessage = message;
    _setStatus(
      _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    );
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
