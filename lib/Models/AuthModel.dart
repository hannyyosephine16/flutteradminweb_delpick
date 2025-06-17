// lib/Models/AuthModel.dart
class AuthModel {
  final String token;
  final UserData user;

  AuthModel({
    required this.token,
    required this.user,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'] ?? '',
      user: UserData.fromJson(json['user'] ?? {}),
    );
  }
}

class UserData {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatar;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'],
    );
  }

  bool get isAdmin => role == 'admin';
}
