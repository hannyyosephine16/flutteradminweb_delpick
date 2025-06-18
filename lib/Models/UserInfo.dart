class UserInfo {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatar;
  final String? fcmToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'],
      fcmToken: json['fcm_token'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar': avatar,
      'fcm_token': fcmToken,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';
  bool get isStore => role == 'store';
  bool get isDriver => role == 'driver';
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;
  String get displayAvatar => avatar ?? '';
}
