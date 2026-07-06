class UserModel {
  final String? id;
  final String email;
  final String fullName;
  final String? phone;
  final String? role;

  UserModel({
    this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.role,
  });

  // Konversi dari JSON ke object UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone']?.toString(),
      role: (json['role'] is Map) ? json['role']['name'] : json['role'],
    );
  }

  // Konversi dari object UserModel ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
    };
  }
}
