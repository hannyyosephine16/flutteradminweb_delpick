import 'UserInfo.dart';

class StoreModel {
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
  final double? distance;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final UserInfo? user;

  StoreModel({
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
    this.distance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
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
      distance: json['distance']?.toDouble(),
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      user: json['user'] != null || json['owner'] != null
          ? UserInfo.fromJson(json['user'] ?? json['owner'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'address': address,
      'description': description,
      'open_time': openTime,
      'close_time': closeTime,
      'rating': rating,
      'total_products': totalProducts,
      'image_url': imageUrl,
      'phone': phone,
      'review_count': reviewCount,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => name;
  String get ownerName => user?.name ?? 'Unknown Owner';
  String get ownerEmail => user?.email ?? '';
  String get ownerPhone => user?.phone ?? '';
  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isClosed => status == 'closed';
  String get ratingDisplay => rating?.toStringAsFixed(1) ?? '0.0';

  String get operatingHours {
    if (openTime != null && closeTime != null) {
      return '$openTime - $closeTime';
    }
    return 'Not specified';
  }

  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'closed':
        return 'Closed';
      default:
        return 'Unknown';
    }
  }

  String get distanceDisplay {
    if (distance != null) {
      return '${distance!.toStringAsFixed(1)} km';
    }
    return 'Unknown distance';
  }

  String get productsDisplay => '${totalProducts ?? 0} products';
  String get reviewsDisplay => '${reviewCount ?? 0} reviews';
  bool get hasRating => rating != null && rating! > 0;
  bool get hasReviews => reviewCount != null && reviewCount! > 0;
  bool get hasProducts => totalProducts != null && totalProducts! > 0;
}
