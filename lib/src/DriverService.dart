// import 'dart:convert';
// import 'dart:math' as math;
// import 'package:dio/dio.dart';
// import 'BaseService.dart';
// import 'api_constant.dart';
// import '../Models/DriverModel.dart';
//
// class DriverService extends BaseService {
//   // ===== ADMIN OPERATIONS =====
//
//   /// Get all drivers with pagination and filtering (Admin only)
//   static Future<Map<String, dynamic>> getAllDrivers({
//     int page = 1,
//     int limit = 10,
//     String? search,
//     String sortBy = 'created_at',
//     String sortOrder = 'DESC',
//   }) async {
//     try {
//       final queryParams = BaseService.buildQueryParams(
//         page: page,
//         limit: limit,
//         search: search,
//         sortBy: sortBy,
//         sortOrder: sortOrder,
//       );
//
//       final response = await BaseService.get(
//         ApiConstants.drivers,
//         queryParameters: queryParams,
//       );
//
//       return response;
//     } catch (e) {
//       throw Exception('Failed to load drivers: ${e.toString()}');
//     }
//   }
//
//   /// Get all drivers as List<DriverModel> (Admin only)
//   static Future<List<DriverModel>> getAllDriversAsList({
//     int page = 1,
//     int limit = 10,
//     String? search,
//     String sortBy = 'created_at',
//     String sortOrder = 'DESC',
//   }) async {
//     try {
//       final response = await getAllDrivers(
//         page: page,
//         limit: limit,
//         search: search,
//         sortBy: sortBy,
//         sortOrder: sortOrder,
//       );
//
//       return extractDriverList(response);
//     } catch (e) {
//       throw Exception('Failed to load drivers list: ${e.toString()}');
//     }
//   }
//
//   /// Get driver by ID (Admin only)
//   static Future<DriverModel> getDriverById(String id) async {
//     try {
//       final endpoint = BaseService.buildUrlWithParams(
//         ApiConstants.driverById,
//         {'id': id},
//       );
//
//       final response = await BaseService.get(endpoint);
//       final data = BaseService.extractData(response);
//
//       return DriverModel.fromJson(data);
//     } catch (e) {
//       throw Exception('Failed to get driver: ${e.toString()}');
//     }
//   }
//
//   /// Create new driver (Admin only)
//   static Future<DriverModel> createDriver({
//     required String name,
//     required String email,
//     required String password,
//     required String phone,
//     required String licenseNumber,
//     required String vehiclePlate,
//     String? avatar,
//   }) async {
//     try {
//       final data = {
//         'name': name,
//         'email': email,
//         'password': password,
//         'phone': phone,
//         'license_number': licenseNumber,
//         'vehicle_plate': vehiclePlate,
//         if (avatar != null && avatar.isNotEmpty) 'avatar': avatar,
//       };
//
//       final response = await BaseService.post(
//         ApiConstants.drivers,
//         data: data,
//       );
//
//       final responseData = BaseService.extractData(response);
//       return DriverModel.fromJson(responseData);
//     } catch (e) {
//       throw Exception('Failed to create driver: ${e.toString()}');
//     }
//   }
//
//   /// Update driver (Admin only)
//   static Future<DriverModel> updateDriver({
//     required String id,
//     String? name,
//     String? email,
//     String? phone,
//     String? licenseNumber,
//     String? vehiclePlate,
//     String? status,
//     String? avatar,
//   }) async {
//     try {
//       final endpoint = BaseService.buildUrlWithParams(
//         ApiConstants.driverById,
//         {'id': id},
//       );
//
//       final data = <String, dynamic>{};
//       if (name != null) data['name'] = name;
//       if (email != null) data['email'] = email;
//       if (phone != null) data['phone'] = phone;
//       if (licenseNumber != null) data['license_number'] = licenseNumber;
//       if (vehiclePlate != null) data['vehicle_plate'] = vehiclePlate;
//       if (status != null) data['status'] = status;
//       if (avatar != null && avatar.isNotEmpty) data['avatar'] = avatar;
//
//       final response = await BaseService.put(endpoint, data: data);
//       final responseData = BaseService.extractData(response);
//
//       return DriverModel.fromJson(responseData);
//     } catch (e) {
//       throw Exception('Failed to update driver: ${e.toString()}');
//     }
//   }
//
//   /// Delete driver (Admin only)
//   static Future<bool> deleteDriver(String id) async {
//     try {
//       final endpoint = BaseService.buildUrlWithParams(
//         ApiConstants.driverById,
//         {'id': id},
//       );
//
//       await BaseService.delete(endpoint);
//       return true;
//     } catch (e) {
//       throw Exception('Failed to delete driver: ${e.toString()}');
//     }
//   }
//
//   /// Update driver status (Admin only)
//   static Future<DriverModel> updateDriverStatus({
//     required String id,
//     required String status,
//   }) async {
//     try {
//       final endpoint = BaseService.buildUrlWithParams(
//         ApiConstants.driverStatus,
//         {'id': id},
//       );
//
//       final response = await BaseService.patch(
//         endpoint,
//         data: {'status': status},
//       );
//
//       final responseData = BaseService.extractData(response);
//       return DriverModel.fromJson(responseData);
//     } catch (e) {
//       throw Exception('Failed to update driver status: ${e.toString()}');
//     }
//   }
//
//   // ===== DRIVER SELF-MANAGEMENT OPERATIONS =====
//
//   /// Update driver location (Driver only)
//   static Future<Map<String, dynamic>> updateDriverLocation({
//     required double latitude,
//     required double longitude,
//   }) async {
//     try {
//       // Based on backend route: PATCH /drivers/{id}/location
//       // For self-update, we need to get current user's driver ID
//       final userData = await BaseService.getUserData();
//       if (userData == null) {
//         throw Exception('User not logged in');
//       }
//
//       // Assuming driver ID is available in user data or we use a different endpoint
//       final response = await BaseService.patch(
//         '/drivers/location', // Backend might have a self-update endpoint
//         data: {
//           'latitude': latitude,
//           'longitude': longitude,
//         },
//       );
//
//       return BaseService.extractData(response);
//     } catch (e) {
//       throw Exception('Failed to update location: ${e.toString()}');
//     }
//   }
//
//   /// Update driver status (Driver only)
//   static Future<Map<String, dynamic>> updateOwnStatus(String status) async {
//     try {
//       final response = await BaseService.patch(
//         '/drivers/status', // Self-update endpoint
//         data: {'status': status},
//       );
//
//       return BaseService.extractData(response);
//     } catch (e) {
//       throw Exception('Failed to update status: ${e.toString()}');
//     }
//   }
//
//   /// Update driver profile (Driver only)
//   static Future<DriverModel> updateOwnProfile({
//     String? name,
//     String? email,
//     String? phone,
//     String? licenseNumber,
//     String? vehiclePlate,
//     String? avatar,
//   }) async {
//     try {
//       final data = <String, dynamic>{};
//       if (name != null) data['name'] = name;
//       if (email != null) data['email'] = email;
//       if (phone != null) data['phone'] = phone;
//       if (licenseNumber != null) data['license_number'] = licenseNumber;
//       if (vehiclePlate != null) data['vehicle_plate'] = vehiclePlate;
//       if (avatar != null && avatar.isNotEmpty) data['avatar'] = avatar;
//
//       final response = await BaseService.put(
//         '/drivers/me', // Self-update endpoint
//         data: data,
//       );
//
//       final responseData = BaseService.extractData(response);
//       return DriverModel.fromJson(responseData);
//     } catch (e) {
//       throw Exception('Failed to update profile: ${e.toString()}');
//     }
//   }
//
//   /// Get driver orders (Driver only)
//   static Future<Map<String, dynamic>> getDriverOrders({
//     int page = 1,
//     int limit = 10,
//   }) async {
//     try {
//       final queryParams = BaseService.buildQueryParams(
//         page: page,
//         limit: limit,
//       );
//
//       final response = await BaseService.get(
//         '/drivers/orders', // Self-orders endpoint
//         queryParameters: queryParams,
//       );
//
//       return response;
//     } catch (e) {
//       throw Exception('Failed to get driver orders: ${e.toString()}');
//     }
//   }
//
//   /// Get driver location by ID (for tracking)
//   static Future<Map<String, dynamic>> getDriverLocation(String driverId) async {
//     try {
//       final endpoint = BaseService.buildUrlWithParams(
//         ApiConstants.driverLocation,
//         {'id': driverId},
//       );
//
//       final response = await BaseService.get(endpoint);
//       return BaseService.extractData(response);
//     } catch (e) {
//       throw Exception('Failed to get driver location: ${e.toString()}');
//     }
//   }
//
//   // ===== DRIVER REQUEST OPERATIONS =====
//
//   /// Get driver requests (Driver only)
//   static Future<Map<String, dynamic>> getDriverRequests({
//     int page = 1,
//     int limit = 10,
//   }) async {
//     try {
//       final queryParams = BaseService.buildQueryParams(
//         page: page,
//         limit: limit,
//       );
//
//       final response = await BaseService.get(
//         ApiConstants.driverRequests,
//         queryParameters: queryParams,
//       );
//
//       return response;
//     } catch (e) {
//       throw Exception('Failed to get driver requests: ${e.toString()}');
//     }
//   }
//
//   /// Get driver request detail (Driver only)
//   static Future<Map<String, dynamic>> getDriverRequestDetail(
//       String requestId) async {
//     try {
//       final endpoint = BaseService.buildUrlWithParams(
//         ApiConstants.driverRequestById,
//         {'id': requestId},
//       );
//
//       final response = await BaseService.get(endpoint);
//       return BaseService.extractData(response);
//     } catch (e) {
//       throw Exception('Failed to get request detail: ${e.toString()}');
//     }
//   }
//
//   /// Respond to driver request (Driver only)
//   static Future<Map<String, dynamic>> respondToDriverRequest({
//     required String requestId,
//     required String action, // 'accept' or 'reject'
//     DateTime? estimatedPickupTime,
//     DateTime? estimatedDeliveryTime,
//   }) async {
//     try {
//       final endpoint = BaseService.buildUrlWithParams(
//         ApiConstants.respondDriverRequest,
//         {'id': requestId},
//       );
//
//       final data = {
//         'action': action,
//         if (estimatedPickupTime != null)
//           'estimatedPickupTime': estimatedPickupTime.toIso8601String(),
//         if (estimatedDeliveryTime != null)
//           'estimatedDeliveryTime': estimatedDeliveryTime.toIso8601String(),
//       };
//
//       final response = await BaseService.post(endpoint, data: data);
//       return BaseService.extractData(response);
//     } catch (e) {
//       throw Exception('Failed to respond to request: ${e.toString()}');
//     }
//   }
//
//   // ===== UTILITY METHODS =====
//
//   /// Test connection to backend
//   static Future<bool> testConnection() async {
//     return await BaseService.testConnection();
//   }
//
//   /// Validate driver data before submission
//   static Map<String, String?> validateDriverData({
//     required String name,
//     required String email,
//     required String phone,
//     required String licenseNumber,
//     required String vehiclePlate,
//     String? password,
//   }) {
//     Map<String, String?> errors = {};
//
//     // Name validation
//     if (name.trim().isEmpty) {
//       errors['name'] = 'Name is required';
//     } else if (name.trim().length < 2) {
//       errors['name'] = 'Name must be at least 2 characters';
//     }
//
//     // Email validation
//     if (email.trim().isEmpty) {
//       errors['email'] = 'Email is required';
//     } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
//       errors['email'] = 'Invalid email format';
//     }
//
//     // Phone validation
//     if (phone.trim().isEmpty) {
//       errors['phone'] = 'Phone is required';
//     } else if (!RegExp(r'^\+?[0-9]{10,15}$')
//         .hasMatch(phone.replaceAll(' ', ''))) {
//       errors['phone'] = 'Invalid phone format';
//     }
//
//     // License number validation
//     if (licenseNumber.trim().isEmpty) {
//       errors['licenseNumber'] = 'License number is required';
//     }
//
//     // Vehicle plate validation
//     if (vehiclePlate.trim().isEmpty) {
//       errors['vehiclePlate'] = 'Vehicle plate is required';
//     }
//
//     // Password validation (for create operations)
//     if (password != null) {
//       if (password.isEmpty) {
//         errors['password'] = 'Password is required';
//       } else if (password.length < 6) {
//         errors['password'] = 'Password must be at least 6 characters';
//       }
//     }
//
//     return errors;
//   }
//
//   /// Validate driver status
//   static bool isValidDriverStatus(String status) {
//     return ApiConstants.driverStatuses.contains(status);
//   }
//
//   /// Format driver data for display
//   static Map<String, dynamic> formatDriverData(Map<String, dynamic> driver) {
//     return {
//       'id': driver['id']?.toString() ?? '',
//       'name': driver['name'] ?? 'Unknown',
//       'email': driver['email'] ?? '',
//       'phone': driver['phone'] ?? '',
//       'license_number': driver['license_number'] ?? '',
//       'vehicle_plate': driver['vehicle_plate'] ?? '',
//       'status': driver['status'] ?? 'inactive',
//       'rating': driver['rating'] ?? 0.0,
//       'reviews_count': driver['reviews_count'] ?? 0,
//       'latitude': driver['latitude'],
//       'longitude': driver['longitude'],
//       'avatar': driver['avatar'],
//       'created_at': driver['created_at'],
//       'updated_at': driver['updated_at'],
//       'user': driver['user'], // User data if included
//     };
//   }
//
//   /// Extract driver list from API response
//   static List<DriverModel> extractDriverList(Map<String, dynamic> response) {
//     try {
//       final data = BaseService.extractData(response);
//
//       // Backend response: { statusCode: 200, message: "...", data: [...] }
//       // So data should be a List directly
//       if (data is List) {
//         final driverJsonList = List<Map<String, dynamic>>.from(data);
//         return driverJsonList
//             .map((json) => DriverModel.fromJson(json))
//             .toList();
//       }
//
//       // Fallback: if data is Map containing array
//       if (data is Map<String, dynamic>) {
//         List<dynamic>? driverList;
//
//         // Try different possible keys
//         if (data.containsKey('drivers')) {
//           driverList = data['drivers'] as List<dynamic>?;
//         } else if (data.containsKey('data')) {
//           driverList = data['data'] as List<dynamic>?;
//         } else if (data.containsKey('items')) {
//           driverList = data['items'] as List<dynamic>?;
//         }
//
//         if (driverList != null) {
//           final driverJsonList = List<Map<String, dynamic>>.from(driverList);
//           return driverJsonList
//               .map((json) => DriverModel.fromJson(json))
//               .toList();
//         }
//       }
//
//       // If no valid data found, return empty list
//       return [];
//     } catch (e) {
//       throw Exception('Failed to parse driver list: ${e.toString()}');
//     }
//   }
//
//   /// Get pagination info from response
//   static Map<String, dynamic> extractPaginationInfo(
//       Map<String, dynamic> response) {
//     return BaseService.extractPaginationData(response);
//   }
//
//   /// Calculate distance between two points using Haversine formula
//   static double calculateDistance(
//       double lat1, double lon1, double lat2, double lon2) {
//     const double earthRadius = 6371; // km
//     final double dLat = _degreesToRadians(lat2 - lat1);
//     final double dLon = _degreesToRadians(lon2 - lon1);
//
//     final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.cos(_degreesToRadians(lat1)) *
//             math.cos(_degreesToRadians(lat2)) *
//             math.sin(dLon / 2) *
//             math.sin(dLon / 2);
//
//     final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//
//     return earthRadius * c;
//   }
//
//   static double _degreesToRadians(double degrees) {
//     return degrees * (math.pi / 180);
//   }
//
//   /// Convert driver status to display text
//   static String getStatusDisplayText(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return 'Active';
//       case 'inactive':
//         return 'Inactive';
//       case 'busy':
//         return 'Busy';
//       default:
//         return 'Unknown';
//     }
//   }
//
//   /// Get available driver statuses
//   static List<String> getAvailableStatuses() {
//     return List.from(ApiConstants.driverStatuses);
//   }
//
//   /// Create driver from form data
//   static Future<DriverModel> createDriverFromForm(
//       Map<String, dynamic> formData) async {
//     // Validate data first
//     final errors = validateDriverData(
//       name: formData['name'] ?? '',
//       email: formData['email'] ?? '',
//       phone: formData['phone'] ?? '',
//       licenseNumber: formData['license_number'] ?? '',
//       vehiclePlate: formData['vehicle_plate'] ?? '',
//       password: formData['password'],
//     );
//
//     if (errors.isNotEmpty) {
//       final errorMessages =
//           errors.values.where((msg) => msg != null).join(', ');
//       throw Exception('Validation failed: $errorMessages');
//     }
//
//     return await createDriver(
//       name: formData['name'],
//       email: formData['email'],
//       password: formData['password'],
//       phone: formData['phone'],
//       licenseNumber: formData['license_number'],
//       vehiclePlate: formData['vehicle_plate'],
//       avatar: formData['avatar'],
//     );
//   }
//
//   /// Update driver from form data
//   static Future<DriverModel> updateDriverFromForm(
//       String id, Map<String, dynamic> formData) async {
//     return await updateDriver(
//       id: id,
//       name: formData['name'],
//       email: formData['email'],
//       phone: formData['phone'],
//       licenseNumber: formData['license_number'],
//       vehiclePlate: formData['vehicle_plate'],
//       status: formData['status'],
//       avatar: formData['avatar'],
//     );
//   }
//
//   /// Check if driver is available
//   static bool isDriverAvailable(DriverModel driver) {
//     return driver.status == 'active' && driver.hasLocation;
//   }
//
//   /// Get driver statistics
//   static Map<String, dynamic> getDriverStats(List<DriverModel> drivers) {
//     final activeDrivers = drivers.where((d) => d.isActive).length;
//     final busyDrivers = drivers.where((d) => d.isBusy).length;
//     final inactiveDrivers = drivers.where((d) => d.isInactive).length;
//     final averageRating = drivers.isEmpty
//         ? 0.0
//         : drivers.map((d) => d.rating).reduce((a, b) => a + b) / drivers.length;
//
//     return {
//       'total': drivers.length,
//       'active': activeDrivers,
//       'busy': busyDrivers,
//       'inactive': inactiveDrivers,
//       'averageRating': averageRating,
//     };
//   }
//
//   // ===== EXAMPLE USAGE =====
//
//   /// Example of how to use the DriverService
//   static Future<void> exampleUsage() async {
//     try {
//       // Initialize BaseService first
//       BaseService.initialize();
//
//       // Get all drivers
//       final response = await getAllDrivers(page: 1, limit: 10);
//       print('Response: $response');
//
//       // Extract drivers as List<DriverModel>
//       final drivers = extractDriverList(response);
//       print('Found ${drivers.length} drivers');
//
//       // Get pagination info
//       final pagination = extractPaginationInfo(response);
//       print('Pagination: $pagination');
//
//       // Create a new driver
//       final newDriver = await createDriver(
//         name: 'John Doe',
//         email: 'john@example.com',
//         password: 'password123',
//         phone: '08123456789',
//         licenseNumber: 'DL123456',
//         vehiclePlate: 'B1234ABC',
//       );
//       print('Created driver: ${newDriver.displayName}');
//
//       // Update driver status
//       final updatedDriver = await updateDriverStatus(
//         id: newDriver.id.toString(),
//         status: 'active',
//       );
//       print('Updated driver status: ${updatedDriver.statusDisplay}');
//     } catch (e) {
//       print('Error in example usage: $e');
//     }
//   }
// }
import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'BaseService.dart';
import 'api_constant.dart';
import '../Models/DriverModel.dart';

class DriverService extends BaseService {
  // ===== ADMIN OPERATIONS =====

  /// Get all drivers with pagination and filtering (Admin only)
  static Future<Map<String, dynamic>> getAllDrivers({
    int page = 1,
    int limit = 10,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'DESC',
  }) async {
    try {
      final queryParams = BaseService.buildQueryParams(
        page: page,
        limit: limit,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final response = await BaseService.get(
        ApiConstants.drivers,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to load drivers: ${e.toString()}');
    }
  }

  /// Get all drivers as List<DriverModel> (Admin only)
  static Future<List<DriverModel>> getAllDriversAsList({
    int page = 1,
    int limit = 10,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'DESC',
  }) async {
    try {
      final response = await getAllDrivers(
        page: page,
        limit: limit,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      return extractDriverList(response);
    } catch (e) {
      throw Exception('Failed to load drivers list: ${e.toString()}');
    }
  }

  /// Get driver by ID (Admin only)
  static Future<DriverModel> getDriverById(String id) async {
    try {
      final endpoint = BaseService.buildUrlWithParams(
        ApiConstants.driverById,
        {'id': id},
      );

      final response = await BaseService.get(endpoint);
      final data = BaseService.extractData(response);

      return DriverModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get driver: ${e.toString()}');
    }
  }

  /// ✅ FIXED: Create new driver (Admin only) - Handle proper response format
  static Future<DriverModel> createDriver({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String licenseNumber,
    required String vehiclePlate,
    String? avatar,
  }) async {
    try {
      print('🚗 Creating driver with data:');
      print('   Name: $name');
      print('   Email: $email');
      print('   Phone: $phone');
      print('   License: $licenseNumber');
      print('   Vehicle: $vehiclePlate');
      print('   Has Avatar: ${avatar != null}');

      final data = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'license_number': licenseNumber,
        'vehicle_plate': vehiclePlate,
        if (avatar != null && avatar.isNotEmpty) 'avatar': avatar,
      };

      print('📤 Request data: ${data.keys.toList()}');

      final response = await BaseService.post(
        ApiConstants.drivers,
        data: data,
      );

      print('📥 Create response: $response');

      // ✅ Handle backend response format for create
      // Format: { "message": "Driver berhasil ditambahkan", "data": { "user": {...}, "driver": {...} } }
      final responseData = BaseService.extractData(response);

      if (responseData is Map<String, dynamic>) {
        // ✅ Merge user and driver data for DriverModel
        final userData = responseData['user'] as Map<String, dynamic>?;
        final driverData = responseData['driver'] as Map<String, dynamic>?;

        if (userData != null && driverData != null) {
          // ✅ Create combined data structure for DriverModel.fromJson
          final combinedData = Map<String, dynamic>.from(driverData);
          combinedData['user'] = userData;

          print(
              '✅ Combined data for DriverModel: ${combinedData.keys.toList()}');
          return DriverModel.fromJson(combinedData);
        }
      }

      // ✅ Fallback if response format is different
      return DriverModel.fromJson(responseData);
    } catch (e) {
      print('❌ Error creating driver: $e');
      throw Exception('Failed to create driver: ${e.toString()}');
    }
  }

  /// ✅ FIXED: Update driver (Admin only) - Handle proper response format
  static Future<DriverModel> updateDriver({
    required String id,
    String? name,
    String? email,
    String? phone,
    String? licenseNumber,
    String? vehiclePlate,
    String? status,
    String? avatar,
  }) async {
    try {
      print('🔄 Updating driver $id with data:');
      print('   Name: $name');
      print('   Email: $email');
      print('   Phone: $phone');
      print('   License: $licenseNumber');
      print('   Vehicle: $vehiclePlate');
      print('   Status: $status');
      print('   Has Avatar: ${avatar != null}');

      final endpoint = BaseService.buildUrlWithParams(
        ApiConstants.driverById,
        {'id': id},
      );

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (licenseNumber != null) data['license_number'] = licenseNumber;
      if (vehiclePlate != null) data['vehicle_plate'] = vehiclePlate;
      if (status != null) data['status'] = status;
      if (avatar != null && avatar.isNotEmpty) data['avatar'] = avatar;

      print('📤 Update request data: ${data.keys.toList()}');

      final response = await BaseService.put(endpoint, data: data);

      print('📥 Update response: $response');

      // ✅ Handle backend response format for update
      // Format might be similar to create: { "message": "...", "data": { "user": {...}, "driver": {...} } }
      final responseData = BaseService.extractData(response);

      if (responseData is Map<String, dynamic>) {
        // ✅ Check if response has user and driver structure
        if (responseData.containsKey('user') &&
            responseData.containsKey('driver')) {
          final userData = responseData['user'] as Map<String, dynamic>;
          final driverData = responseData['driver'] as Map<String, dynamic>;

          // ✅ Create combined data structure for DriverModel.fromJson
          final combinedData = Map<String, dynamic>.from(driverData);
          combinedData['user'] = userData;

          print(
              '✅ Combined update data for DriverModel: ${combinedData.keys.toList()}');
          return DriverModel.fromJson(combinedData);
        }

        // ✅ Check if response is direct driver data with user nested
        if (responseData.containsKey('user')) {
          print('✅ Direct driver data with user nested');
          return DriverModel.fromJson(responseData);
        }
      }

      // ✅ Fallback: treat as direct driver data
      print('✅ Fallback: treating as direct driver data');
      return DriverModel.fromJson(responseData);
    } catch (e) {
      print('❌ Error updating driver: $e');
      throw Exception('Failed to update driver: ${e.toString()}');
    }
  }

  /// Delete driver (Admin only)
  static Future<bool> deleteDriver(String id) async {
    try {
      final endpoint = BaseService.buildUrlWithParams(
        ApiConstants.driverById,
        {'id': id},
      );

      await BaseService.delete(endpoint);
      return true;
    } catch (e) {
      throw Exception('Failed to delete driver: ${e.toString()}');
    }
  }

  /// ✅ FIXED: Update driver status (Admin only)
  static Future<DriverModel> updateDriverStatus({
    required String id,
    required String status,
  }) async {
    try {
      print('🔄 Updating driver $id status to: $status');

      final endpoint = BaseService.buildUrlWithParams(
        ApiConstants.driverStatus,
        {'id': id},
      );

      final response = await BaseService.patch(
        endpoint,
        data: {'status': status},
      );

      print('📥 Status update response: $response');

      // ✅ Handle response format similar to update method
      final responseData = BaseService.extractData(response);

      if (responseData is Map<String, dynamic>) {
        // ✅ Check if response has user and driver structure
        if (responseData.containsKey('user') &&
            responseData.containsKey('driver')) {
          final userData = responseData['user'] as Map<String, dynamic>;
          final driverData = responseData['driver'] as Map<String, dynamic>;

          final combinedData = Map<String, dynamic>.from(driverData);
          combinedData['user'] = userData;

          return DriverModel.fromJson(combinedData);
        }

        // ✅ Check if response is direct driver data with user nested
        if (responseData.containsKey('user')) {
          return DriverModel.fromJson(responseData);
        }
      }

      return DriverModel.fromJson(responseData);
    } catch (e) {
      print('❌ Error updating driver status: $e');
      throw Exception('Failed to update driver status: ${e.toString()}');
    }
  }

  // ===== DRIVER SELF-MANAGEMENT OPERATIONS =====

  /// Update driver location (Driver only)
  static Future<Map<String, dynamic>> updateDriverLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Based on backend route: PATCH /drivers/{id}/location
      // For self-update, we need to get current user's driver ID
      final userData = await BaseService.getUserData();
      if (userData == null) {
        throw Exception('User not logged in');
      }

      // Assuming driver ID is available in user data or we use a different endpoint
      final response = await BaseService.patch(
        '/drivers/location', // Backend might have a self-update endpoint
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      return BaseService.extractData(response);
    } catch (e) {
      throw Exception('Failed to update location: ${e.toString()}');
    }
  }

  /// Update driver status (Driver only)
  static Future<Map<String, dynamic>> updateOwnStatus(String status) async {
    try {
      final response = await BaseService.patch(
        '/drivers/status', // Self-update endpoint
        data: {'status': status},
      );

      return BaseService.extractData(response);
    } catch (e) {
      throw Exception('Failed to update status: ${e.toString()}');
    }
  }

  /// Update driver profile (Driver only)
  static Future<DriverModel> updateOwnProfile({
    String? name,
    String? email,
    String? phone,
    String? licenseNumber,
    String? vehiclePlate,
    String? avatar,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (licenseNumber != null) data['license_number'] = licenseNumber;
      if (vehiclePlate != null) data['vehicle_plate'] = vehiclePlate;
      if (avatar != null && avatar.isNotEmpty) data['avatar'] = avatar;

      final response = await BaseService.put(
        '/drivers/me', // Self-update endpoint
        data: data,
      );

      final responseData = BaseService.extractData(response);
      return DriverModel.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  /// Get driver orders (Driver only)
  static Future<Map<String, dynamic>> getDriverOrders({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = BaseService.buildQueryParams(
        page: page,
        limit: limit,
      );

      final response = await BaseService.get(
        '/drivers/orders', // Self-orders endpoint
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to get driver orders: ${e.toString()}');
    }
  }

  /// Get driver location by ID (for tracking)
  static Future<Map<String, dynamic>> getDriverLocation(String driverId) async {
    try {
      final endpoint = BaseService.buildUrlWithParams(
        ApiConstants.driverLocation,
        {'id': driverId},
      );

      final response = await BaseService.get(endpoint);
      return BaseService.extractData(response);
    } catch (e) {
      throw Exception('Failed to get driver location: ${e.toString()}');
    }
  }

  // ===== DRIVER REQUEST OPERATIONS =====

  /// Get driver requests (Driver only)
  static Future<Map<String, dynamic>> getDriverRequests({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = BaseService.buildQueryParams(
        page: page,
        limit: limit,
      );

      final response = await BaseService.get(
        ApiConstants.driverRequests,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to get driver requests: ${e.toString()}');
    }
  }

  /// Get driver request detail (Driver only)
  static Future<Map<String, dynamic>> getDriverRequestDetail(
      String requestId) async {
    try {
      final endpoint = BaseService.buildUrlWithParams(
        ApiConstants.driverRequestById,
        {'id': requestId},
      );

      final response = await BaseService.get(endpoint);
      return BaseService.extractData(response);
    } catch (e) {
      throw Exception('Failed to get request detail: ${e.toString()}');
    }
  }

  /// Respond to driver request (Driver only)
  static Future<Map<String, dynamic>> respondToDriverRequest({
    required String requestId,
    required String action, // 'accept' or 'reject'
    DateTime? estimatedPickupTime,
    DateTime? estimatedDeliveryTime,
  }) async {
    try {
      final endpoint = BaseService.buildUrlWithParams(
        ApiConstants.respondDriverRequest,
        {'id': requestId},
      );

      final data = {
        'action': action,
        if (estimatedPickupTime != null)
          'estimatedPickupTime': estimatedPickupTime.toIso8601String(),
        if (estimatedDeliveryTime != null)
          'estimatedDeliveryTime': estimatedDeliveryTime.toIso8601String(),
      };

      final response = await BaseService.post(endpoint, data: data);
      return BaseService.extractData(response);
    } catch (e) {
      throw Exception('Failed to respond to request: ${e.toString()}');
    }
  }

  // ===== UTILITY METHODS =====

  /// Test connection to backend
  static Future<bool> testConnection() async {
    return await BaseService.testConnection();
  }

  /// Validate driver data before submission
  static Map<String, String?> validateDriverData({
    required String name,
    required String email,
    required String phone,
    required String licenseNumber,
    required String vehiclePlate,
    String? password,
  }) {
    Map<String, String?> errors = {};

    // Name validation
    if (name.trim().isEmpty) {
      errors['name'] = 'Name is required';
    } else if (name.trim().length < 2) {
      errors['name'] = 'Name must be at least 2 characters';
    }

    // Email validation
    if (email.trim().isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      errors['email'] = 'Invalid email format';
    }

    // Phone validation
    if (phone.trim().isEmpty) {
      errors['phone'] = 'Phone is required';
    } else if (!RegExp(r'^\+?[0-9]{10,15}$')
        .hasMatch(phone.replaceAll(' ', ''))) {
      errors['phone'] = 'Invalid phone format';
    }

    // License number validation
    if (licenseNumber.trim().isEmpty) {
      errors['licenseNumber'] = 'License number is required';
    }

    // Vehicle plate validation
    if (vehiclePlate.trim().isEmpty) {
      errors['vehiclePlate'] = 'Vehicle plate is required';
    }

    // Password validation (for create operations)
    if (password != null) {
      if (password.isEmpty) {
        errors['password'] = 'Password is required';
      } else if (password.length < 6) {
        errors['password'] = 'Password must be at least 6 characters';
      }
    }

    return errors;
  }

  /// Validate driver status
  static bool isValidDriverStatus(String status) {
    return ApiConstants.driverStatuses.contains(status);
  }

  /// Format driver data for display
  static Map<String, dynamic> formatDriverData(Map<String, dynamic> driver) {
    return {
      'id': driver['id']?.toString() ?? '',
      'name': driver['name'] ?? 'Unknown',
      'email': driver['email'] ?? '',
      'phone': driver['phone'] ?? '',
      'license_number': driver['license_number'] ?? '',
      'vehicle_plate': driver['vehicle_plate'] ?? '',
      'status': driver['status'] ?? 'inactive',
      'rating': driver['rating'] ?? 0.0,
      'reviews_count': driver['reviews_count'] ?? 0,
      'latitude': driver['latitude'],
      'longitude': driver['longitude'],
      'avatar': driver['avatar'],
      'created_at': driver['created_at'],
      'updated_at': driver['updated_at'],
      'user': driver['user'], // User data if included
    };
  }

  /// ✅ ENHANCED: Extract driver list from API response
  static List<DriverModel> extractDriverList(Map<String, dynamic> response) {
    try {
      print('🔍 Extracting driver list from response...');
      print('🔍 Response keys: ${response.keys.toList()}');

      final data = BaseService.extractData(response);
      print('🔍 Extracted data type: ${data.runtimeType}');

      // ✅ Backend response: { statusCode: 200, message: "...", data: [...] }
      // So data should be a List directly
      if (data is List) {
        print('✅ Data is List with ${data.length} items');
        final driverJsonList = List<Map<String, dynamic>>.from(data);
        return driverJsonList
            .map((json) => DriverModel.fromJson(json))
            .toList();
      }

      // ✅ Fallback: if data is Map containing array
      if (data is Map<String, dynamic>) {
        print('🔍 Data is Map, checking for array fields...');
        List<dynamic>? driverList;

        // Try different possible keys
        if (data.containsKey('drivers')) {
          driverList = data['drivers'] as List<dynamic>?;
          print('✅ Found drivers array in "drivers" key');
        } else if (data.containsKey('data')) {
          driverList = data['data'] as List<dynamic>?;
          print('✅ Found drivers array in "data" key');
        } else if (data.containsKey('items')) {
          driverList = data['items'] as List<dynamic>?;
          print('✅ Found drivers array in "items" key');
        }

        if (driverList != null) {
          print('✅ Converting ${driverList.length} items to DriverModel');
          final driverJsonList = List<Map<String, dynamic>>.from(driverList);
          return driverJsonList
              .map((json) => DriverModel.fromJson(json))
              .toList();
        }
      }

      // ✅ If no valid data found, return empty list
      print('⚠️ No valid driver list found, returning empty list');
      return [];
    } catch (e) {
      print('❌ Error extracting driver list: $e');
      throw Exception('Failed to parse driver list: ${e.toString()}');
    }
  }

  /// Get pagination info from response
  static Map<String, dynamic> extractPaginationInfo(
      Map<String, dynamic> response) {
    return BaseService.extractPaginationData(response);
  }

  /// Calculate distance between two points using Haversine formula
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Convert driver status to display text
  static String getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'busy':
        return 'Busy';
      default:
        return 'Unknown';
    }
  }

  /// Get available driver statuses
  static List<String> getAvailableStatuses() {
    return List.from(ApiConstants.driverStatuses);
  }

  /// Create driver from form data
  static Future<DriverModel> createDriverFromForm(
      Map<String, dynamic> formData) async {
    // Validate data first
    final errors = validateDriverData(
      name: formData['name'] ?? '',
      email: formData['email'] ?? '',
      phone: formData['phone'] ?? '',
      licenseNumber: formData['license_number'] ?? '',
      vehiclePlate: formData['vehicle_plate'] ?? '',
      password: formData['password'],
    );

    if (errors.isNotEmpty) {
      final errorMessages =
          errors.values.where((msg) => msg != null).join(', ');
      throw Exception('Validation failed: $errorMessages');
    }

    return await createDriver(
      name: formData['name'],
      email: formData['email'],
      password: formData['password'],
      phone: formData['phone'],
      licenseNumber: formData['license_number'],
      vehiclePlate: formData['vehicle_plate'],
      avatar: formData['avatar'],
    );
  }

  /// Update driver from form data
  static Future<DriverModel> updateDriverFromForm(
      String id, Map<String, dynamic> formData) async {
    return await updateDriver(
      id: id,
      name: formData['name'],
      email: formData['email'],
      phone: formData['phone'],
      licenseNumber: formData['license_number'],
      vehiclePlate: formData['vehicle_plate'],
      status: formData['status'],
      avatar: formData['avatar'],
    );
  }

  /// Check if driver is available
  static bool isDriverAvailable(DriverModel driver) {
    return driver.status == 'active' && driver.hasLocation;
  }

  /// Get driver statistics
  static Map<String, dynamic> getDriverStats(List<DriverModel> drivers) {
    final activeDrivers = drivers.where((d) => d.isActive).length;
    final busyDrivers = drivers.where((d) => d.isBusy).length;
    final inactiveDrivers = drivers.where((d) => d.isInactive).length;
    final averageRating = drivers.isEmpty
        ? 0.0
        : drivers.map((d) => d.rating).reduce((a, b) => a + b) / drivers.length;

    return {
      'total': drivers.length,
      'active': activeDrivers,
      'busy': busyDrivers,
      'inactive': inactiveDrivers,
      'averageRating': averageRating,
    };
  }

  // ===== EXAMPLE USAGE =====

  /// Example of how to use the DriverService
  static Future<void> exampleUsage() async {
    try {
      // Initialize BaseService first
      BaseService.initialize();

      // Get all drivers
      final response = await getAllDrivers(page: 1, limit: 10);
      print('Response: $response');

      // Extract drivers as List<DriverModel>
      final drivers = extractDriverList(response);
      print('Found ${drivers.length} drivers');

      // Get pagination info
      final pagination = extractPaginationInfo(response);
      print('Pagination: $pagination');

      // Create a new driver
      final newDriver = await createDriver(
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
        phone: '08123456789',
        licenseNumber: 'DL123456',
        vehiclePlate: 'B1234ABC',
      );
      print('Created driver: ${newDriver.displayName}');

      // Update driver status
      final updatedDriver = await updateDriverStatus(
        id: newDriver.id.toString(),
        status: 'active',
      );
      print('Updated driver status: ${updatedDriver.statusDisplay}');
    } catch (e) {
      print('Error in example usage: $e');
    }
  }
}
