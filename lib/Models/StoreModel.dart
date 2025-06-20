// import 'UserInfo.dart';
//
// class StoreModel {
//   final int id;
//   final int userId;
//   final String name;
//   final String address;
//   final String? description;
//   final String? openTime;
//   final String? closeTime;
//   final double? rating;
//   final int? totalProducts;
//   final String? imageUrl;
//   final String phone;
//   final int? reviewCount;
//   final double latitude;
//   final double longitude;
//   final double? distance;
//   final String status;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   // Relations
//   final UserInfo? user;
//
//   StoreModel({
//     required this.id,
//     required this.userId,
//     required this.name,
//     required this.address,
//     this.description,
//     this.openTime,
//     this.closeTime,
//     this.rating,
//     this.totalProducts,
//     this.imageUrl,
//     required this.phone,
//     this.reviewCount,
//     required this.latitude,
//     required this.longitude,
//     this.distance,
//     required this.status,
//     required this.createdAt,
//     required this.updatedAt,
//     this.user,
//   });
//
//   factory StoreModel.fromJson(Map<String, dynamic> json) {
//     return StoreModel(
//       id: json['id'] ?? 0,
//       userId: json['user_id'] ?? 0,
//       name: json['name'] ?? '',
//       address: json['address'] ?? '',
//       description: json['description'],
//       openTime: json['open_time'],
//       closeTime: json['close_time'],
//       rating: json['rating']?.toDouble(),
//       totalProducts: json['total_products'],
//       imageUrl: json['image_url'],
//       phone: json['phone'] ?? '',
//       reviewCount: json['review_count'],
//       latitude: (json['latitude'] ?? 0).toDouble(),
//       longitude: (json['longitude'] ?? 0).toDouble(),
//       distance: json['distance']?.toDouble(),
//       status: json['status'] ?? 'active',
//       createdAt: DateTime.parse(
//           json['created_at'] ?? DateTime.now().toIso8601String()),
//       updatedAt: DateTime.parse(
//           json['updated_at'] ?? DateTime.now().toIso8601String()),
//       user: json['user'] != null || json['owner'] != null
//           ? UserInfo.fromJson(json['user'] ?? json['owner'])
//           : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'user_id': userId,
//       'name': name,
//       'address': address,
//       'description': description,
//       'open_time': openTime,
//       'close_time': closeTime,
//       'rating': rating,
//       'total_products': totalProducts,
//       'image_url': imageUrl,
//       'phone': phone,
//       'review_count': reviewCount,
//       'latitude': latitude,
//       'longitude': longitude,
//       'distance': distance,
//       'status': status,
//       'created_at': createdAt.toIso8601String(),
//       'updated_at': updatedAt.toIso8601String(),
//     };
//   }
//
//   String get displayName => name;
//   String get ownerName => user?.name ?? 'Unknown Owner';
//   String get ownerEmail => user?.email ?? '';
//   String get ownerPhone => user?.phone ?? '';
//   bool get isActive => status == 'active';
//   bool get isInactive => status == 'inactive';
//   bool get isClosed => status == 'closed';
//   String get ratingDisplay => rating?.toStringAsFixed(1) ?? '0.0';
//
//   String get operatingHours {
//     if (openTime != null && closeTime != null) {
//       return '$openTime - $closeTime';
//     }
//     return 'Not specified';
//   }
//
//   String get statusDisplay {
//     switch (status) {
//       case 'active':
//         return 'Active';
//       case 'inactive':
//         return 'Inactive';
//       case 'closed':
//         return 'Closed';
//       default:
//         return 'Unknown';
//     }
//   }
//
//   String get distanceDisplay {
//     if (distance != null) {
//       return '${distance!.toStringAsFixed(1)} km';
//     }
//     return 'Unknown distance';
//   }
//
//   String get productsDisplay => '${totalProducts ?? 0} products';
//   String get reviewsDisplay => '${reviewCount ?? 0} reviews';
//   bool get hasRating => rating != null && rating! > 0;
//   bool get hasReviews => reviewCount != null && reviewCount! > 0;
//   bool get hasProducts => totalProducts != null && totalProducts! > 0;
// }
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

  // ✅ FIXED: fromJson untuk handle response backend yang sebenarnya
  factory StoreModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing StoreModel from JSON...');
      print('📋 JSON keys: ${json.keys.toList()}');

      // ✅ Parse basic fields with proper type handling
      final id = _parseIntSafely(json['id'], 0);
      final userId = _parseIntSafely(json['user_id'], 0);
      final name = json['name']?.toString() ?? '';
      final address = json['address']?.toString() ?? '';
      final description = json['description']?.toString();
      final phone = json['phone']?.toString() ?? '';
      final status = json['status']?.toString() ?? 'active';

      // ✅ FIXED: Parse time fields (remove seconds if present)
      String? openTime = json['open_time']?.toString();
      if (openTime != null && openTime.contains(':')) {
        // Convert "07:00:00" to "07:00"
        final parts = openTime.split(':');
        if (parts.length >= 2) {
          openTime = '${parts[0]}:${parts[1]}';
        }
      }

      String? closeTime = json['close_time']?.toString();
      if (closeTime != null && closeTime.contains(':')) {
        // Convert "22:00:00" to "22:00"
        final parts = closeTime.split(':');
        if (parts.length >= 2) {
          closeTime = '${parts[0]}:${parts[1]}';
        }
      }

      // ✅ FIXED: Parse numeric fields with null safety
      final rating = _parseDoubleSafely(json['rating']);
      final totalProducts = _parseIntSafely(json['total_products'], null);
      final reviewCount = _parseIntSafely(json['review_count'], null);
      final distance = _parseDoubleSafely(json['distance']);

      // ✅ FIXED: Parse coordinates (backend sends as strings)
      final latitude = _parseDoubleSafely(json['latitude']) ?? 0.0;
      final longitude = _parseDoubleSafely(json['longitude']) ?? 0.0;

      // ✅ Parse image URL
      final imageUrl = json['image_url']?.toString();

      // ✅ FIXED: Parse dates with fallback
      final createdAt =
          _parseDateTimeSafely(json['created_at']) ?? DateTime.now();
      final updatedAt =
          _parseDateTimeSafely(json['updated_at']) ?? DateTime.now();

      // ✅ FIXED: Parse owner/user data
      UserInfo? owner;
      final ownerData = json['owner'] ?? json['user'];
      if (ownerData != null && ownerData is Map<String, dynamic>) {
        try {
          owner = UserInfo.fromJson(Map<String, dynamic>.from(ownerData));
          print('✅ Parsed owner: ${owner.name}');
        } catch (e) {
          print('⚠️ Failed to parse owner data: $e');
          print('📄 Owner data: $ownerData');
        }
      }

      final store = StoreModel(
        id: id,
        userId: userId,
        name: name,
        address: address,
        description: description?.isNotEmpty == true ? description : null,
        openTime: openTime,
        closeTime: closeTime,
        rating: rating,
        totalProducts: totalProducts,
        imageUrl: imageUrl?.isNotEmpty == true ? imageUrl : null,
        phone: phone,
        reviewCount: reviewCount,
        latitude: latitude,
        longitude: longitude,
        distance: distance,
        status: status,
        createdAt: createdAt,
        updatedAt: updatedAt,
        user: owner,
      );

      print(
          '✅ StoreModel parsed successfully: ${store.name} (ID: ${store.id})');
      return store;
    } catch (e, stackTrace) {
      print('❌ Error parsing StoreModel: $e');
      print('📄 JSON data: $json');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ✅ Helper methods for safe parsing
  static int _parseIntSafely(dynamic value, int? defaultValue) {
    if (value == null) return defaultValue ?? 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? defaultValue ?? 0;
    }
    if (value is double) return value.toInt();
    return defaultValue ?? 0;
  }

  static double? _parseDoubleSafely(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
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

  // ✅ FIXED: Display helpers with null safety
  String get displayName => name.isNotEmpty ? name : 'Unknown Store';
  String get ownerName => user?.name ?? 'Unknown Owner';
  String get ownerEmail => user?.email ?? '';
  String get ownerPhone => user?.phone ?? phone;

  // ✅ Status helpers
  bool get isActive => status.toLowerCase() == 'active';
  bool get isInactive => status.toLowerCase() == 'inactive';
  bool get isClosed => status.toLowerCase() == 'closed';

  // ✅ FIXED: Rating display with null handling
  String get ratingDisplay {
    if (rating == null || rating == 0) return '0.0';
    return rating!.toStringAsFixed(1);
  }

  // ✅ FIXED: Operating hours display
  String get operatingHours {
    if (openTime != null && closeTime != null) {
      return '$openTime - $closeTime';
    }
    return 'Not specified';
  }

  // ✅ Status display
  String get statusDisplay {
    switch (status.toLowerCase()) {
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

  // ✅ FIXED: Distance display with null handling
  String get distanceDisplay {
    if (distance != null) {
      return '${distance!.toStringAsFixed(1)} km';
    }
    return 'Unknown distance';
  }

  // ✅ FIXED: Products and reviews display
  String get productsDisplay => '${totalProducts ?? 0} products';
  String get reviewsDisplay => '${reviewCount ?? 0} reviews';

  // ✅ Boolean helpers
  bool get hasRating => rating != null && rating! > 0;
  bool get hasReviews => reviewCount != null && reviewCount! > 0;
  bool get hasProducts => totalProducts != null && totalProducts! > 0;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;

  // ✅ FIXED: Location helpers
  bool get hasValidLocation => latitude != 0.0 || longitude != 0.0;
  String get locationDisplay =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  // ✅ Image URL helper with base URL handling
  String get fullImageUrl {
    if (!hasImage) return '';

    final imageUrl = this.imageUrl!;

    // If already a full URL, return as-is
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }

    // If relative path, construct full URL
    // Adjust base URL according to your backend configuration
    return 'http://localhost:5000$imageUrl';
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

  // ✅ Contact info helper
  String get contactInfo {
    List<String> info = [];
    if (phone.isNotEmpty) info.add(phone);
    if (ownerEmail.isNotEmpty) info.add(ownerEmail);
    return info.join(' • ');
  }

  // ✅ Validation helpers
  bool get isValid {
    return id > 0 &&
        name.isNotEmpty &&
        address.isNotEmpty &&
        phone.isNotEmpty &&
        status.isNotEmpty &&
        hasValidLocation;
  }

  List<String> get validationErrors {
    List<String> errors = [];

    if (id <= 0) errors.add('Invalid store ID');
    if (name.isEmpty) errors.add('Store name is required');
    if (address.isEmpty) errors.add('Address is required');
    if (phone.isEmpty) errors.add('Phone is required');
    if (status.isEmpty) errors.add('Status is required');
    if (!hasValidLocation) errors.add('Valid location coordinates required');

    return errors;
  }

  // ✅ copyWith method for updates
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
    );
  }

  // ✅ equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoreModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // ✅ toString for debugging
  @override
  String toString() {
    return 'StoreModel{'
        'id: $id, '
        'name: $name, '
        'address: $address, '
        'phone: $phone, '
        'status: $status, '
        'rating: $ratingDisplay, '
        'owner: ${ownerName}, '
        'hasImage: $hasImage, '
        'location: $locationDisplay'
        '}';
  }

  // ✅ Static factory methods
  static StoreModel empty() {
    return StoreModel(
      id: 0,
      userId: 0,
      name: '',
      address: '',
      phone: '',
      latitude: 0.0,
      longitude: 0.0,
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // ✅ Helper for form data
  Map<String, dynamic> toFormData() {
    return {
      'name': name,
      'address': address,
      'description': description ?? '',
      'phone': phone,
      'open_time': openTime ?? '',
      'close_time': closeTime ?? '',
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'status': status,
    };
  }

  // ✅ Search helper
  bool matchesSearchQuery(String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    return id.toString().contains(lowerQuery) ||
        name.toLowerCase().contains(lowerQuery) ||
        address.toLowerCase().contains(lowerQuery) ||
        ownerName.toLowerCase().contains(lowerQuery) ||
        phone.contains(query) ||
        (description?.toLowerCase().contains(lowerQuery) ?? false);
  }

  // ✅ Status color for UI
  String get statusColorHex {
    switch (status.toLowerCase()) {
      case 'active':
        return '#4CAF50'; // Green
      case 'inactive':
        return '#FF9800'; // Orange
      case 'closed':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // ✅ Rating color for UI
  String get ratingColorHex {
    if (!hasRating) return '#9E9E9E';

    final ratingValue = rating!;
    if (ratingValue >= 4.5) return '#4CAF50'; // Green
    if (ratingValue >= 4.0) return '#8BC34A'; // Light Green
    if (ratingValue >= 3.5) return '#FFEB3B'; // Yellow
    if (ratingValue >= 3.0) return '#FF9800'; // Orange
    return '#F44336'; // Red
  }

  // ✅ Performance metrics
  Map<String, dynamic> get performanceMetrics {
    return {
      'rating': rating ?? 0.0,
      'totalProducts': totalProducts ?? 0,
      'reviewCount': reviewCount ?? 0,
      'averageProductsPerReview': reviewCount != null && reviewCount! > 0
          ? (totalProducts ?? 0) / reviewCount!
          : 0.0,
      'hasImage': hasImage,
      'hasDescription': hasDescription,
      'completenessScore': _calculateCompletenessScore(),
    };
  }

  double _calculateCompletenessScore() {
    int score = 0;
    int maxScore = 10;

    if (name.isNotEmpty) score++;
    if (address.isNotEmpty) score++;
    if (phone.isNotEmpty) score++;
    if (hasDescription) score++;
    if (hasImage) score++;
    if (openTime != null && closeTime != null) score++;
    if (hasValidLocation) score++;
    if (hasRating) score++;
    if (hasReviews) score++;
    if (hasProducts) score++;

    return (score / maxScore) * 100;
  }

  // ✅ Filter helpers
  static List<StoreModel> filterByStatus(
      List<StoreModel> stores, String status) {
    if (status.toLowerCase() == 'all') return stores;
    return stores
        .where((store) => store.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  static List<StoreModel> filterWithRating(
      List<StoreModel> stores, double minRating) {
    return stores
        .where((store) => store.hasRating && store.rating! >= minRating)
        .toList();
  }

  static List<StoreModel> filterWithProducts(List<StoreModel> stores) {
    return stores.where((store) => store.hasProducts).toList();
  }

  // ✅ Sort helpers
  static List<StoreModel> sortByName(List<StoreModel> stores,
      {bool ascending = true}) {
    stores.sort((a, b) =>
        ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
    return stores;
  }

  static List<StoreModel> sortByRating(List<StoreModel> stores,
      {bool ascending = false}) {
    stores.sort((a, b) {
      final aRating = a.rating ?? 0.0;
      final bRating = b.rating ?? 0.0;
      return ascending
          ? aRating.compareTo(bRating)
          : bRating.compareTo(aRating);
    });
    return stores;
  }

  static List<StoreModel> sortByCreatedDate(List<StoreModel> stores,
      {bool ascending = false}) {
    stores.sort((a, b) => ascending
        ? a.createdAt.compareTo(b.createdAt)
        : b.createdAt.compareTo(a.createdAt));
    return stores;
  }
}
