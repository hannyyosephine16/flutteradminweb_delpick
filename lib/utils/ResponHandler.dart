// lib/utils/ResponseHandler.dart
// Utility untuk handle response format yang berbeda-beda dari backend

class ResponseHandler {
  /// Extract list data from different response formats
  /// Supports: direct array, {data: array}, {items: array}, {customers: array}, etc.
  static List<dynamic> extractListData(dynamic response, [String? itemKey]) {
    if (response is List) {
      // Direct array response
      return response;
    }

    if (response is Map<String, dynamic>) {
      // Try specific item key first (e.g., 'customers', 'drivers', 'stores')
      if (itemKey != null && response.containsKey(itemKey)) {
        final items = response[itemKey];
        if (items is List) {
          return items;
        }
      }

      // Try common keys
      final commonKeys = ['data', 'items', 'results', 'list'];
      for (final key in commonKeys) {
        if (response.containsKey(key)) {
          final items = response[key];
          if (items is List) {
            return items;
          } else if (items is Map<String, dynamic>) {
            // Nested structure like {data: {customers: [...]}}
            if (itemKey != null && items.containsKey(itemKey)) {
              final nestedItems = items[itemKey];
              if (nestedItems is List) {
                return nestedItems;
              }
            }
          }
        }
      }
    }

    // Fallback: empty list
    return [];
  }

  /// Extract pagination info from response
  static PaginationInfo extractPaginationInfo(
      dynamic response, int defaultPage, int defaultTotal) {
    if (response is Map<String, dynamic>) {
      return PaginationInfo(
        currentPage: response['currentPage'] ?? defaultPage,
        totalPages: response['totalPages'] ?? 1,
        totalItems: response['totalItems'] ?? defaultTotal,
      );
    }

    // Fallback for direct array response
    return PaginationInfo(
      currentPage: defaultPage,
      totalPages: 1,
      totalItems: defaultTotal,
    );
  }

  /// Extract single item data from response
  static Map<String, dynamic>? extractItemData(dynamic response) {
    if (response is Map<String, dynamic>) {
      // Try to get from 'data' key first
      if (response.containsKey('data') &&
          response['data'] is Map<String, dynamic>) {
        return response['data'];
      }
      // Return the response itself if it's already a map
      return response;
    }

    return null;
  }

  /// Safe coordinate parsing
  static double? parseCoordinate(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value);
  }

  /// Validate coordinate range
  static String? validateCoordinate(String? value, String coordinateName) {
    if (value == null || value.isEmpty) {
      return '$coordinateName is required';
    }

    final coordinate = double.tryParse(value);
    if (coordinate == null) {
      return 'Please enter a valid $coordinateName (decimal number)';
    }

    // Validate realistic coordinate ranges
    if (coordinateName.toLowerCase().contains('latitude')) {
      if (coordinate < -90 || coordinate > 90) {
        return 'Latitude must be between -90 and 90';
      }
    } else if (coordinateName.toLowerCase().contains('longitude')) {
      if (coordinate < -180 || coordinate > 180) {
        return 'Longitude must be between -180 and 180';
      }
    }

    return null;
  }

  /// Format error message from API response
  static String formatErrorMessage(dynamic error) {
    if (error is Map<String, dynamic>) {
      return error['message'] ?? error['error'] ?? 'An unknown error occurred';
    }
    return error.toString();
  }
}

/// Pagination information class
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });
}

/// Usage example in controllers:
/*
// In DriverController.dart
final response = await DriverService.getAllDrivers(page: page, limit: itemsPerPage.value);

// ✅ Using ResponseHandler
final driversData = ResponseHandler.extractListData(response, 'drivers');
final driversList = driversData.map((json) => DriverModel.fromJson(json)).toList();

final paginationInfo = ResponseHandler.extractPaginationInfo(response, page, driversList.length);
currentPage.value = paginationInfo.currentPage;
totalPages.value = paginationInfo.totalPages;
totalItems.value = paginationInfo.totalItems;
*/
