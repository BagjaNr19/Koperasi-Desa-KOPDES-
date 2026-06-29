import 'package:shared_preferences/shared_preferences.dart';

/// Manages JWT token and user session persistence using SharedPreferences.
class TokenStorage {
  static const _keyToken = 'af_craft_token';
  static const _keyUserId = 'af_craft_user_id';
  static const _keyUserName = 'af_craft_user_name';
  static const _keyUserEmail = 'af_craft_user_email';
  static const _keyUserPhone = 'af_craft_user_phone';
  static const _keyUserAvatar = 'af_craft_user_avatar';
  static const _keyUserRole = 'af_craft_user_role';

  // ── Token ─────────────────────────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── User Data ─────────────────────────────────────────────────────────────────
  /// userId is a UUID string (not int) in this API
  static Future<void> saveUserData({
    required String userId,   // UUID string
    required String name,
    required String email,
    String? phone,
    String? avatar,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserEmail, email);
    if (phone != null) await prefs.setString(_keyUserPhone, phone);
    if (avatar != null) await prefs.setString(_keyUserAvatar, avatar);
    if (role != null) await prefs.setString(_keyUserRole, role);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId);
    if (userId == null) return null;

    return {
      'id': userId,
      'full_name': prefs.getString(_keyUserName) ?? '',
      'email': prefs.getString(_keyUserEmail) ?? '',
      'phone': prefs.getString(_keyUserPhone) ?? '',
      'avatar_url': prefs.getString(_keyUserAvatar) ?? '',
      'role': prefs.getString(_keyUserRole) ?? 'customer',
    };
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  // ── Clear Session ─────────────────────────────────────────────────────────────
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_keyToken),
      prefs.remove(_keyUserId),
      prefs.remove(_keyUserName),
      prefs.remove(_keyUserEmail),
      prefs.remove(_keyUserPhone),
      prefs.remove(_keyUserAvatar),
      prefs.remove(_keyUserRole),
    ]);
  }
}
