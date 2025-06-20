// import 'UserInfo.dart';
//
// class DriverModel {
//   final int id;
//   final int userId;
//   final String licenseNumber;
//   final String vehiclePlate;
//   final String status;
//   final double rating;
//   final int reviewsCount;
//   final double? latitude;
//   final double? longitude;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   // User relation
//   final UserInfo? user;
//
//   DriverModel({
//     required this.id,
//     required this.userId,
//     required this.licenseNumber,
//     required this.vehiclePlate,
//     required this.status,
//     required this.rating,
//     required this.reviewsCount,
//     this.latitude,
//     this.longitude,
//     required this.createdAt,
//     required this.updatedAt,
//     this.user,
//   });
//
//   factory DriverModel.fromJson(Map<String, dynamic> json) {
//     return DriverModel(
//       id: json['id'] ?? 0,
//       userId: json['user_id'] ?? 0,
//       licenseNumber: json['license_number'] ?? '',
//       vehiclePlate: json['vehicle_plate'] ?? '',
//       status: json['status'] ?? 'inactive',
//       rating: (json['rating'] ?? 5.0).toDouble(),
//       reviewsCount: json['reviews_count'] ?? 0,
//       latitude: json['latitude']?.toDouble(),
//       longitude: json['longitude']?.toDouble(),
//       createdAt: DateTime.parse(
//           json['created_at'] ?? DateTime.now().toIso8601String()),
//       updatedAt: DateTime.parse(
//           json['updated_at'] ?? DateTime.now().toIso8601String()),
//       user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'user_id': userId,
//       'license_number': licenseNumber,
//       'vehicle_plate': vehiclePlate,
//       'status': status,
//       'rating': rating,
//       'reviews_count': reviewsCount,
//       'latitude': latitude,
//       'longitude': longitude,
//       'created_at': createdAt.toIso8601String(),
//       'updated_at': updatedAt.toIso8601String(),
//     };
//   }
//
//   String get displayName => user?.name ?? 'Unknown Driver';
//   String get displayEmail => user?.email ?? '';
//   String get displayPhone => user?.phone ?? '';
//   bool get isActive => status == 'active';
//   bool get isBusy => status == 'busy';
//   bool get isInactive => status == 'inactive';
//   String get ratingDisplay => rating.toStringAsFixed(1);
//   String get vehicleNumber => vehiclePlate;
//
//   String get statusDisplay {
//     switch (status) {
//       case 'active':
//         return 'Active';
//       case 'busy':
//         return 'Busy';
//       case 'inactive':
//         return 'Inactive';
//       default:
//         return 'Unknown';
//     }
//   }
//
//   bool get hasLocation => latitude != null && longitude != null;
// }
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

  // User relation (from backend join)
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

  // ✅ FIXED: fromJson to handle backend response format
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    try {
      return DriverModel(
        id: _parseIntSafely(json['id'], 0),
        userId: _parseIntSafely(json['user_id'], 0),
        licenseNumber: json['license_number']?.toString() ?? '',
        vehiclePlate: json['vehicle_plate']?.toString() ?? '',
        status: json['status']?.toString() ?? 'inactive',
        rating: _parseDoubleSafely(json['rating'], 5.0),
        reviewsCount: _parseIntSafely(json['reviews_count'], 0),
        latitude: _parseNullableDoubleSafely(json['latitude']),
        longitude: _parseNullableDoubleSafely(json['longitude']),
        createdAt: _parseDateTimeSafely(json['created_at']) ?? DateTime.now(),
        updatedAt: _parseDateTimeSafely(json['updated_at']) ?? DateTime.now(),
        user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
      );
    } catch (e) {
      print('❌ Error parsing DriverModel: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  // ✅ Helper methods for safe parsing
  static int _parseIntSafely(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    if (value is double) return value.toInt();
    return defaultValue;
  }

  static double _parseDoubleSafely(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static double? _parseNullableDoubleSafely(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static DateTime? _parseDateTimeSafely(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('⚠️ Failed to parse datetime: $value');
        return null;
      }
    }
    return null;
  }

  // ✅ toJson for sending data to backend
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

  // ✅ toCreateJson for creating new driver
  Map<String, dynamic> toCreateJson({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? avatar,
  }) {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'license_number': licenseNumber,
      'vehicle_plate': vehiclePlate,
      if (avatar != null && avatar.isNotEmpty) 'avatar': avatar,
    };
  }

  // ✅ toUpdateJson for updating driver
  Map<String, dynamic> toUpdateJson({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (licenseNumber.isNotEmpty) data['license_number'] = licenseNumber;
    if (vehiclePlate.isNotEmpty) data['vehicle_plate'] = vehiclePlate;
    if (status.isNotEmpty) data['status'] = status;
    if (avatar != null && avatar.isNotEmpty) data['avatar'] = avatar;

    return data;
  }

  // ✅ ENHANCED: Getters with better null safety
  String get displayName => user?.name ?? 'Unknown Driver';
  String get displayEmail => user?.email ?? 'No email provided';
  String get displayPhone => user?.phone ?? 'No phone provided';
  String get displayAvatar => user?.avatar ?? '';

  // ✅ Status helpers
  bool get isActive => status.toLowerCase() == 'active';
  bool get isBusy => status.toLowerCase() == 'busy';
  bool get isInactive => status.toLowerCase() == 'inactive';

  // ✅ Enhanced status display
  String get statusDisplay {
    switch (status.toLowerCase()) {
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

  // ✅ Status color for UI
  String get statusColorHex {
    switch (status.toLowerCase()) {
      case 'active':
        return '#4CAF50'; // Green
      case 'busy':
        return '#FF9800'; // Orange
      case 'inactive':
      default:
        return '#757575'; // Grey
    }
  }

  // ✅ Rating display
  String get ratingDisplay => rating.toStringAsFixed(1);
  String get ratingWithStars => '⭐ ${ratingDisplay}';

  // ✅ Vehicle info
  String get vehicleNumber => vehiclePlate;
  String get vehicleInfo =>
      vehiclePlate.isNotEmpty ? vehiclePlate : 'No vehicle';

  // ✅ Location helpers
  bool get hasLocation => latitude != null && longitude != null;
  String get locationDisplay {
    if (hasLocation) {
      return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
    }
    return 'Location not available';
  }

  // ✅ Reviews helpers
  String get reviewsDisplay {
    if (reviewsCount == 0) return 'No reviews';
    if (reviewsCount == 1) return '1 review';
    return '$reviewsCount reviews';
  }

  // ✅ Date helpers
  String get createdAtDisplay {
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')}/'
        '${createdAt.year}';
  }

  String get updatedAtDisplay {
    return '${updatedAt.day.toString().padLeft(2, '0')}/'
        '${updatedAt.month.toString().padLeft(2, '0')}/'
        '${updatedAt.year}';
  }

  // ✅ Availability check
  bool get isAvailableForDelivery => isActive && hasLocation;

  // ✅ copyWith method for updates
  DriverModel copyWith({
    int? id,
    int? userId,
    String? licenseNumber,
    String? vehiclePlate,
    String? status,
    double? rating,
    int? reviewsCount,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserInfo? user,
  }) {
    return DriverModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  // ✅ equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DriverModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // ✅ toString for debugging
  @override
  String toString() {
    return 'DriverModel{'
        'id: $id, '
        'userId: $userId, '
        'name: $displayName, '
        'email: $displayEmail, '
        'phone: $displayPhone, '
        'licenseNumber: $licenseNumber, '
        'vehiclePlate: $vehiclePlate, '
        'status: $status, '
        'rating: $rating, '
        'reviewsCount: $reviewsCount, '
        'hasLocation: $hasLocation'
        '}';
  }

  // ✅ Validation helpers
  bool get isValid {
    return id > 0 &&
        userId > 0 &&
        licenseNumber.isNotEmpty &&
        vehiclePlate.isNotEmpty &&
        displayName.isNotEmpty &&
        displayEmail.isNotEmpty;
  }

  List<String> get validationErrors {
    List<String> errors = [];

    if (id <= 0) errors.add('Invalid driver ID');
    if (userId <= 0) errors.add('Invalid user ID');
    if (licenseNumber.isEmpty) errors.add('License number is required');
    if (vehiclePlate.isEmpty) errors.add('Vehicle plate is required');
    if (displayName.isEmpty) errors.add('Driver name is required');
    if (displayEmail.isEmpty) errors.add('Email is required');
    if (rating < 0 || rating > 5) errors.add('Rating must be between 0 and 5');
    if (reviewsCount < 0) errors.add('Reviews count cannot be negative');

    return errors;
  }

  // ✅ Static factory methods
  static DriverModel empty() {
    return DriverModel(
      id: 0,
      userId: 0,
      licenseNumber: '',
      vehiclePlate: '',
      status: 'inactive',
      rating: 5.0,
      reviewsCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static DriverModel fromFormData(Map<String, dynamic> formData) {
    return DriverModel(
      id: _parseIntSafely(formData['id'], 0),
      userId: _parseIntSafely(formData['user_id'], 0),
      licenseNumber: formData['license_number']?.toString() ?? '',
      vehiclePlate: formData['vehicle_plate']?.toString() ?? '',
      status: formData['status']?.toString() ?? 'inactive',
      rating: _parseDoubleSafely(formData['rating'], 5.0),
      reviewsCount: _parseIntSafely(formData['reviews_count'], 0),
      latitude: _parseNullableDoubleSafely(formData['latitude']),
      longitude: _parseNullableDoubleSafely(formData['longitude']),
      createdAt: _parseDateTimeSafely(formData['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTimeSafely(formData['updated_at']) ?? DateTime.now(),
      user:
          formData['user'] != null ? UserInfo.fromJson(formData['user']) : null,
    );
  }

  // ✅ Helper methods for UI
  Map<String, dynamic> toDisplayMap() {
    return {
      'ID': id.toString(),
      'Name': displayName,
      'Email': displayEmail,
      'Phone': displayPhone,
      'License': licenseNumber,
      'Vehicle': vehiclePlate,
      'Status': statusDisplay,
      'Rating': ratingWithStars,
      'Reviews': reviewsDisplay,
      'Location': locationDisplay,
      'Created': createdAtDisplay,
      'Updated': updatedAtDisplay,
    };
  }

  // ✅ Search helper
  bool matchesSearchQuery(String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    return id.toString().contains(lowerQuery) ||
        displayName.toLowerCase().contains(lowerQuery) ||
        displayEmail.toLowerCase().contains(lowerQuery) ||
        displayPhone.contains(query) ||
        licenseNumber.toLowerCase().contains(lowerQuery) ||
        vehiclePlate.toLowerCase().contains(lowerQuery) ||
        status.toLowerCase().contains(lowerQuery);
  }

  // ✅ Filter helpers
  static List<DriverModel> filterByStatus(
      List<DriverModel> drivers, String status) {
    if (status.toLowerCase() == 'all') return drivers;
    return drivers
        .where((driver) => driver.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  static List<DriverModel> filterByRating(
      List<DriverModel> drivers, double minRating) {
    return drivers.where((driver) => driver.rating >= minRating).toList();
  }

  static List<DriverModel> filterAvailable(List<DriverModel> drivers) {
    return drivers.where((driver) => driver.isAvailableForDelivery).toList();
  }

  // ✅ Sort helpers
  static List<DriverModel> sortByName(List<DriverModel> drivers,
      {bool ascending = true}) {
    drivers.sort((a, b) => ascending
        ? a.displayName.compareTo(b.displayName)
        : b.displayName.compareTo(a.displayName));
    return drivers;
  }

  static List<DriverModel> sortByRating(List<DriverModel> drivers,
      {bool ascending = false}) {
    drivers.sort((a, b) => ascending
        ? a.rating.compareTo(b.rating)
        : b.rating.compareTo(a.rating));
    return drivers;
  }

  static List<DriverModel> sortByCreatedDate(List<DriverModel> drivers,
      {bool ascending = false}) {
    drivers.sort((a, b) => ascending
        ? a.createdAt.compareTo(b.createdAt)
        : b.createdAt.compareTo(a.createdAt));
    return drivers;
  }
}
