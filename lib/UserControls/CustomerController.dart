import 'dart:convert';
import 'package:flutter/material.dart';
import '../Models/CustomerModel.dart';
import '../src/CustomerService.dart';

class CustomerController extends ChangeNotifier {
  // ===== STATE MANAGEMENT =====

  // Loading states
  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  bool _isSearching = false;

  // Data states
  List<CustomerModel> _customers = [];
  CustomerModel? _currentCustomer;
  String _searchQuery = '';
  String _errorMessage = '';
  String _successMessage = '';

  // Pagination states
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _itemsPerPage = 10;
  String _sortBy = 'created_at';
  String _sortOrder = 'DESC';

  // Connection state
  bool _isConnected = true;
  Map<String, String> _connectionDiagnosis = {};

  // ===== GETTERS =====

  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  bool get isSearching => _isSearching;
  bool get hasError => _errorMessage.isNotEmpty;
  bool get hasSuccess => _successMessage.isNotEmpty;
  bool get isConnected => _isConnected;

  List<CustomerModel> get customers => _customers;
  CustomerModel? get currentCustomer => _currentCustomer;
  String get searchQuery => _searchQuery;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  Map<String, String> get connectionDiagnosis => _connectionDiagnosis;

  // Pagination getters
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  int get itemsPerPage => _itemsPerPage;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  bool get hasNextPage => _currentPage < _totalPages;
  bool get hasPreviousPage => _currentPage > 1;
  bool get hasCustomers => _customers.isNotEmpty;

  // Computed getters
  String get paginationInfo =>
      'Showing ${(_currentPage - 1) * _itemsPerPage + 1}-${(_currentPage - 1) * _itemsPerPage + _customers.length} of $_totalItems customers';

  String get pageInfo => 'Page $_currentPage of $_totalPages';

  // ===== CORE METHODS =====

  /// Load all customers with pagination and filtering
  Future<void> loadCustomers({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? sortOrder,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        _setLoading(true);
      }
      _clearMessages();

      // Update parameters if provided
      if (page != null) _currentPage = page;
      if (limit != null) _itemsPerPage = limit;
      if (search != null) _searchQuery = search;
      if (sortBy != null) _sortBy = sortBy;
      if (sortOrder != null) _sortOrder = sortOrder;

      // Call service
      final response = await CustomerService.getAllCustomers(
        page: _currentPage,
        limit: _itemsPerPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      // Extract customers data
      final customersData = CustomerService.extractCustomerList(response);
      _customers =
          customersData.map((json) => CustomerModel.fromJson(json)).toList();

      // Extract pagination info
      final paginationInfo = CustomerService.extractPaginationInfo(response);
      _totalItems = paginationInfo['totalItems'] ?? 0;
      _totalPages = paginationInfo['totalPages'] ?? 1;
      _currentPage = paginationInfo['currentPage'] ?? 1;

      _isConnected = true;
      print('✅ Loaded ${_customers.length} customers successfully');
    } catch (e) {
      _handleError('Failed to load customers', e);
      _isConnected = false;
    } finally {
      if (showLoading) {
        _setLoading(false);
      }
    }
  }

  /// Load customer by ID
  Future<void> loadCustomerById(String id) async {
    try {
      _setLoading(true);
      _clearMessages();

      final customerData = await CustomerService.getCustomerById(id);
      _currentCustomer = CustomerModel.fromJson(customerData);

      print('✅ Loaded customer: ${_currentCustomer?.name}');
    } catch (e) {
      _handleError('Failed to load customer details', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Create new customer
  Future<bool> createCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? imageBase64,
  }) async {
    try {
      _isCreating = true;
      _clearMessages();
      notifyListeners();

      // Validate data
      final validationErrors = CustomerService.validateCustomerData(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (validationErrors.isNotEmpty) {
        final errorMessages =
            validationErrors.values.where((error) => error != null).join(', ');
        throw Exception('Validation failed: $errorMessages');
      }

      // Call service
      final customerData = await CustomerService.createCustomer(
        name: name,
        email: email,
        phone: phone,
        password: password,
        imageBase64: imageBase64,
      );

      // Add to local list
      final newCustomer = CustomerModel.fromJson(customerData);
      _customers.insert(0, newCustomer);
      _totalItems++;

      _setSuccessMessage('Customer "${name}" created successfully');
      print('✅ Created customer: $name');

      return true;
    } catch (e) {
      _handleError('Failed to create customer', e);
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
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
      _isUpdating = true;
      _clearMessages();
      notifyListeners();

      // Validate data
      final validationErrors = CustomerService.validateCustomerData(
        name: name,
        email: email,
        phone: phone,
      );

      if (validationErrors.isNotEmpty) {
        final errorMessages =
            validationErrors.values.where((error) => error != null).join(', ');
        throw Exception('Validation failed: $errorMessages');
      }

      // Call service
      final customerData = await CustomerService.updateCustomer(
        id: id,
        name: name,
        email: email,
        phone: phone,
        imageBase64: imageBase64,
      );

      // Update local list
      final updatedCustomer = CustomerModel.fromJson(customerData);
      final index = _customers.indexWhere((c) => c.id.toString() == id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
      }

      // Update current customer if it's the same
      if (_currentCustomer?.id.toString() == id) {
        _currentCustomer = updatedCustomer;
      }

      _setSuccessMessage('Customer "${name}" updated successfully');
      print('✅ Updated customer: $name');

      return true;
    } catch (e) {
      _handleError('Failed to update customer', e);
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Delete customer
  Future<bool> deleteCustomer(String id, String name) async {
    try {
      _isDeleting = true;
      _clearMessages();
      notifyListeners();

      // Call service
      final success = await CustomerService.deleteCustomer(id);

      if (success) {
        // Remove from local list
        _customers.removeWhere((c) => c.id.toString() == id);
        _totalItems--;

        // Clear current customer if it's the deleted one
        if (_currentCustomer?.id.toString() == id) {
          _currentCustomer = null;
        }

        _setSuccessMessage('Customer "$name" deleted successfully');
        print('✅ Deleted customer: $name');

        return true;
      } else {
        throw Exception('Delete operation failed');
      }
    } catch (e) {
      _handleError('Failed to delete customer', e);
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  /// Search customers
  Future<void> searchCustomers(String query) async {
    try {
      _isSearching = true;
      _searchQuery = query;
      _currentPage = 1; // Reset to first page
      notifyListeners();

      await loadCustomers(showLoading: false);
    } catch (e) {
      _handleError('Failed to search customers', e);
    } finally {
      _isSearching = false;
    }
  }

  /// Clear search and reload all customers
  Future<void> clearSearch() async {
    _searchQuery = '';
    _currentPage = 1;
    await loadCustomers();
  }

  // ===== PAGINATION METHODS =====

  /// Go to next page
  Future<void> nextPage() async {
    if (hasNextPage && !isLoading) {
      await loadCustomers(page: _currentPage + 1);
    }
  }

  /// Go to previous page
  Future<void> previousPage() async {
    if (hasPreviousPage && !isLoading) {
      await loadCustomers(page: _currentPage - 1);
    }
  }

  /// Go to specific page
  Future<void> goToPage(int page) async {
    if (page > 0 && page <= _totalPages && page != _currentPage && !isLoading) {
      await loadCustomers(page: page);
    }
  }

  /// Change items per page
  Future<void> changeItemsPerPage(int itemsPerPage) async {
    if (itemsPerPage != _itemsPerPage && !isLoading) {
      _itemsPerPage = itemsPerPage;
      _currentPage = 1; // Reset to first page
      await loadCustomers();
    }
  }

  /// Change sorting
  Future<void> changeSorting(String sortBy, {String? sortOrder}) async {
    if (!isLoading) {
      _sortBy = sortBy;
      if (sortOrder != null) {
        _sortOrder = sortOrder;
      } else {
        // Toggle sort order if same field
        _sortOrder =
            (_sortBy == sortBy && _sortOrder == 'ASC') ? 'DESC' : 'ASC';
      }
      _currentPage = 1; // Reset to first page
      await loadCustomers();
    }
  }

  // ===== UTILITY METHODS =====

  /// Refresh data
  Future<void> refresh() async {
    await loadCustomers();
  }

  /// Test connection to backend
  Future<void> testConnection() async {
    try {
      _setLoading(true);
      _clearMessages();

      final isConnected = await CustomerService.testConnection();
      _isConnected = isConnected;

      if (isConnected) {
        _setSuccessMessage('✅ Backend connection successful');
      } else {
        _setErrorMessage('❌ Backend connection failed');
      }
    } catch (e) {
      _isConnected = false;
      _handleError('Connection test failed', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Diagnose connection issues
  Future<void> diagnoseConnection() async {
    try {
      _setLoading(true);
      _clearMessages();

      _connectionDiagnosis = await CustomerService.diagnoseConnection();

      final hasAnySuccess = _connectionDiagnosis.values
          .any((result) => result.toLowerCase().contains('success'));

      if (hasAnySuccess) {
        _setSuccessMessage('✅ Connection diagnosis completed');
      } else {
        _setErrorMessage('❌ Connection issues detected');
      }
    } catch (e) {
      _handleError('Connection diagnosis failed', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Get customer by ID from current list
  CustomerModel? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id.toString() == id);
    } catch (e) {
      return null;
    }
  }

  /// Get customers by status
  List<CustomerModel> getCustomersByStatus(String status) {
    return _customers.where((c) => c.customerStatus == status).toList();
  }

  /// Get customers by tier
  List<CustomerModel> getCustomersByTier(String tier) {
    return _customers.where((c) => c.customerTier == tier).toList();
  }

  /// Get active customers (ordered in last 30 days)
  List<CustomerModel> getActiveCustomers() {
    return _customers.where((c) => c.isActiveCustomer).toList();
  }

  /// Get customer statistics
  Map<String, dynamic> getCustomerStatistics() {
    final totalCustomers = _customers.length;
    final activeCustomers = getActiveCustomers().length;
    final newCustomers = getCustomersByStatus('New Customer').length;
    final loyalCustomers = getCustomersByStatus('Loyal Customer').length;

    // Tier distribution
    final goldCustomers = getCustomersByTier('Gold').length;
    final silverCustomers = getCustomersByTier('Silver').length;
    final bronzeCustomers = getCustomersByTier('Bronze').length;
    final basicCustomers = getCustomersByTier('Basic').length;

    // Calculate total spending
    final totalSpent =
        _customers.fold<double>(0.0, (sum, customer) => sum + customer.spent);

    return {
      'totalCustomers': totalCustomers,
      'activeCustomers': activeCustomers,
      'newCustomers': newCustomers,
      'loyalCustomers': loyalCustomers,
      'goldTier': goldCustomers,
      'silverTier': silverCustomers,
      'bronzeTier': bronzeCustomers,
      'basicTier': basicCustomers,
      'totalSpent': totalSpent,
      'averageSpent': totalCustomers > 0 ? totalSpent / totalCustomers : 0.0,
      'activePercentage':
          totalCustomers > 0 ? (activeCustomers / totalCustomers) * 100 : 0.0,
    };
  }

  // ===== PRIVATE HELPER METHODS =====

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    _successMessage = '';
    notifyListeners();
    print('❌ Error: $message');
  }

  void _setSuccessMessage(String message) {
    _successMessage = message;
    _errorMessage = '';
    notifyListeners();
    print('✅ Success: $message');
  }

  void _handleError(String operation, dynamic error) {
    final errorMessage = error.toString().replaceFirst('Exception: ', '');
    _setErrorMessage('$operation: $errorMessage');
  }

  void _clearMessages() {
    _errorMessage = '';
    _successMessage = '';
  }

  /// Clear current customer
  void clearCurrentCustomer() {
    _currentCustomer = null;
    notifyListeners();
  }

  /// Clear all data (useful for logout)
  void clearData() {
    _customers.clear();
    _currentCustomer = null;
    _searchQuery = '';
    _currentPage = 1;
    _totalPages = 1;
    _totalItems = 0;
    _clearMessages();
    notifyListeners();
  }

  // ===== MESSAGE HANDLING =====

  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Clear success message
  void clearSuccess() {
    _successMessage = '';
    notifyListeners();
  }

  /// Clear all messages
  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  // ===== VALIDATION HELPERS =====

  /// Validate customer data and return errors
  Map<String, String?> validateCustomer({
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

  /// Check if email already exists (excluding current customer)
  bool isEmailTaken(String email, {String? excludeId}) {
    return _customers.any((customer) =>
        customer.email.toLowerCase() == email.toLowerCase() &&
        customer.id.toString() != excludeId);
  }

  /// Check if phone already exists (excluding current customer)
  bool isPhoneTaken(String phone, {String? excludeId}) {
    return _customers.any((customer) =>
        customer.phone == phone && customer.id.toString() != excludeId);
  }

  // ===== DISPOSE =====

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
