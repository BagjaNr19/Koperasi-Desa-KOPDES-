/// Represents the authenticated user.
///
/// API returns:
/// {
///   "id": "uuid-string",
///   "email": "...",
///   "full_name": "...",    ← NOT "name"
///   "phone": null,
///   "avatar_url": null,    ← NOT "avatar"
///   "role": "customer"
/// }
class UserModel {
  final String id;      // UUID string
  final String name;    // mapped from full_name
  final String email;
  final String? phone;
  final String? avatar;
  final String? role;
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.role,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // id can be int or UUID string
      id: json['id']?.toString() ?? '',
      // API uses 'full_name', fallback to 'name'
      name: json['full_name']?.toString() ??
          json['name']?.toString() ??
          json['username']?.toString() ??
          '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      // API uses 'avatar_url', fallback to 'avatar'/'photo'
      avatar: json['avatar_url']?.toString() ??
          json['avatar']?.toString() ??
          json['photo']?.toString(),
      role: _parseRole(json['role']),
      createdAt: json['created_at']?.toString() ??
          json['createdAt']?.toString(),
    );
  }

  /// role can be a String ("customer") or an Object {"id": "...", "name": "customer"}
  static String? _parseRole(dynamic roleField) {
    if (roleField == null) return null;
    if (roleField is String) return roleField;
    if (roleField is Map) return roleField['name']?.toString();
    return roleField.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (avatar != null) 'avatar_url': avatar,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? role,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 &&
        parts[0].isNotEmpty &&
        parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  String get firstName => name.trim().split(' ').first;

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email)';
}
