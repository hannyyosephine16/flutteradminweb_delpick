import 'dart:convert';
import 'package:dio/dio.dart';
import 'BaseService.dart';
import 'api_constant.dart';

class StoreService extends BaseService {
  // ✅ FIXED: Get all stores dengan handling response yang tepat
  static Future<Map<String, dynamic>> getAllStores({
    int page = 1,
    int limit = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      print('🔍 StoreService.getAllStores called with:');
      print('   Page: $page, Limit: $limit');
      print('   Search: $search');
      print('   SortBy: $sortBy, SortOrder: $sortOrder');

      final queryParams = BaseService.buildQueryParams(
        page: page,
        limit: limit,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      print('🔗 Query params: $queryParams');
      print('🔗 Full URL: ${ApiConstants.baseUrl}${ApiConstants.stores}');

      final response = await BaseService.get(
        ApiConstants.stores,
        queryParameters: queryParams,
      );

      print('📥 StoreService response type: ${response.runtimeType}');
      print('📥 StoreService response keys: ${response.keys.toList()}');

      // ✅ FIXED: Response sudah dalam format yang benar dari BaseService
      // Format: { "message": "Berhasil mendapatkan data store", "data": [...] }

      // Validate response format
      if (!response.containsKey('data')) {
        print('❌ Response missing data field');
        throw Exception('Invalid response format: missing data field');
      }

      final dataField = response['data'];
      if (dataField is! List) {
        print('❌ Data field is not a list: ${dataField.runtimeType}');
        throw Exception('Invalid response format: data is not an array');
      }

      print(
          '✅ StoreService returning valid response with ${dataField.length} stores');

      // Return response as-is karena sudah dalam format yang benar
      return response;
    } catch (e, stackTrace) {
      print('❌ StoreService.getAllStores error: $e');
      print('📍 Stack trace: $stackTrace');
      throw Exception('Failed to load stores: $e');
    }
  }

  // ✅ Get store by ID
  static Future<Map<String, dynamic>> getStoreById(String id) async {
    try {
      print('🔍 StoreService.getStoreById called with ID: $id');

      final endpoint =
          BaseService.buildUrlWithParams(ApiConstants.storeById, {'id': id});

      print('🔗 Store by ID URL: $endpoint');

      final response = await BaseService.get(endpoint);

      print('📥 StoreService.getStoreById response: ${response.keys.toList()}');

      // Extract data from response
      final data = BaseService.extractData(response);

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid store data format');
      }

      return data as Map<String, dynamic>;
    } catch (e) {
      print('❌ StoreService.getStoreById error: $e');
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
      print('🔍 StoreService.createStore called for: $name');

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

      print('📤 Creating store with data keys: ${data.keys.toList()}');

      final response = await BaseService.post(
        ApiConstants.stores,
        data: data,
      );

      print('✅ Store created successfully');
      return BaseService.extractData(response);
    } catch (e) {
      print('❌ StoreService.createStore error: $e');
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
      print('🔍 StoreService.updateStore called for ID: $id');

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

      print('📤 Updating store with data keys: ${data.keys.toList()}');

      final endpoint =
          BaseService.buildUrlWithParams(ApiConstants.storeById, {'id': id});

      final response = await BaseService.put(
        endpoint,
        data: data,
      );

      print('✅ Store updated successfully');
      return BaseService.extractData(response);
    } catch (e) {
      print('❌ StoreService.updateStore error: $e');
      throw Exception('Failed to update store: $e');
    }
  }

  // ✅ Delete store (Admin only)
  static Future<Map<String, dynamic>> deleteStore(String id) async {
    try {
      print('🔍 StoreService.deleteStore called for ID: $id');

      final endpoint =
          BaseService.buildUrlWithParams(ApiConstants.storeById, {'id': id});

      final response = await BaseService.delete(endpoint);

      print('✅ Store deleted successfully');
      return response;
    } catch (e) {
      print('❌ StoreService.deleteStore error: $e');
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
      print('🔍 StoreService.getStoreMenuItems called for store: $storeId');

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
      print('❌ StoreService.getStoreMenuItems error: $e');
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
      print('🔍 StoreService.getStoreOrders called');

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
      print('❌ StoreService.getStoreOrders error: $e');
      throw Exception('Failed to get store orders: $e');
    }
  }

  // ✅ Update store status
  static Future<Map<String, dynamic>> updateStoreStatus(
    String id,
    String status,
  ) async {
    try {
      print('🔍 StoreService.updateStoreStatus called: $id -> $status');

      // Validate status
      if (!ApiConstants.storeStatuses.contains(status)) {
        throw Exception('Invalid store status: $status');
      }

      final endpoint = '${ApiConstants.stores}/$id/status';

      final response = await BaseService.patch(
        endpoint,
        data: {'status': status},
      );

      print('✅ Store status updated successfully');
      return BaseService.extractData(response);
    } catch (e) {
      print('❌ StoreService.updateStoreStatus error: $e');
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
      print('🔍 StoreService.getStoresWithFilters called');

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
      print('❌ StoreService.getStoresWithFilters error: $e');
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
      print('🔍 StoreService.searchStores called with query: $query');

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
      print('❌ StoreService.searchStores error: $e');
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
      print('🔍 StoreService.getStoresByStatus called with status: $status');

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
      print('❌ StoreService.getStoresByStatus error: $e');
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
      print('🔍 StoreService.getStoreStatistics called');

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

      final stats = {
        'total': total,
        'active': active,
        'inactive': inactive,
        'closed': closed,
        'activePercentage': total > 0 ? (active / total * 100).round() : 0,
        'inactivePercentage': total > 0 ? (inactive / total * 100).round() : 0,
        'closedPercentage': total > 0 ? (closed / total * 100).round() : 0,
      };

      print('📊 Store statistics: $stats');
      return stats;
    } catch (e) {
      print('❌ StoreService.getStoreStatistics error: $e');
      throw Exception('Failed to get store statistics: $e');
    }
  }

  // ✅ Test connection to stores endpoint
  static Future<bool> testStoresEndpoint() async {
    try {
      print('🧪 Testing stores endpoint...');

      await BaseService.get(ApiConstants.stores, queryParameters: {'limit': 1});

      print('✅ Stores endpoint test successful');
      return true;
    } catch (e) {
      print('❌ Stores endpoint test failed: $e');
      return false;
    }
  }

  // ✅ DEBUGGING: Log response format
  static Future<void> debugStoresEndpoint() async {
    try {
      print('🔧 ========== DEBUGGING STORES ENDPOINT ==========');
      print('🔗 URL: ${ApiConstants.baseUrl}${ApiConstants.stores}');

      final response = await BaseService.get(
        ApiConstants.stores,
        queryParameters: {'limit': 1},
      );

      print('📥 Response type: ${response.runtimeType}');
      print('📥 Response keys: ${response.keys.toList()}');

      if (response.containsKey('data')) {
        final data = response['data'];
        print('📋 Data type: ${data.runtimeType}');
        if (data is List) {
          print('📋 Data length: ${data.length}');
          if (data.isNotEmpty) {
            print('📋 First item keys: ${data[0].keys.toList()}');
          }
        }
      }

      print('🔧 ========== END DEBUGGING ==========');
    } catch (e) {
      print('❌ Debug stores endpoint error: $e');
    }
  }
}
