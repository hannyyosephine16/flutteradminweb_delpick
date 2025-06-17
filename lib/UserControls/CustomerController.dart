// FIXED: CustomerController.dart - Updated to match backend response format
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../src/CustomerService.dart';
import '../Models/CustomerModel.dart';

class CustomerController extends GetxController {
  // Observable variables
  final customers = <CustomerModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 0.obs;
  final totalItems = 0.obs;
  final itemsPerPage = 10.obs;

  // Search and filter
  final searchQuery = ''.obs;
  final selectedFilter = 'all'.obs;

  // Selection
  final selectedCustomers = <CustomerModel>[].obs;
  final isAllSelected = false.obs;

  // Form data for add/edit
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Form state
  final isFormLoading = false.obs;
  final isEditMode = false.obs;
  final editingCustomerId = ''.obs;
  final selectedImageBase64 = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // FIXED: Fetch customers with correct response parsing
  Future<void> fetchCustomers({int page = 1, bool isRefresh = false}) async {
    try {
      if (isRefresh || page == 1) {
        isLoading.value = true;
        customers.clear();
      } else {
        isLoadingMore.value = true;
      }

      hasError.value = false;
      errorMessage.value = '';

      print(
          '🔄 Fetching customers - Page: $page, Limit: ${itemsPerPage.value}');

      final response = await CustomerService.getAllCustomers(
        page: page,
        limit: itemsPerPage.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (response != null) {
        List<dynamic> customersData = [];

        // ✅ FIXED: Handle backend response format with snake_case keys
        if (response.containsKey('data') && response['data'] != null) {
          final data = response['data'] as Map<String, dynamic>?;
          if (data != null && data.containsKey('customers')) {
            customersData = data['customers'] as List<dynamic>? ?? [];

            // ✅ FIXED: Use snake_case keys to match backend
            currentPage.value =
                data['current_page'] as int? ?? page; // Was: currentPage
            totalPages.value =
                data['total_pages'] as int? ?? 1; // Was: totalPages
            totalItems.value = data['total_items'] as int? ??
                customersData.length; // Was: totalItems
          }
        } else if (response['customers'] != null) {
          // Alternative format: direct customers array in response
          customersData = response['customers'] as List<dynamic>? ?? [];
          currentPage.value = response['current_page'] as int? ?? page;
          totalPages.value = response['total_pages'] as int? ?? 1;
          totalItems.value =
              response['total_items'] as int? ?? customersData.length;
        }

        // Convert to CustomerModel list
        final customersList = customersData
            .map((json) => CustomerModel.fromJson(json as Map<String, dynamic>))
            .toList();

        if (page == 1) {
          customers.assignAll(customersList);
        } else {
          customers.addAll(customersList);
        }

        print('✅ Loaded ${customersList.length} customers');
        print(
            '📊 Pagination - Page: ${currentPage.value}, Total Pages: ${totalPages.value}, Total Items: ${totalItems.value}');
      } else {
        throw Exception('No response from server');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      _showErrorSnackbar('Failed to load customers: ${e.toString()}');
      print('❌ Error fetching customers: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load more customers (pagination)
  Future<void> loadMoreCustomers() async {
    if (currentPage.value < totalPages.value && !isLoadingMore.value) {
      await fetchCustomers(page: currentPage.value + 1);
    }
  }

  // Refresh customers list
  Future<void> refreshCustomers() async {
    await fetchCustomers(page: 1, isRefresh: true);
  }

  // Search customers
  void searchCustomers(String query) {
    searchQuery.value = query;
    fetchCustomers(page: 1, isRefresh: true);
  }

  // Filter customers
  void filterCustomers(String filter) {
    selectedFilter.value = filter;
    fetchCustomers(page: 1, isRefresh: true);
  }

  // FIXED: Get customer by ID with proper response handling
  Future<CustomerModel?> getCustomerById(String id) async {
    try {
      final response = await CustomerService.getCustomerById(id);
      if (response != null) {
        // Handle different response formats
        Map<String, dynamic>? customerData;

        // Backend format: { statusCode: 200, message: "...", data: {...} }
        if (response.containsKey('data') && response['data'] != null) {
          customerData = response['data'] as Map<String, dynamic>?;
        } else if (response.containsKey('name') ||
            response.containsKey('email')) {
          // Direct customer data
          customerData = response;
        }

        if (customerData != null) {
          return CustomerModel.fromJson(customerData);
        }
      }
      return null;
    } catch (e) {
      _showErrorSnackbar('Failed to get customer: ${e.toString()}');
      return null;
    }
  }

  // Create new customer
  Future<bool> createCustomer() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    try {
      isFormLoading.value = true;

      final response = await CustomerService.createCustomer(
        nameController.text,
        emailController.text,
        phoneController.text,
        passwordController.text,
        selectedImageBase64.value.isNotEmpty ? selectedImageBase64.value : null,
      );

      if (response != null) {
        _showSuccessSnackbar('Customer created successfully');
        clearForm();
        refreshCustomers();
        return true;
      } else {
        throw Exception('No response from server');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to create customer: ${e.toString()}');
      return false;
    } finally {
      isFormLoading.value = false;
    }
  }

  // Update customer
  Future<bool> updateCustomer() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    try {
      isFormLoading.value = true;

      final response = await CustomerService.updateCustomer(
        editingCustomerId.value,
        nameController.text,
        emailController.text,
        phoneController.text,
        '', // current password (not implemented in form)
        passwordController.text,
        selectedImageBase64.value.isNotEmpty ? selectedImageBase64.value : null,
      );

      if (response != null) {
        _showSuccessSnackbar('Customer updated successfully');
        clearForm();
        refreshCustomers();
        return true;
      } else {
        throw Exception('No response from server');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to update customer: ${e.toString()}');
      return false;
    } finally {
      isFormLoading.value = false;
    }
  }

  // Delete customer
  Future<bool> deleteCustomer(String id) async {
    try {
      final success = await CustomerService.deleteCustomer(id);
      if (success) {
        _showSuccessSnackbar('Customer deleted successfully');
        refreshCustomers();
        return true;
      } else {
        throw Exception('Delete operation failed');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to delete customer: ${e.toString()}');
      return false;
    }
  }

  // Delete multiple customers
  Future<bool> deleteMultipleCustomers() async {
    if (selectedCustomers.isEmpty) {
      _showErrorSnackbar('No customers selected');
      return false;
    }

    try {
      // Delete each selected customer
      for (final customer in selectedCustomers) {
        await CustomerService.deleteCustomer(customer.id.toString());
      }

      _showSuccessSnackbar(
          '${selectedCustomers.length} customers deleted successfully');
      clearSelection();
      refreshCustomers();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to delete customers: ${e.toString()}');
      return false;
    }
  }

  // Form management
  void setEditMode(CustomerModel customer) {
    isEditMode.value = true;
    editingCustomerId.value = customer.id.toString();
    nameController.text = customer.name;
    emailController.text = customer.email;
    phoneController.text = customer.phone;
    passwordController.clear();
    confirmPasswordController.clear();
    selectedImageBase64.value = customer.avatar ?? '';
  }

  void clearForm() {
    isEditMode.value = false;
    editingCustomerId.value = '';
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    selectedImageBase64.value = '';
  }

  void setSelectedImage(String base64Image) {
    selectedImageBase64.value = base64Image;
  }

  // Selection management
  void toggleCustomerSelection(CustomerModel customer) {
    if (selectedCustomers.contains(customer)) {
      selectedCustomers.remove(customer);
    } else {
      selectedCustomers.add(customer);
    }
    _updateSelectAllState();
  }

  void toggleSelectAll() {
    if (isAllSelected.value) {
      selectedCustomers.clear();
    } else {
      selectedCustomers.assignAll(customers);
    }
    _updateSelectAllState();
  }

  void clearSelection() {
    selectedCustomers.clear();
    isAllSelected.value = false;
  }

  void _updateSelectAllState() {
    isAllSelected.value =
        customers.isNotEmpty && selectedCustomers.length == customers.length;
  }

  // Utility methods
  bool isCustomerSelected(CustomerModel customer) {
    return selectedCustomers.contains(customer);
  }

  int get selectedCount => selectedCustomers.length;

  List<CustomerModel> get filteredCustomers {
    if (searchQuery.value.isEmpty) {
      return customers;
    }

    return customers.where((customer) {
      final query = searchQuery.value.toLowerCase();
      return customer.name.toLowerCase().contains(query) ||
          customer.email.toLowerCase().contains(query) ||
          customer.phone.contains(query);
    }).toList();
  }

  // Statistics
  int get totalCustomersCount => totalItems.value;

  int get newCustomersCount =>
      customers.where((c) => (c.customerStatus ?? '') == 'New Customer').length;

  // Snackbar helpers
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Validation
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone is required';
    }
    if (value.length < 10) {
      return 'Phone must be at least 10 digits';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
