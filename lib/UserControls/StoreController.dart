import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../src/StoreService.dart';
import '../Models/StoreModel.dart';

class StoreController extends GetxController {
  // Observable variables
  final stores = <StoreModel>[].obs;
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
  final selectedStatusFilter = 'all'.obs;

  // Selection
  final selectedStores = <StoreModel>[].obs;
  final isAllSelected = false.obs;

  // Form data for add/edit
  final formKey = GlobalKey<FormState>();

  // Owner data
  final ownerNameController = TextEditingController();
  final ownerEmailController = TextEditingController();
  final ownerPhoneController = TextEditingController();
  final ownerPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Store data
  final storeNameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final openTimeController = TextEditingController();
  final closeTimeController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  // Form state
  final isFormLoading = false.obs;
  // final isEditMode = false.obs;
  final isEditMode = true.obs;
  final editingStoreId = ''.obs;
  final selectedImageBase64 = ''.obs;
  final selectedStatus = 'active'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
  }

  @override
  void onClose() {
    // Dispose all controllers
    ownerNameController.dispose();
    ownerEmailController.dispose();
    ownerPhoneController.dispose();
    ownerPasswordController.dispose();
    confirmPasswordController.dispose();
    storeNameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    openTimeController.dispose();
    closeTimeController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.onClose();
  }

  // Tambah method validation baru
  bool validateUpdateData() {
    if (editingStoreId.value.isEmpty) {
      _showErrorSnackbar('Store ID is missing');
      return false;
    }

    if (storeNameController.text.trim().isEmpty) {
      _showErrorSnackbar('Store name is required');
      return false;
    }

    if (addressController.text.trim().isEmpty) {
      _showErrorSnackbar('Store address is required');
      return false;
    }

    if (ownerNameController.text.trim().isEmpty) {
      _showErrorSnackbar('Owner name is required');
      return false;
    }

    final latitude = double.tryParse(latitudeController.text.trim());
    final longitude = double.tryParse(longitudeController.text.trim());

    if (latitude == null || longitude == null) {
      _showErrorSnackbar('Valid coordinates are required');
      return false;
    }

    return true;
  }

  // ✅ FIXED: Fetch stores sesuai dengan response backend yang sebenarnya
  Future<void> fetchStores({int page = 1, bool isRefresh = false}) async {
    try {
      if (isRefresh || page == 1) {
        isLoading.value = true;
        stores.clear();
        currentPage.value = 1;
      } else {
        isLoadingMore.value = true;
      }

      hasError.value = false;
      errorMessage.value = '';

      print('🔍 Fetching stores - Page: $page');

      // ✅ Call StoreService
      final response = await StoreService.getAllStores(
        page: page,
        limit: itemsPerPage.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      print('📥 Raw response type: ${response.runtimeType}');
      print('📥 Response keys: ${response.keys.toList()}');

      // ✅ FIXED: Handle actual backend response format
      // Format: { "message": "Berhasil mendapatkan data store", "data": [...] }

      if (!response.containsKey('data')) {
        throw Exception('Response missing data field');
      }

      final dataField = response['data'];
      print('📋 Data field type: ${dataField.runtimeType}');

      List<dynamic> storesData = [];

      if (dataField is List) {
        // ✅ This is the actual format from backend
        print('✅ Found stores array in data field');
        storesData = List<dynamic>.from(dataField);
      } else {
        throw Exception(
            'Data field is not an array. Type: ${dataField.runtimeType}');
      }

      print('📊 Found ${storesData.length} stores in response');

      // ✅ Convert to StoreModel objects
      final List<StoreModel> storesList = [];

      for (int i = 0; i < storesData.length; i++) {
        try {
          final item = storesData[i];
          if (item is Map<String, dynamic>) {
            final store = StoreModel.fromJson(Map<String, dynamic>.from(item));
            storesList.add(store);
            print('✅ Parsed store ${i + 1}: ${store.name} (ID: ${store.id})');
          } else {
            print('⚠️ Store item $i is not a Map: ${item.runtimeType}');
          }
        } catch (e, stackTrace) {
          print('❌ Error parsing store item $i: $e');
          print('📄 Item data: ${storesData[i]}');
          print('📍 Stack trace: $stackTrace');
          // Continue with other stores even if one fails
        }
      }

      // ✅ Update stores list
      if (page == 1 || isRefresh) {
        stores.assignAll(storesList);
      } else {
        stores.addAll(storesList);
      }

      // ✅ FIXED: Handle pagination - Since backend doesn't return pagination info,
      // we'll simulate it based on the response
      if (page == 1) {
        currentPage.value = 1;
        totalItems.value = storesList.length;

        // If we get less than requested limit, we're on the last page
        if (storesList.length < itemsPerPage.value) {
          totalPages.value = 1;
        } else {
          // Estimate total pages (we'll adjust as we get more data)
          totalPages.value = 2; // Assume there might be more
        }
      } else {
        currentPage.value = page;
        totalItems.value =
            stores.length; // Update total to current loaded count

        // If we get less than requested limit, this is the last page
        if (storesList.length < itemsPerPage.value) {
          totalPages.value = currentPage.value;
        } else {
          totalPages.value =
              currentPage.value + 1; // Assume there might be more
        }
      }

      print('✅ Successfully loaded ${storesList.length} stores');
      print('📊 Total stores in list: ${stores.length}');
      print(
          '📊 Pagination - Page: ${currentPage.value}/${totalPages.value}, Total: ${totalItems.value}');
    } catch (e, stackTrace) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('❌ Error in fetchStores: $e');
      print('📍 Stack trace: $stackTrace');
      _showErrorSnackbar('Failed to load stores: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load more stores (pagination)
  Future<void> loadMoreStores() async {
    if (currentPage.value < totalPages.value && !isLoadingMore.value) {
      await fetchStores(page: currentPage.value + 1);
    }
  }

  // Refresh stores list
  Future<void> refreshStores() async {
    await fetchStores(page: 1, isRefresh: true);
  }

  // Search stores
  void searchStores(String query) {
    searchQuery.value = query;
    fetchStores(page: 1, isRefresh: true);
  }

  // Filter stores by status
  void filterStoresByStatus(String status) {
    selectedStatusFilter.value = status;
    fetchStores(page: 1, isRefresh: true);
  }

  // Get store by ID
  Future<StoreModel?> getStoreById(String id) async {
    try {
      final response = await StoreService.getStoreById(id);
      return StoreModel.fromJson(response);
    } catch (e) {
      _showErrorSnackbar('Failed to get store: ${e.toString()}');
      return null;
    }
  }

  // Create new store (ADMIN BISA AKSES)
  Future<bool> createStore() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    try {
      isFormLoading.value = true;

      final latitude = double.tryParse(latitudeController.text);
      final longitude = double.tryParse(longitudeController.text);

      if (latitude == null || longitude == null) {
        _showErrorSnackbar('Please enter valid latitude and longitude');
        return false;
      }

      await StoreService.createStore(
        name: storeNameController.text,
        email: ownerEmailController.text,
        password: ownerPasswordController.text,
        phone: ownerPhoneController.text,
        address: addressController.text,
        description: descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
        imageBase64: selectedImageBase64.value.isNotEmpty
            ? selectedImageBase64.value
            : null,
        openTime: openTimeController.text,
        closeTime: closeTimeController.text,
        latitude: latitude,
        longitude: longitude,
      );

      _showSuccessSnackbar('Store created successfully');
      clearForm();
      refreshStores();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to create store: ${e.toString()}');
      return false;
    } finally {
      isFormLoading.value = false;
    }
  }

  // Update store (ADMIN BISA AKSES)
  Future<bool> updateStore() async {
    // if (!formKey.currentState!.validate()) {
    //   return false;
    // }
    if (!validateUpdateData()) {
      return false;
    }
    try {
      isFormLoading.value = true;

      // ✅ Validate required fields
      if (editingStoreId.value.isEmpty) {
        throw Exception('Store ID is required for update');
      }

      if (storeNameController.text.trim().isEmpty) {
        throw Exception('Store name is required');
      }

      if (addressController.text.trim().isEmpty) {
        throw Exception('Store address is required');
      }

      if (ownerNameController.text.trim().isEmpty) {
        throw Exception('Owner name is required');
      }

      // ✅ Parse and validate coordinates
      final latitude = double.tryParse(latitudeController.text.trim());
      final longitude = double.tryParse(longitudeController.text.trim());

      if (latitude == null || longitude == null) {
        throw Exception('Valid latitude and longitude are required');
      }

      // ✅ Prepare data with proper null handling
      await StoreService.updateStore(
        editingStoreId.value,
        name: storeNameController.text.trim(),
        email: ownerEmailController.text.trim().isNotEmpty
            ? ownerEmailController.text.trim()
            : null,
        phone: ownerPhoneController.text.trim().isNotEmpty
            ? ownerPhoneController.text.trim()
            : null,
        address: addressController.text.trim(),
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        imageBase64: selectedImageBase64.value.isNotEmpty
            ? selectedImageBase64.value
            : null,
        openTime: openTimeController.text.trim().isNotEmpty
            ? openTimeController.text.trim()
            : null,
        closeTime: closeTimeController.text.trim().isNotEmpty
            ? closeTimeController.text.trim()
            : null,
        latitude: latitude,
        longitude: longitude,
        status: selectedStatus.value,
      );

      _showSuccessSnackbar('Store updated successfully');
      clearForm();
      refreshStores();
      return true;
    } catch (e) {
      print('❌ StoreController.updateStore error: $e');
      _showErrorSnackbar('Failed to update store: ${e.toString()}');
      return false;
    } finally {
      isFormLoading.value = false;
    }
  }

  // Delete store (ADMIN BISA AKSES)
  Future<bool> deleteStore(String id) async {
    try {
      await StoreService.deleteStore(id);
      _showSuccessSnackbar('Store deleted successfully');
      refreshStores();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to delete store: ${e.toString()}');
      return false;
    }
  }

  // Delete multiple stores
  Future<bool> deleteMultipleStores() async {
    if (selectedStores.isEmpty) {
      _showErrorSnackbar('No stores selected');
      return false;
    }
    try {
      for (final store in selectedStores) {
        await StoreService.deleteStore(store.id.toString());
      }

      _showSuccessSnackbar(
          '${selectedStores.length} stores deleted successfully');
      clearSelection();
      refreshStores();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to delete stores: ${e.toString()}');
      return false;
    }
  }

  // Update store status (ADMIN BISA AKSES)
  Future<void> updateStoreStatus(String storeId, String status) async {
    try {
      await StoreService.updateStoreStatus(storeId, status);
      // Update local store status
      final storeIndex = stores.indexWhere((s) => s.id.toString() == storeId);
      if (storeIndex != -1) {
        // Refresh data to get updated store
        refreshStores();
      }

      _showSuccessSnackbar('Store status updated to $status');
    } catch (e) {
      _showErrorSnackbar('Failed to update store status: ${e.toString()}');
    }
  }

  // Form management
  void setEditMode(StoreModel store) {
    isEditMode.value = true;
    editingStoreId.value = store.id.toString();

    // Owner data
    ownerNameController.text = store.ownerName;
    ownerEmailController.text = store.ownerEmail;
    ownerPhoneController.text = store.ownerPhone;
    ownerPasswordController.clear();
    confirmPasswordController.clear();

    // Store data
    storeNameController.text = store.name;
    addressController.text = store.address;
    descriptionController.text = store.description ?? '';
    openTimeController.text = store.openTime ?? '';
    closeTimeController.text = store.closeTime ?? '';
    latitudeController.text = store.latitude.toString();
    longitudeController.text = store.longitude.toString();
    selectedStatus.value = store.status;
    selectedImageBase64.value = store.imageUrl ?? '';
  }

  void clearForm() {
    isEditMode.value = false;
    editingStoreId.value = '';

    // Clear owner data
    ownerNameController.clear();
    ownerEmailController.clear();
    ownerPhoneController.clear();
    ownerPasswordController.clear();
    confirmPasswordController.clear();

    // Clear store data
    storeNameController.clear();
    addressController.clear();
    descriptionController.clear();
    openTimeController.clear();
    closeTimeController.clear();
    latitudeController.clear();
    longitudeController.clear();
    selectedStatus.value = 'active';
    selectedImageBase64.value = '';
  }

  void setSelectedImage(String base64Image) {
    selectedImageBase64.value = base64Image;
  }

  void setSelectedStatus(String status) {
    selectedStatus.value = status;
  }

  // Selection management
  void toggleStoreSelection(StoreModel store) {
    if (selectedStores.contains(store)) {
      selectedStores.remove(store);
    } else {
      selectedStores.add(store);
    }
    _updateSelectAllState();
  }

  void toggleSelectAll() {
    if (isAllSelected.value) {
      selectedStores.clear();
    } else {
      selectedStores.assignAll(stores);
    }
    _updateSelectAllState();
  }

  void clearSelection() {
    selectedStores.clear();
    isAllSelected.value = false;
  }

  void _updateSelectAllState() {
    isAllSelected.value =
        stores.isNotEmpty && selectedStores.length == stores.length;
  }

  // Utility methods
  bool isStoreSelected(StoreModel store) {
    return selectedStores.contains(store);
  }

  int get selectedCount => selectedStores.length;

  List<StoreModel> get filteredStores {
    var filtered = stores.where((store) {
      // Status filter
      if (selectedStatusFilter.value != 'all' &&
          store.status != selectedStatusFilter.value) {
        return false;
      }

      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        return store.name.toLowerCase().contains(query) ||
            store.address.toLowerCase().contains(query) ||
            store.ownerName.toLowerCase().contains(query) ||
            (store.description?.toLowerCase().contains(query) ?? false);
      }

      return true;
    }).toList();

    return filtered;
  }

  // ✅ FIXED: Statistics - Handle null rating values properly
  int get totalStoresCount => stores.length; // Changed from totalItems.value
  int get activeStoresCount => stores.where((s) => s.isActive).length;
  int get inactiveStoresCount => stores.where((s) => s.isInactive).length;

  double get averageRating {
    if (stores.isEmpty) return 0.0;
    final validRatings = stores
        .where((store) => store.rating != null && store.rating! > 0)
        .map((store) => store.rating!)
        .toList();

    if (validRatings.isEmpty) return 0.0;

    return validRatings.fold(0.0, (sum, rating) => sum + rating) /
        validRatings.length;
  }

  String get averageRatingDisplay => averageRating.toStringAsFixed(1);

  // Status options for dropdown
  List<String> get statusOptions => ['active', 'inactive'];

  // Filter options
  List<String> get filterOptions => ['all', 'active', 'inactive'];

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

  // Validation methods
  String? validateOwnerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Owner name is required';
    }
    if (value.length < 2) {
      return 'Owner name must be at least 2 characters';
    }
    return null;
  }

  String? validateOwnerEmail(String? value) {
    // ✅ Email bisa kosong di edit mode
    if (value == null || value.trim().isEmpty) {
      if (isEditMode.value) {
        return null; // Allow empty email in edit mode
      }
      return 'Owner email is required';
    }

    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateOwnerPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Owner phone is required';
    }
    if (value.length < 10) {
      return 'Phone must be at least 10 digits';
    }
    return null;
  }

  String? validateStoreName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Store name is required';
    }
    if (value.length < 2) {
      return 'Store name must be at least 2 characters';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (value.length < 10) {
      return 'Address must be at least 10 characters';
    }
    return null;
  }

  String? validateCoordinate(String? value, String coordinateName) {
    if (value == null || value.isEmpty) {
      return '$coordinateName is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid $coordinateName';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (isEditMode.value && (value == null || value.isEmpty)) {
      return null; // Password is optional when editing
    }
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (isEditMode.value && ownerPasswordController.text.isEmpty) {
      return null; // Skip validation if password is not being updated
    }
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != ownerPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
