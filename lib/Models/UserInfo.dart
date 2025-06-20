// class UserInfo {
//   final int id;
//   final String name;
//   final String email;
//   final String phone;
//   final String role;
//   final String? avatar;
//   final String? fcmToken;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//
//   UserInfo({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.role,
//     this.avatar,
//     this.fcmToken,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   factory UserInfo.fromJson(Map<String, dynamic> json) {
//     return UserInfo(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       phone: json['phone'] ?? '',
//       role: json['role'] ?? '',
//       avatar: json['avatar'],
//       fcmToken: json['fcm_token'],
//       createdAt: json['created_at'] != null
//           ? DateTime.parse(json['created_at'])
//           : null,
//       updatedAt: json['updated_at'] != null
//           ? DateTime.parse(json['updated_at'])
//           : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'role': role,
//       'avatar': avatar,
//       'fcm_token': fcmToken,
//       'created_at': createdAt?.toIso8601String(),
//       'updated_at': updatedAt?.toIso8601String(),
//     };
//   }
//
//   bool get isAdmin => role == 'admin';
//   bool get isCustomer => role == 'customer';
//   bool get isStore => role == 'store';
//   bool get isDriver => role == 'driver';
//   bool get hasAvatar => avatar != null && avatar!.isNotEmpty;
//   String get displayAvatar => avatar ?? '';
// }
// ✅ FIXED: UserInfo model to match backend user structure

class UserInfo {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatar;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserInfo({
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

  // ✅ FIXED: fromJson to handle backend user response format
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    try {
      return UserInfo(
        id: _parseIntSafely(json['id'], 0),
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        role: json['role']?.toString() ?? 'customer',
        avatar: json['avatar']?.toString(),
        fcmToken: json['fcm_token']?.toString(),
        createdAt: _parseDateTimeSafely(json['created_at']) ?? DateTime.now(),
        updatedAt: _parseDateTimeSafely(json['updated_at']) ?? DateTime.now(),
      );
    } catch (e) {
      print('❌ Error parsing UserInfo: $e');
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
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar': avatar,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ✅ toUpdateJson for updating user profile
  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> data = {};

    if (name.isNotEmpty) data['name'] = name;
    if (email.isNotEmpty) data['email'] = email;
    if (phone.isNotEmpty) data['phone'] = phone;
    if (avatar != null && avatar!.isNotEmpty) data['avatar'] = avatar;
    if (fcmToken != null && fcmToken!.isNotEmpty) data['fcm_token'] = fcmToken;

    return data;
  }

  // ✅ Display helpers
  String get displayName => name.isNotEmpty ? name : 'Unknown User';
  String get displayEmail => email.isNotEmpty ? email : 'No email';
  String get displayPhone => phone.isNotEmpty ? phone : 'No phone';
  String get displayAvatar => avatar ?? '';

  // ✅ Role helpers
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isCustomer => role.toLowerCase() == 'customer';
  bool get isDriver => role.toLowerCase() == 'driver';
  bool get isStore => role.toLowerCase() == 'store';

  String get roleDisplay {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'customer':
        return 'Customer';
      case 'driver':
        return 'Driver';
      case 'store':
        return 'Store Owner';
      default:
        return 'Unknown';
    }
  }

  // ✅ Avatar helpers
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;
  String get avatarUrl {
    if (hasAvatar) {
      // If avatar is already a full URL, return as is
      if (avatar!.startsWith('http')) {
        return avatar!;
      }
      // If avatar is a relative path, construct full URL
      // Adjust this based on your backend's file serving configuration
      return 'http://localhost:5000${avatar!}';
    }
    return '';
  }

  // ✅ Notification helpers
  bool get hasNotificationToken => fcmToken != null && fcmToken!.isNotEmpty;
  bool get canReceiveNotifications => hasNotificationToken;

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

  String get joinedDateDisplay => createdAtDisplay;

  // ✅ Validation helpers
  bool get isValid {
    return id > 0 &&
        name.isNotEmpty &&
        email.isNotEmpty &&
        _isValidEmail(email) &&
        role.isNotEmpty;
  }

  List<String> get validationErrors {
    List<String> errors = [];

    if (id <= 0) errors.add('Invalid user ID');
    if (name.isEmpty) errors.add('Name is required');
    if (email.isEmpty) errors.add('Email is required');
    if (!_isValidEmail(email)) errors.add('Invalid email format');
    if (role.isEmpty) errors.add('Role is required');
    if (phone.isNotEmpty && !_isValidPhone(phone))
      errors.add('Invalid phone format');

    return errors;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone.replaceAll(' ', ''));
  }

  // ✅ copyWith method for updates
  UserInfo copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? avatar,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ✅ equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // ✅ toString for debugging
  @override
  String toString() {
    return 'UserInfo{'
        'id: $id, '
        'name: $name, '
        'email: $email, '
        'phone: $phone, '
        'role: $role, '
        'hasAvatar: $hasAvatar, '
        'canReceiveNotifications: $canReceiveNotifications'
        '}';
  }

  // ✅ Static factory methods
  static UserInfo empty() {
    return UserInfo(
      id: 0,
      name: '',
      email: '',
      phone: '',
      role: 'customer',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static UserInfo fromFormData(Map<String, dynamic> formData) {
    return UserInfo(
      id: _parseIntSafely(formData['id'], 0),
      name: formData['name']?.toString() ?? '',
      email: formData['email']?.toString() ?? '',
      phone: formData['phone']?.toString() ?? '',
      role: formData['role']?.toString() ?? 'customer',
      avatar: formData['avatar']?.toString(),
      fcmToken: formData['fcm_token']?.toString(),
      createdAt: _parseDateTimeSafely(formData['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTimeSafely(formData['updated_at']) ?? DateTime.now(),
    );
  }

  // ✅ Helper methods for UI
  Map<String, dynamic> toDisplayMap() {
    return {
      'ID': id.toString(),
      'Name': displayName,
      'Email': displayEmail,
      'Phone': displayPhone,
      'Role': roleDisplay,
      'Avatar': hasAvatar ? 'Yes' : 'No',
      'Notifications': canReceiveNotifications ? 'Enabled' : 'Disabled',
      'Joined': joinedDateDisplay,
    };
  }

  // ✅ Search helper
  bool matchesSearchQuery(String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    return id.toString().contains(lowerQuery) ||
        name.toLowerCase().contains(lowerQuery) ||
        email.toLowerCase().contains(lowerQuery) ||
        phone.contains(query) ||
        role.toLowerCase().contains(lowerQuery);
  }

  // ✅ Role color for UI
  String get roleColorHex {
    switch (role.toLowerCase()) {
      case 'admin':
        return '#F44336'; // Red
      case 'driver':
        return '#2196F3'; // Blue
      case 'store':
        return '#FF9800'; // Orange
      case 'customer':
      default:
        return '#4CAF50'; // Green
    }
  }

  // ✅ Get initials for avatar placeholder
  String get initials {
    if (name.isEmpty) return 'U';

    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return nameParts[0].substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
  }

  // ✅ Contact info helper
  String get contactInfo {
    List<String> info = [];
    if (email.isNotEmpty) info.add(email);
    if (phone.isNotEmpty) info.add(phone);
    return info.join(' • ');
  }

  // ✅ Filter helpers
  static List<UserInfo> filterByRole(List<UserInfo> users, String role) {
    if (role.toLowerCase() == 'all') return users;
    return users
        .where((user) => user.role.toLowerCase() == role.toLowerCase())
        .toList();
  }

  static List<UserInfo> filterWithNotifications(List<UserInfo> users) {
    return users.where((user) => user.canReceiveNotifications).toList();
  }

  // ✅ Sort helpers
  static List<UserInfo> sortByName(List<UserInfo> users,
      {bool ascending = true}) {
    users.sort((a, b) =>
        ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
    return users;
  }

  static List<UserInfo> sortByEmail(List<UserInfo> users,
      {bool ascending = true}) {
    users.sort((a, b) =>
        ascending ? a.email.compareTo(b.email) : b.email.compareTo(a.email));
    return users;
  }

  static List<UserInfo> sortByRole(List<UserInfo> users,
      {bool ascending = true}) {
    users.sort((a, b) =>
        ascending ? a.role.compareTo(b.role) : b.role.compareTo(a.role));
    return users;
  }

  static List<UserInfo> sortByJoinDate(List<UserInfo> users,
      {bool ascending = false}) {
    users.sort((a, b) => ascending
        ? a.createdAt.compareTo(b.createdAt)
        : b.createdAt.compareTo(a.createdAt));
    return users;
  }

  // ✅ Permission helpers (for future use)
  bool canManageDrivers() => isAdmin;
  bool canManageStores() => isAdmin;
  bool canManageCustomers() => isAdmin;
  bool canViewOrders() => isAdmin || isStore || isDriver;
  bool canManageOrders() => isAdmin || isStore;
  bool canViewStatistics() => isAdmin;
}
