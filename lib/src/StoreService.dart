import 'dart:convert';
import 'package:dio/dio.dart';
import 'BaseService.dart';
import 'api_constant.dart';

class StoreService extends BaseService {
  // ✅ Get all stores with pagination
  static Future<Map<String, dynamic>> getAllStores({
    int page = 1,
    int limit = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
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
        ApiConstants.stores,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to load stores: $e');
    }
  }

  // ✅ Get store by ID
  static Future<Map<String, dynamic>> getStoreById(String id) async {
    try {
      final endpoint =
          BaseService.buildUrlWithParams(ApiConstants.storeById, {'id': id});

      final response = await BaseService.get(endpoint);
      return BaseService.extractData(response);
    } catch (e) {
      throw Exception('Failed to get store: $e');
    }
  }

  // ✅ Create new store (Admin only)
  static Future<Map<String, dynamic>> createStore({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    String? description,
    String? imageBase64,
    required String openTime,
    required String closeTime,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final data = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'address': address,
        'description': description ?? '',
        'open_time': openTime,
        'close_time': closeTime,
        'latitude': latitude,
        'longitude': longitude,
      };

      // Add image if provided (base64)
      if (imageBase64 != null && imageBase64.isNotEmpty) {
        data['image'] = imageBase64;
      }

      final response = await BaseService.post(
        ApiConstants.stores,
        data: data,
      );

      return BaseService.extractData(response);
    } catch (e) {
      throw Exception('Failed to create store: $e');
    }
  }

  // ✅ Update store (Admin only)
  static Future<Map<String, dynamic>> updateStore(
    String id, {
    String? name,
    String? email,
    String? phone,
    String? address,
    String? description,
    String? imageBase64,
    String? openTime,
    String? closeTime,
    double? latitude,
    double? longitude,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{};

      // Only add non-null values
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;
      if (description != null) data['description'] = description;
      if (openTime != null) data['open_time'] = openTime;
      if (closeTime != null) data['close_time'] = closeTime;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (status != null) data['status'] = status;

      // Add image if provided (base64)
      if (imageBase64 != null && imageBase64.isNotEmpty) {
        data['image'] = imageBase64;
      }

      final endpoint =
          BaseService.buildUrlWithParams(ApiConstants.storeById, {'id': id});

      final response = await BaseService.put(
        endpoint,
        data: data,
      );

      return BaseService.extractData(response);
    } catch (e) {
      throw Exception('Failed to update store: $e');
    }
  }

  // ✅ Delete store (Admin only)
  static Future<Map<String, dynamic>> deleteStore(String id) async {
    try {
      final endpoint =
          BaseService.buildUrlWithParams(ApiConstants.storeById, {'id': id});

      final response = await BaseService.delete(endpoint);
      return response;
    } catch (e) {
      throw Exception('Failed to delete store: $e');
    }
  }

  // ✅ Get store menu items
  static Future<Map<String, dynamic>> getStoreMenuItems(
    String storeId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final endpoint = BaseService.buildUrlWithParams(
          ApiConstants.menuByStore, {'store_id': storeId});

      final queryParams =
          BaseService.buildQueryParams(page: page, limit: limit);

      final response = await BaseService.get(
        endpoint,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to get store menu items: $e');
    }
  }

  // ✅ Get store orders
  static Future<Map<String, dynamic>> getStoreOrders({
    int page = 1,
    int limit = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
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
        ApiConstants.storeOrders,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to get store orders: $e');
    }
  }

  // ✅ Update store status
  static Future<Map<String, dynamic>> updateStoreStatus(
    String id,
    String status,
  ) async {
    try {
      // Validate status
      if (!ApiConstants.storeStatuses.contains(status)) {
        throw Exception('Invalid store status: $status');
      }

      final endpoint = '${ApiConstants.stores}/$id/status';

      final response = await BaseService.patch(
        endpoint,
        data: {'status': status},
      );

      return BaseService.extractData(response);
    } catch (e) {
      throw Exception('Failed to update store status: $e');
    }
  }

  // ✅ Get stores with filters
  static Future<Map<String, dynamic>> getStoresWithFilters({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? sortBy = 'created_at',
    String? sortOrder = 'DESC',
  }) async {
    try {
      final queryParams = BaseService.buildQueryParams(
        page: page,
        limit: limit,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
        additionalParams: status != null ? {'status': status} : null,
      );

      final response = await BaseService.get(
        ApiConstants.stores,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to load stores with filters: $e');
    }
  }

  // ✅ Search stores by name
  static Future<Map<String, dynamic>> searchStores(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = BaseService.buildQueryParams(
        page: page,
        limit: limit,
        search: query,
      );

      final response = await BaseService.get(
        ApiConstants.stores,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to search stores: $e');
    }
  }

  // ✅ Get stores by status
  static Future<Map<String, dynamic>> getStoresByStatus(
    String status, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = BaseService.buildQueryParams(
        page: page,
        limit: limit,
        additionalParams: {'status': status},
      );

      final response = await BaseService.get(
        ApiConstants.stores,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to get stores by status: $e');
    }
  }

  // ✅ Get active stores only
  static Future<Map<String, dynamic>> getActiveStores({
    int page = 1,
    int limit = 10,
  }) async {
    return getStoresByStatus('active', page: page, limit: limit);
  }

  // ✅ Get inactive stores only
  static Future<Map<String, dynamic>> getInactiveStores({
    int page = 1,
    int limit = 10,
  }) async {
    return getStoresByStatus('inactive', page: page, limit: limit);
  }

  // ✅ Get closed stores only
  static Future<Map<String, dynamic>> getClosedStores({
    int page = 1,
    int limit = 10,
  }) async {
    return getStoresByStatus('closed', page: page, limit: limit);
  }

  // ✅ Validate store data before creating/updating
  static String? validateStoreData({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? openTime,
    String? closeTime,
    double? latitude,
    double? longitude,
  }) {
    // Name validation
    if (name != null && name.trim().length < 3) {
      return 'Store name must be at least 3 characters';
    }

    // Email validation
    if (email != null && !_isValidEmail(email)) {
      return 'Invalid email format';
    }

    // Phone validation
    if (phone != null && !_isValidPhone(phone)) {
      return 'Invalid phone number format';
    }

    // Address validation
    if (address != null && address.trim().length < 10) {
      return 'Address must be at least 10 characters';
    }

    // Time validation
    if (openTime != null && !_isValidTime(openTime)) {
      return 'Invalid open time format (use HH:mm)';
    }

    if (closeTime != null && !_isValidTime(closeTime)) {
      return 'Invalid close time format (use HH:mm)';
    }

    // Location validation
    if (latitude != null && (latitude < -90 || latitude > 90)) {
      return 'Latitude must be between -90 and 90';
    }

    if (longitude != null && (longitude < -180 || longitude > 180)) {
      return 'Longitude must be between -180 and 180';
    }

    return null; // No validation errors
  }

  // ✅ Helper methods for validation
  static bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  static bool _isValidPhone(String phone) {
    return RegExp(r'^[0-9+\-\s()]{10,15}$').hasMatch(phone);
  }

  static bool _isValidTime(String time) {
    return RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(time);
  }

  // ✅ Get store statistics
  static Future<Map<String, dynamic>> getStoreStatistics() async {
    try {
      // Get all stores to calculate statistics
      final response = await BaseService.get(
        ApiConstants.stores,
        queryParameters: {'limit': 1000}, // Get all stores
      );

      final data = BaseService.extractData(response);
      final stores = data is List ? data : data['stores'] ?? [];

      // Calculate statistics
      final total = stores.length;
      final active = stores.where((s) => s['status'] == 'active').length;
      final inactive = stores.where((s) => s['status'] == 'inactive').length;
      final closed = stores.where((s) => s['status'] == 'closed').length;

      return {
        'total': total,
        'active': active,
        'inactive': inactive,
        'closed': closed,
        'activePercentage': total > 0 ? (active / total * 100).round() : 0,
        'inactivePercentage': total > 0 ? (inactive / total * 100).round() : 0,
        'closedPercentage': total > 0 ? (closed / total * 100).round() : 0,
      };
    } catch (e) {
      throw Exception('Failed to get store statistics: $e');
    }
  }

  // ✅ Test connection to stores endpoint
  static Future<bool> testStoresEndpoint() async {
    try {
      await BaseService.get(ApiConstants.stores, queryParameters: {'limit': 1});
      return true;
    } catch (e) {
      return false;
    }
  }
}
