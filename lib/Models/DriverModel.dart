import 'UserInfo.dart';

class DriverModel {
  final int id;
  final int userId;
  final String licenseNumber;
  final String vehiclePlate;
  final String status;
  final double rating;
  final int reviewsCount;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  // User relation
  final UserInfo? user;

  DriverModel({
    required this.id,
    required this.userId,
    required this.licenseNumber,
    required this.vehiclePlate,
    required this.status,
    required this.rating,
    required this.reviewsCount,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      licenseNumber: json['license_number'] ?? '',
      vehiclePlate: json['vehicle_plate'] ?? '',
      status: json['status'] ?? 'inactive',
      rating: (json['rating'] ?? 5.0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'license_number': licenseNumber,
      'vehicle_plate': vehiclePlate,
      'status': status,
      'rating': rating,
      'reviews_count': reviewsCount,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => user?.name ?? 'Unknown Driver';
  String get displayEmail => user?.email ?? '';
  String get displayPhone => user?.phone ?? '';
  bool get isActive => status == 'active';
  bool get isBusy => status == 'busy';
  bool get isInactive => status == 'inactive';
  String get ratingDisplay => rating.toStringAsFixed(1);

  // ADDED - vehicleNumber getter
  String get vehicleNumber => vehiclePlate;

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
}
