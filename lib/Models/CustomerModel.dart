class CustomerModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional computed fields for admin view
  final int? totalOrders;
  final double? totalSpent;
  final int? loyaltyPoints;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
    this.totalOrders,
    this.totalSpent,
    this.loyaltyPoints,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'customer',
      avatar: json['avatar'],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      totalOrders: json['totalOrders'],
      totalSpent: json['totalSpent']?.toDouble(),
      loyaltyPoints: json['loyaltyPoints'],
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'loyaltyPoints': loyaltyPoints,
    };
  }

  CustomerModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalOrders,
    double? totalSpent,
    int? loyaltyPoints,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
    );
  }

  @override
  String toString() {
    return 'CustomerModel(id: $id, name: $name, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Utility getters
  String get displayName => name;
  String get displayEmail => email;
  String get displayPhone => phone;
  String get displayAvatar => avatar ?? '';

  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;

  String get registeredDate =>
      createdAt.toString().split(' ')[0]; // YYYY-MM-DD format
  String get lastUpdated => updatedAt.toString().split(' ')[0];

  int get orders => totalOrders ?? 0;
  double get spent => totalSpent ?? 0.0;
  int get points => loyaltyPoints ?? 0;

  String get spentDisplay => 'Rp ${spent.toStringAsFixed(0)}';
  String get ordersDisplay => '$orders orders';
  String get pointsDisplay => '$points points';

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

  // Calculate days since registration
  int get daysSinceRegistration {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  // Format for display in admin panel
  Map<String, String> get displayData => {
        'ID': id.toString(),
        'Name': name,
        'Email': email,
        'Phone': phone,
        'Orders': ordersDisplay,
        'Spent': spentDisplay,
        'Status': customerStatus,
        'Tier': customerTier,
        'Joined': registeredDate,
      };

  // Check if customer is active (has made order in last 30 days)
  bool get isActiveCustomer {
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    return updatedAt.isAfter(thirtyDaysAgo);
  }

  // Average order value
  double get averageOrderValue {
    if (orders == 0) return 0.0;
    return spent / orders;
  }

  String get averageOrderValueDisplay =>
      'Rp ${averageOrderValue.toStringAsFixed(0)}';
}
