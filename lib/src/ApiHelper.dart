// lib/src/api_helper.dart
import 'api_constant.dart';

class ApiHelper {
  // Customer endpoints
  static String getCustomersUrl({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) {
    final params = ApiConstants.buildQueryParams(
      page: page,
      limit: limit,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    final query = params.isNotEmpty
        ? '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';

    return '${ApiConstants.buildUrl(ApiConstants.customers)}$query';
  }

  static String getCustomerByIdUrl(String id) {
    return ApiConstants.buildUrlWithParams(
        ApiConstants.customerById, {'id': id});
  }

  // Driver endpoints
  static String getDriversUrl({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) {
    final params = ApiConstants.buildQueryParams(
      page: page,
      limit: limit,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    final query = params.isNotEmpty
        ? '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';

    return '${ApiConstants.buildUrl(ApiConstants.drivers)}$query';
  }

  static String getDriverByIdUrl(String id) {
    return ApiConstants.buildUrlWithParams(ApiConstants.driverById, {'id': id});
  }

  static String getDriverStatusUrl(String id) {
    return ApiConstants.buildUrlWithParams(
        ApiConstants.driverStatus, {'id': id});
  }

  // Store endpoints
  static String getStoresUrl({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) {
    final params = ApiConstants.buildQueryParams(
      page: page,
      limit: limit,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    final query = params.isNotEmpty
        ? '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';

    return '${ApiConstants.buildUrl(ApiConstants.stores)}$query';
  }

  static String getStoreByIdUrl(String id) {
    return ApiConstants.buildUrlWithParams(ApiConstants.storeById, {'id': id});
  }

  // Menu endpoints
  static String getMenuByStoreUrl(String storeId) {
    return ApiConstants.buildUrlWithParams(
        ApiConstants.menuByStore, {'store_id': storeId});
  }

  static String getMenuItemByIdUrl(String id) {
    return ApiConstants.buildUrlWithParams(
        ApiConstants.menuItemById, {'id': id});
  }

  // Order endpoints
  static String getOrderByIdUrl(String id) {
    return ApiConstants.buildUrlWithParams(ApiConstants.orderById, {'id': id});
  }

  static String getOrderStatusUrl(String id) {
    return ApiConstants.buildUrlWithParams(
        ApiConstants.orderStatus, {'id': id});
  }

  // Validate response format
  static bool isValidResponse(Map<String, dynamic> response) {
    return response.containsKey(ApiConstants.statusCodeKey) &&
        response.containsKey(ApiConstants.messageKey);
  }

  // Extract data from response
  static dynamic extractData(Map<String, dynamic> response) {
    if (isValidResponse(response)) {
      return response[ApiConstants.dataKey];
    }
    return null;
  }

  // Extract error message
  static String extractErrorMessage(Map<String, dynamic> response) {
    if (response.containsKey(ApiConstants.messageKey)) {
      return response[ApiConstants.messageKey];
    }
    return 'Unknown error occurred';
  }
}
