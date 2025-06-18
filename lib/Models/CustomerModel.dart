// lib/Models/CustomerModel.dart
import 'package:flutter/material.dart';

class CustomerModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatar;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Admin computed fields (not from backend model directly)
  final int? totalOrders;
  final double? totalSpent;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
    this.totalOrders,
    this.totalSpent,
  });

  /// Create CustomerModel from JSON response from backend
  /// Handles both direct customer data and wrapped response format
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    // Handle wrapped response format (e.g., from API response with statusCode, message, data)
    Map<String, dynamic> customerData;
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      customerData = json['data'];
    } else {
      customerData = json;
    }

    return CustomerModel(
      id: _parseIntSafely(customerData['id']) ?? 0,
      name: customerData['name']?.toString() ?? '',
      email: customerData['email']?.toString() ?? '',
      phone: customerData['phone']?.toString() ?? '',
      role: customerData['role']?.toString() ?? 'customer',
      avatar: customerData['avatar']?.toString(),
      fcmToken: customerData['fcm_token']?.toString(),
      createdAt: _parseDateSafely(customerData['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateSafely(customerData['updated_at']) ?? DateTime.now(),
      totalOrders: _parseIntSafely(customerData['total_orders']),
      totalSpent: _parseDoubleSafely(customerData['total_spent']),
    );
  }

  /// Safe integer parsing
  static int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) return value.toInt();
    return null;
  }

  /// Safe double parsing
  static double? _parseDoubleSafely(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Safe date parsing with multiple format support
  static DateTime? _parseDateSafely(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      // Try different date formats
      try {
        // ISO 8601 format (most common from backend)
        if (value.contains('T')) {
          return DateTime.parse(value);
        }
        // MySQL datetime format
        if (value.contains(' ')) {
          return DateTime.parse(value.replaceFirst(' ', 'T'));
        }
        // Date only format
        if (value.contains('-') && value.length == 10) {
          return DateTime.parse('${value}T00:00:00.000Z');
        }
        // Fallback to parse
        return DateTime.parse(value);
      } catch (e) {
        print('Failed to parse date: $value, error: $e');
        return null;
      }
    }
    return null;
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar': avatar,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (totalOrders != null) 'total_orders': totalOrders,
      if (totalSpent != null) 'total_spent': totalSpent,
    };
  }

  /// Create a copy with updated fields
  CustomerModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? avatar,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalOrders,
    double? totalSpent,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }

  /// Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.role == role &&
        other.avatar == avatar &&
        other.fcmToken == fcmToken;
  }

  /// Hash code
  @override
  int get hashCode {
    return Object.hash(id, name, email, phone, role, avatar, fcmToken);
  }

  /// String representation
  @override
  String toString() {
    return 'CustomerModel(id: $id, name: $name, email: $email, phone: $phone, role: $role)';
  }

  // Utility getters with null safety
  String get displayName => name.isNotEmpty ? name : 'Unknown Customer';
  String get displayEmail => email.isNotEmpty ? email : 'No Email';
  String get displayPhone => phone.isNotEmpty ? phone : 'No Phone';
  String get displayAvatar => avatar ?? '';
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;

  // Date formatting
  String get registeredDate {
    try {
      return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String get lastUpdated {
    try {
      return '${updatedAt.year}-${updatedAt.month.toString().padLeft(2, '0')}-${updatedAt.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String get registeredDateTime {
    try {
      return '${registeredDate} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  // Statistics
  int get orders => totalOrders ?? 0;
  double get spent => totalSpent ?? 0.0;

  String get spentDisplay {
    if (spent == 0) return 'Rp 0';
    return 'Rp ${spent.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String get ordersDisplay => '$orders order${orders != 1 ? 's' : ''}';

  // Customer status based on activity
  String get customerStatus {
    if (orders == 0) return 'New Customer';
    if (orders >= 10) return 'Loyal Customer';
    if (orders >= 5) return 'Regular Customer';
    return 'Active Customer';
  }

  // Customer tier based on spending
  String get customerTier {
    if (spent >= 1000000) return 'Gold';
    if (spent >= 500000) return 'Silver';
    if (spent >= 100000) return 'Bronze';
    return 'Basic';
  }

  // Tier color for UI
  Color get tierColor {
    switch (customerTier) {
      case 'Gold':
        return const Color(0xFFFFD700);
      case 'Silver':
        return const Color(0xFFC0C0C0);
      case 'Bronze':
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  // Check if customer is active (has made order in last 30 days)
  bool get isActiveCustomer {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return updatedAt.isAfter(thirtyDaysAgo);
  }

  // Check if customer joined recently (last 7 days)
  bool get isNewCustomer {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return createdAt.isAfter(sevenDaysAgo);
  }

  // Time since registration
  String get timeSinceRegistered {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years != 1 ? 's' : ''} ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months != 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Validation helpers
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  bool get isValidPhone {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return RegExp(r'^[0-9]{10,13}$').hasMatch(cleanPhone);
  }

  bool get isValidName {
    return name.trim().length >= 3 && name.trim().length <= 50;
  }

  // Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];

    if (!isValidName) {
      errors.add('Name must be 3-50 characters');
    }
    if (!isValidEmail) {
      errors.add('Invalid email format');
    }
    if (!isValidPhone) {
      errors.add('Phone must be 10-13 digits');
    }

    return errors;
  }

  bool get isValid => validationErrors.isEmpty;

  /// Create list of customers from API response
  static List<CustomerModel> fromJsonList(dynamic jsonList) {
    if (jsonList is! List) return [];

    return jsonList
        .where((item) => item is Map<String, dynamic>)
        .map((item) => CustomerModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Create customer from wrapped API response
  static CustomerModel? fromApiResponse(Map<String, dynamic> response) {
    try {
      // Handle different response formats
      if (response.containsKey('data') && response['data'] != null) {
        return CustomerModel.fromJson(response['data']);
      } else if (response.containsKey('statusCode') &&
          response['statusCode'] == 200) {
        // Sometimes data is directly in response
        return CustomerModel.fromJson(response);
      } else {
        return CustomerModel.fromJson(response);
      }
    } catch (e) {
      print('Error parsing customer from API response: $e');
      return null;
    }
  }
}
