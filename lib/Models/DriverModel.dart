class DriverModel {
  final int id;
  final int userId;
  final String vehicleNumber;
  final double rating;
  final int reviewsCount;
  final double? latitude;
  final double? longitude;
  final String status; // 'active', 'inactive', 'busy'
  final DateTime createdAt;
  final DateTime updatedAt;

  // User information (from relation)
  final UserInfo? user;

  // Order information (from relation)
  final List<OrderInfo>? orders;

  DriverModel({
    required this.id,
    required this.userId,
    required this.vehicleNumber,
    required this.rating,
    required this.reviewsCount,
    this.latitude,
    this.longitude,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.orders,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      vehicleNumber: json['vehicle_number'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      status: json['status'] ?? 'inactive',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
      orders: json['orders'] != null
          ? (json['orders'] as List)
              .map((order) => OrderInfo.fromJson(order))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'vehicle_number': vehicleNumber,
      'rating': rating,
      'reviews_count': reviewsCount,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'orders': orders?.map((order) => order.toJson()).toList(),
    };
  }

  DriverModel copyWith({
    int? id,
    int? userId,
    String? vehicleNumber,
    double? rating,
    int? reviewsCount,
    double? latitude,
    double? longitude,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserInfo? user,
    List<OrderInfo>? orders,
  }) {
    return DriverModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      orders: orders ?? this.orders,
    );
  }

  @override
  String toString() {
    return 'DriverModel(id: $id, userId: $userId, vehicleNumber: $vehicleNumber, status: $status, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DriverModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Utility getters
  String get displayName => user?.name ?? 'Unknown Driver';
  String get displayEmail => user?.email ?? '';
  String get displayPhone => user?.phone ?? '';
  String get displayAvatar => user?.avatar ?? '';

  bool get isActive => status == 'active';
  bool get isBusy => status == 'busy';
  bool get isInactive => status == 'inactive';

  String get ratingDisplay => rating.toStringAsFixed(1);
  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Active';
      case 'busy':
        return 'Busy';
      case 'inactive':
        return 'Inactive';
      default:
        return 'Unknown';
    }
  }

  bool get hasLocation => latitude != null && longitude != null;
}

// Supporting classes for relations
class UserInfo {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatar;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'],
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
    };
  }
}

class OrderInfo {
  final int id;
  final String code;
  final String orderStatus;
  final String deliveryStatus;
  final double total;
  final DateTime orderDate;

  OrderInfo({
    required this.id,
    required this.code,
    required this.orderStatus,
    required this.deliveryStatus,
    required this.total,
    required this.orderDate,
  });

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    return OrderInfo(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      orderStatus: json['order_status'] ?? '',
      deliveryStatus: json['delivery_status'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      orderDate:
          DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'order_status': orderStatus,
      'delivery_status': deliveryStatus,
      'total': total,
      'orderDate': orderDate.toIso8601String(),
    };
  }
}
