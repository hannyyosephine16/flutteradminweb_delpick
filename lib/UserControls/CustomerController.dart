// FIXED: CustomerController.dart dengan debugging untuk response parsing
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../src/CustomerService.dart';
import '../Models/CustomerModel.dart';

class CustomerController extends GetxController {
  // Observable variables
  var customers = <CustomerModel>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Pagination
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalItems = 0.obs;
  var itemsPerPage = 10.obs;
  var hasNextPage = false.obs;

  // Search and filter
  var searchQuery = ''.obs;
  var sortBy = 'created_at'.obs;
  var sortOrder = 'DESC'.obs;

  // Selected customer for detail view
  var selectedCustomer = Rxn<CustomerModel>();

  @override
  void onInit() {
    super.onInit();
    // Load customers when controller initializes
    loadCustomers();
  }

  /// Load customers with pagination and search
  Future<void> loadCustomers({
    bool refresh = false,
    int? page,
    String? search,
  }) async {
    try {
      if (refresh || page == 1) {
        isLoading.value = true;
        hasError.value = false;
        errorMessage.value = '';
        if (refresh) {
          customers.clear();
          currentPage.value = 1;
        }
      } else {
        isLoadingMore.value = true;
      }

      final pageToLoad = page ?? currentPage.value;
      final searchTerm = search ?? searchQuery.value;

      print('🔄 Loading customers - Page: $pageToLoad, Search: "$searchTerm"');

      final response = await CustomerService.getAllCustomers(
        page: pageToLoad,
        limit: itemsPerPage.value,
        search: searchTerm.isEmpty ? null : searchTerm,
        sortBy: sortBy.value,
        sortOrder: sortOrder.value,
      );

      print('📥 === RAW RESPONSE DEBUG ===');
      print('📥 Response type: ${response.runtimeType}');
      print('📥 Response keys: ${response?.keys?.toList()}');
      print('📥 Full response: $response');

      if (response != null) {
        await _handleCustomersResponse(response, refresh || page == 1);
      } else {
        throw Exception('No response received from server');
      }
    } catch (e) {
      print('❌ Error loading customers: $e');
      hasError.value = true;
      errorMessage.value = _getErrorMessage(e);

      // Show error snackbar
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Handle the customers response from API with detailed debugging
  Future<void> _handleCustomersResponse(
      Map<String, dynamic> response, bool replaceList) async {
    try {
      print('🔧 === RESPONSE PARSING DEBUG ===');
      print('🔧 Response structure: ${response.keys.toList()}');

      // Extract data based on response format
      dynamic data;
      if (response.containsKey('data')) {
        data = response['data'];
        print('🔧 Found data key, extracting...');
      } else {
        data = response;
        print('🔧 No data key, using response directly');
      }

      print('🔧 Data type: ${data.runtimeType}');
      print('🔧 Data content: $data');

      List<CustomerModel> newCustomers = [];

      // Handle different data formats
      if (data is Map<String, dynamic>) {
        print('🔧 Data is Map, checking for customers array...');
        print('🔧 Data keys: ${data.keys.toList()}');

        // Check if data contains customers array
        if (data.containsKey('customers')) {
          print('🔧 Found customers array');
          final customersList = data['customers'] as List;
          print('🔧 Customers array length: ${customersList.length}');
          print(
              '🔧 First customer: ${customersList.isNotEmpty ? customersList[0] : 'Empty'}');

          // Parse each customer
          for (int i = 0; i < customersList.length; i++) {
            try {
              final customerJson = customersList[i] as Map<String, dynamic>;
              print(
                  '🔧 Parsing customer $i: ${customerJson['name']} (ID: ${customerJson['id']})');

              final customer = CustomerModel.fromJson(customerJson);
              newCustomers.add(customer);
              print('✅ Successfully parsed customer: ${customer.name}');
            } catch (e) {
              print('❌ Error parsing customer $i: $e');
            }
          }
        }
        // Check if data contains data array
        else if (data.containsKey('data')) {
          print('🔧 Found nested data array');
          final customersList = data['data'] as List;
          newCustomers = customersList
              .map((item) =>
                  CustomerModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        // Extract pagination info
        _updatePaginationInfo(data);
      } else if (data is List) {
        print('🔧 Data is direct array of customers');
        // Direct array of customers
        newCustomers = data
            .map((item) => CustomerModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      print('🔧 === PARSING RESULT ===');
      print('🔧 Parsed customers count: ${newCustomers.length}');
      for (int i = 0; i < newCustomers.length; i++) {
        final customer = newCustomers[i];
        print(
            '🔧 Customer $i: ${customer.name} (${customer.email}) - ID: ${customer.id}');
      }

      // Update customers list
      if (replaceList) {
        print('🔧 Replacing customers list with ${newCustomers.length} items');
        customers.assignAll(newCustomers);
      } else {
        print('🔧 Adding ${newCustomers.length} items to existing list');
        customers.addAll(newCustomers);
      }

      // Update pagination from response
      _updatePaginationInfo(response);

      print('🔧 === FINAL STATE ===');
      print('🔧 Total customers in controller: ${customers.length}');
      print('🔧 Customers observable updated');

      // Force UI update
      customers.refresh();

      print(
          '✅ Loaded ${newCustomers.length} customers (Total: ${customers.length})');
    } catch (e) {
      print('❌ Error handling customers response: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      throw Exception('Failed to process customers data: $e');
    }
  }

  /// Update pagination information
  void _updatePaginationInfo(Map<String, dynamic> response) {
    print('🔧 === PAGINATION DEBUG ===');
    print('🔧 Response keys for pagination: ${response.keys.toList()}');

    // Handle different pagination key formats
    totalItems.value = response['total_items'] ??
        response['totalItems'] ??
        response['total'] ??
        0;

    totalPages.value = response['total_pages'] ??
        response['totalPages'] ??
        response['pages'] ??
        1;

    currentPage.value = response['current_page'] ??
        response['currentPage'] ??
        response['page'] ??
        1;

    hasNextPage.value = currentPage.value < totalPages.value;

    print('🔧 Pagination updated:');
    print('🔧 - Total items: ${totalItems.value}');
    print('🔧 - Total pages: ${totalPages.value}');
    print('🔧 - Current page: ${currentPage.value}');
    print('🔧 - Has next page: ${hasNextPage.value}');
  }

  /// Debug method to manually check customer data
  Future<void> debugCustomerData() async {
    try {
      print('🐛 === MANUAL DEBUG START ===');
      isLoading.value = true;

      // Call API directly and log everything
      final response = await CustomerService.getAllCustomers(
        page: 1,
        limit: 10,
      );

      print('🐛 Direct API Response:');
      print('🐛 Type: ${response.runtimeType}');
      print('🐛 Keys: ${response?.keys?.toList()}');
      print('🐛 Content: $response');

      if (response != null && response['data'] != null) {
        final data = response['data'];
        print('🐛 Data section:');
        print('🐛 Data type: ${data.runtimeType}');
        print('🐛 Data keys: ${data.keys?.toList()}');

        if (data['customers'] != null) {
          final customersList = data['customers'] as List;
          print('🐛 Customers array found with ${customersList.length} items');

          for (int i = 0; i < customersList.length; i++) {
            final customer = customersList[i];
            print(
                '🐛 Customer $i: ${customer['name']} - ${customer['email']} (ID: ${customer['id']})');
          }

          // Try to parse them
          print('🐛 Attempting to parse customers...');
          final List<CustomerModel> testCustomers = [];
          for (final customerJson in customersList) {
            try {
              final customer = CustomerModel.fromJson(customerJson);
              testCustomers.add(customer);
              print('🐛 ✅ Parsed: ${customer.name}');
            } catch (e) {
              print('🐛 ❌ Parse error: $e');
            }
          }

          print('🐛 Successfully parsed ${testCustomers.length} customers');

          // Manually update the observable
          customers.assignAll(testCustomers);
          customers.refresh();

          print('🐛 Controller now has ${customers.length} customers');
        }
      }

      Get.snackbar(
        'Debug Complete',
        'Check console for debug info. Found ${customers.length} customers.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade900,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('🐛 Debug error: $e');
      Get.snackbar(
        'Debug Error',
        'Debug failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ... rest of the methods remain the same ...

  /// Create new customer
  Future<bool> createCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? imageBase64,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      print('🔄 Creating customer: $name ($email)');

      final response = await CustomerService.createCustomer(
        name,
        email,
        phone,
        password,
        imageBase64,
      );

      if (response != null) {
        print('✅ Customer created successfully');

        Get.snackbar(
          'Success',
          'Customer "$name" has been created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: Duration(seconds: 3),
        );

        await loadCustomers(refresh: true);
        return true;
      } else {
        throw Exception('Failed to create customer');
      }
    } catch (e) {
      print('❌ Error creating customer: $e');
      hasError.value = true;
      errorMessage.value = _getErrorMessage(e);

      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: Duration(seconds: 4),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update existing customer
  Future<bool> updateCustomer({
    required String id,
    required String name,
    required String email,
    required String phone,
    String? imageBase64,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      print('🔄 Updating customer: $id');

      final response = await CustomerService.updateCustomer(
        id,
        name,
        email,
        phone,
        null,
        null,
        imageBase64,
      );

      if (response != null) {
        print('✅ Customer updated successfully');

        final updatedCustomer = CustomerModel.fromApiResponse(response);
        if (updatedCustomer != null) {
          final index = customers.indexWhere((c) => c.id.toString() == id);
          if (index != -1) {
            customers[index] = updatedCustomer;
            customers.refresh();
          }

          if (selectedCustomer.value?.id.toString() == id) {
            selectedCustomer.value = updatedCustomer;
          }
        }

        Get.snackbar(
          'Success',
          'Customer "$name" has been updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: Duration(seconds: 3),
        );

        return true;
      } else {
        throw Exception('Failed to update customer');
      }
    } catch (e) {
      print('❌ Error updating customer: $e');
      hasError.value = true;
      errorMessage.value = _getErrorMessage(e);

      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: Duration(seconds: 4),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete customer
  Future<bool> deleteCustomer(String id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      print('🔄 Deleting customer: $id');

      final success = await CustomerService.deleteCustomer(id);

      if (success) {
        print('✅ Customer deleted successfully');

        customers.removeWhere((customer) => customer.id.toString() == id);

        if (selectedCustomer.value?.id.toString() == id) {
          selectedCustomer.value = null;
        }

        Get.snackbar(
          'Success',
          'Customer has been deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: Duration(seconds: 3),
        );

        return true;
      } else {
        throw Exception('Failed to delete customer');
      }
    } catch (e) {
      print('❌ Error deleting customer: $e');
      hasError.value = true;
      errorMessage.value = _getErrorMessage(e);

      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: Duration(seconds: 4),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get customer by ID
  Future<CustomerModel?> getCustomerById(String id) async {
    try {
      print('🔄 Getting customer by ID: $id');

      final response = await CustomerService.getCustomerById(id);

      if (response != null) {
        final customer = CustomerModel.fromApiResponse(response);
        if (customer != null) {
          selectedCustomer.value = customer;
          print('✅ Customer retrieved successfully: ${customer.name}');
          return customer;
        }
      }

      throw Exception('Customer not found');
    } catch (e) {
      print('❌ Error getting customer: $e');
      hasError.value = true;
      errorMessage.value = _getErrorMessage(e);

      Get.snackbar(
        'Error',
        'Failed to load customer details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: Duration(seconds: 3),
      );
      return null;
    }
  }

  /// Search customers
  Future<void> searchCustomers(String query) async {
    searchQuery.value = query;
    currentPage.value = 1;
    await loadCustomers(refresh: true, search: query);
  }

  /// Clear search
  Future<void> clearSearch() async {
    searchQuery.value = '';
    currentPage.value = 1;
    await loadCustomers(refresh: true);
  }

  /// Load more customers (pagination)
  Future<void> loadMoreCustomers() async {
    if (!hasNextPage.value || isLoadingMore.value) return;

    currentPage.value++;
    await loadCustomers(page: currentPage.value);
  }

  /// Refresh customers list
  Future<void> refreshCustomers() async {
    await loadCustomers(refresh: true);
  }

  /// Change sorting
  Future<void> changeSorting(String newSortBy, String newSortOrder) async {
    sortBy.value = newSortBy;
    sortOrder.value = newSortOrder;
    currentPage.value = 1;
    await loadCustomers(refresh: true);
  }

  /// Test backend connection
  Future<void> testConnection() async {
    try {
      isLoading.value = true;

      final isConnected = await CustomerService.testConnection();

      if (isConnected) {
        Get.snackbar(
          'Success',
          'Successfully connected to backend',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: Duration(seconds: 2),
        );
      } else {
        throw Exception('Backend connection failed');
      }
    } catch (e) {
      Get.snackbar(
        'Connection Error',
        'Failed to connect to backend: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    String errorString = error.toString();

    if (errorString.startsWith('Exception: ')) {
      errorString = errorString.substring(11);
    }

    if (errorString.contains('401') || errorString.contains('Unauthorized')) {
      return 'Authentication required. Please login again.';
    } else if (errorString.contains('403') ||
        errorString.contains('Forbidden')) {
      return 'Access denied. Admin privileges required.';
    } else if (errorString.contains('404') ||
        errorString.contains('Not Found')) {
      return 'Customer not found.';
    } else if (errorString.contains('409') ||
        errorString.contains('Conflict')) {
      return 'Email already exists. Please use a different email.';
    } else if (errorString.contains('422') ||
        errorString.contains('validation')) {
      return 'Invalid data provided. Please check all fields.';
    } else if (errorString.contains('500') ||
        errorString.contains('Internal Server Error')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('Network') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('timeout')) {
      return 'Request timeout. Please try again.';
    }

    return errorString.isNotEmpty
        ? errorString
        : 'An unexpected error occurred';
  }

  // Computed properties for UI
  bool get hasCustomers => customers.isNotEmpty;
  bool get isEmpty => customers.isEmpty && !isLoading.value;
  bool get canLoadMore => hasNextPage.value && !isLoadingMore.value;
  String get statusMessage {
    if (isLoading.value) return 'Loading customers...';
    if (hasError.value) return errorMessage.value;
    if (isEmpty) return 'No customers found';
    return '${customers.length} customers loaded';
  }

  /// Get customers statistics
  Map<String, dynamic> get customersStats {
    if (customers.isEmpty) {
      return {
        'total': 0,
        'active': 0,
        'new': 0,
        'loyal': 0,
      };
    }

    final total = customers.length;
    final active = customers.where((c) => c.isActiveCustomer).length;
    final newCustomers = customers.where((c) => c.isNewCustomer).length;
    final loyal =
        customers.where((c) => c.customerStatus == 'Loyal Customer').length;

    return {
      'total': total,
      'active': active,
      'new': newCustomers,
      'loyal': loyal,
    };
  }

  /// Filter customers by status
  List<CustomerModel> getCustomersByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return customers.where((c) => c.isActiveCustomer).toList();
      case 'new':
        return customers.where((c) => c.isNewCustomer).toList();
      case 'loyal':
        return customers
            .where((c) => c.customerStatus == 'Loyal Customer')
            .toList();
      default:
        return customers.toList();
    }
  }

  /// Validate customer data
  Map<String, String?> validateCustomerData({
    required String name,
    required String email,
    required String phone,
    String? password,
  }) {
    return CustomerService.validateCustomerData(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
  }

  /// Clean phone number
  String cleanPhoneNumber(String phone) {
    return CustomerService.cleanPhoneNumber(phone);
  }

  /// Check if image format is valid
  bool isValidImageFormat(String? imageBase64) {
    return CustomerService.isValidImageFormat(imageBase64);
  }
}
