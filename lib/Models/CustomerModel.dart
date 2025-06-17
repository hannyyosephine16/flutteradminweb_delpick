class CustomerModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? address;
  final String? avatar;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Admin computed fields
  final int? totalOrders;
  final double? totalSpent;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.address,
    this.avatar,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
    this.totalOrders,
    this.totalSpent,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'customer',
      address: json['address'],
      avatar: json['avatar'],
      fcmToken: json['fcm_token'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      totalOrders: json['total_orders'],
      totalSpent: json['total_spent']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'address': address,
      'avatar': avatar,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Utility getters
  String get displayName => name;
  String get displayEmail => email;
  String get displayPhone => phone;
  String get displayAvatar => avatar ?? '';
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;
  String get registeredDate => createdAt.toString().split(' ')[0];
  String get lastUpdated => updatedAt.toString().split(' ')[0];
  int get orders => totalOrders ?? 0;
  double get spent => totalSpent ?? 0.0;
  String get spentDisplay => 'Rp ${spent.toStringAsFixed(0)}';
  String get ordersDisplay => '$orders orders';

  // Customer status based on activity - ADDED
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

  // Check if customer is active (has made order in last 30 days)
  bool get isActiveCustomer {
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    return updatedAt.isAfter(thirtyDaysAgo);
  }
}
