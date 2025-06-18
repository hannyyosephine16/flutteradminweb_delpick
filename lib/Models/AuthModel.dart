class AuthModel {
  final String token;
  final UserData user;
  final DriverData? driver;
  final StoreData? store;

  AuthModel({
    required this.token,
    required this.user,
    this.driver,
    this.store,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'] ?? '',
      user: UserData.fromJson(json['user'] ?? {}),
      driver:
          json['driver'] != null ? DriverData.fromJson(json['driver']) : null,
      store: json['store'] != null ? StoreData.fromJson(json['store']) : null,
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
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'],
      fcmToken: json['fcm_token'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';
  bool get isStore => role == 'store';
  bool get isDriver => role == 'driver';
}

class DriverData {
  final int id;
  final int userId;
  final String licenseNumber;
  final String vehiclePlate;
  final String status;
  final double rating;
  final int reviewsCount;
  final double? latitude;
  final double? longitude;

  DriverData({
    required this.id,
    required this.userId,
    required this.licenseNumber,
    required this.vehiclePlate,
    required this.status,
    required this.rating,
    required this.reviewsCount,
    this.latitude,
    this.longitude,
  });

  factory DriverData.fromJson(Map<String, dynamic> json) {
    return DriverData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      licenseNumber: json['license_number'] ?? '',
      vehiclePlate: json['vehicle_plate'] ?? '',
      status: json['status'] ?? 'inactive',
      rating: (json['rating'] ?? 5.0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}

class StoreData {
  final int id;
  final int userId;
  final String name;
  final String address;
  final String? description;
  final String? openTime;
  final String? closeTime;
  final double? rating;
  final int? totalProducts;
  final String? imageUrl;
  final String phone;
  final int? reviewCount;
  final double latitude;
  final double longitude;
  final String status;

  StoreData({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    this.description,
    this.openTime,
    this.closeTime,
    this.rating,
    this.totalProducts,
    this.imageUrl,
    required this.phone,
    this.reviewCount,
    required this.latitude,
    required this.longitude,
    required this.status,
  });

  factory StoreData.fromJson(Map<String, dynamic> json) {
    return StoreData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'],
      openTime: json['open_time'],
      closeTime: json['close_time'],
      rating: json['rating']?.toDouble(),
      totalProducts: json['total_products'],
      imageUrl: json['image_url'],
      phone: json['phone'] ?? '',
      reviewCount: json['review_count'],
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      status: json['status'] ?? 'active',
    );
  }
}
