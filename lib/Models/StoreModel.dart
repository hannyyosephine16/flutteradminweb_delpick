class StoreModel {
  final int id;
  final int userId;
  final String name;
  final String address;
  final String? description;
  final String? openTime;
  final String? closeTime;
  final double rating;
  final int totalProducts;
  final String? imageUrl;
  final String? phone;
  final int reviewCount;
  final double? latitude;
  final double? longitude;
  final double? distance;
  final String status; // 'active', 'inactive'
  final DateTime createdAt;
  final DateTime updatedAt;

  // User information (owner)
  final UserInfo? user;

  // Menu items (from relation)
  final List<MenuItemInfo>? menuItems;

  StoreModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    this.description,
    this.openTime,
    this.closeTime,
    required this.rating,
    required this.totalProducts,
    this.imageUrl,
    this.phone,
    required this.reviewCount,
    this.latitude,
    this.longitude,
    this.distance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.menuItems,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      rating: (json['rating'] ?? 0).toDouble(),
      totalProducts: json['totalProducts'] ?? 0,
      imageUrl: json['imageUrl'],
      phone: json['phone'],
      reviewCount: json['reviewCount'] ?? 0,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
      status: json['status'] ?? 'active',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
      menuItems: json['menuItems'] != null
          ? (json['menuItems'] as List)
              .map((item) => MenuItemInfo.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'address': address,
      'description': description,
      'openTime': openTime,
      'closeTime': closeTime,
      'rating': rating,
      'totalProducts': totalProducts,
      'imageUrl': imageUrl,
      'phone': phone,
      'reviewCount': reviewCount,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'menuItems': menuItems?.map((item) => item.toJson()).toList(),
    };
  }

  StoreModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? address,
    String? description,
    String? openTime,
    String? closeTime,
    double? rating,
    int? totalProducts,
    String? imageUrl,
    String? phone,
    int? reviewCount,
    double? latitude,
    double? longitude,
    double? distance,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserInfo? user,
    List<MenuItemInfo>? menuItems,
  }) {
    return StoreModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      rating: rating ?? this.rating,
      totalProducts: totalProducts ?? this.totalProducts,
      imageUrl: imageUrl ?? this.imageUrl,
      phone: phone ?? this.phone,
      reviewCount: reviewCount ?? this.reviewCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      menuItems: menuItems ?? this.menuItems,
    );
  }

  @override
  String toString() {
    return 'StoreModel(id: $id, name: $name, address: $address, status: $status, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoreModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Utility getters
  String get displayName => name;
  String get ownerName => user?.name ?? 'Unknown Owner';
  String get ownerEmail => user?.email ?? '';
  String get ownerPhone => user?.phone ?? '';

  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';

  String get ratingDisplay => rating.toStringAsFixed(1);
  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      default:
        return 'Unknown';
    }
  }

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  String get operatingHours {
    if (openTime != null && closeTime != null) {
      return '$openTime - $closeTime';
    }
    return 'Not specified';
  }

  String get distanceDisplay {
    if (distance != null) {
      return '${distance!.toStringAsFixed(1)} km';
    }
    return 'Unknown distance';
  }

  int get menuItemCount => menuItems?.length ?? totalProducts;
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

class MenuItemInfo {
  final int id;
  final String name;
  final int price;
  final String? description;
  final String? imageUrl;
  final int quantity;

  MenuItemInfo({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    required this.quantity,
  });

  factory MenuItemInfo.fromJson(Map<String, dynamic> json) {
    return MenuItemInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      description: json['description'],
      imageUrl: json['imageUrl'],
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }
}
