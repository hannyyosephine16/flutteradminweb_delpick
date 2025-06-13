import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../src/MenuItemService.dart';

// Simplified MenuItemModel for controller usage
class MenuItemModel {
  final int id;
  final String name;
  final int price;
  final String? description;
  final String? imageUrl;
  final int storeId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final StoreInfo? store;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    required this.storeId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.store,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      description: json['description'],
      imageUrl: json['imageUrl'],
      storeId: json['storeId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      store: json['store'] != null ? StoreInfo.fromJson(json['store']) : null,
    );
  }

  String get priceDisplay => 'Rp ${price.toStringAsFixed(0)}';
  String get storeName => store?.name ?? 'Unknown Store';
  bool get isAvailable => quantity > 0;
  bool get isOutOfStock => quantity == 0;
  String get stockStatus {
    if (quantity == 0) return 'Out of Stock';
    if (quantity <= 10) return 'Low Stock';
    return 'In Stock';
  }
}

class StoreInfo {
  final int id;
  final String name;
  final String? address;

  StoreInfo({
    required this.id,
    required this.name,
    this.address,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'],
    );
  }
}

class MenuItemController extends GetxController {
  // Observable variables
  final menuItems = <MenuItemModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isReadOnlyMode = true.obs; // Admin hanya bisa read, tidak bisa CRUD

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 0.obs;
  final totalItems = 0.obs;
  final itemsPerPage = 10.obs;

  // Search and filter
  final searchQuery = ''.obs;
  final selectedStoreFilter = 'all'.obs;
  final selectedStockFilter = 'all'.obs;

  // Store options for dropdown
  final storeOptions = <Map<String, dynamic>>[].obs;
  final isLoadingStores = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMenuItems();
    _showReadOnlyNotification();
  }

  void _showReadOnlyNotification() {
    Get.snackbar(
      'Read-Only Mode',
      'Admin can view menu items but cannot create/edit/delete.\nOnly store owners can manage their menu items.',
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade800,
      duration: Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
    );
  }

  // Fetch menu items dengan pagination (ADMIN BISA AKSES)
// ✅ COMPLETELY FIXED: Fetch menu items with proper response handling
  Future<void> fetchMenuItems({int page = 1, bool isRefresh = false}) async {
    try {
      if (isRefresh || page == 1) {
        isLoading.value = true;
        menuItems.clear();
      } else {
        isLoadingMore.value = true;
      }

      hasError.value = false;
      errorMessage.value = '';

      // ✅ This now always returns Map<String, dynamic> from MenuItemService
      final response = await MenuItemService.getAllMenuItems(
          page: page, limit: itemsPerPage.value);

      print('🔍 MenuItemController - Response type: ${response.runtimeType}');
      print('🔍 MenuItemController - Response keys: ${response.keys.toList()}');

      // ✅ Since MenuItemService now always returns Map<String, dynamic>
      // We can safely extract the data
      List<dynamic> menuItemsData = [];
      int totalPages = 1;
      int totalItems = 0;
      int currentPageNum = page;

      // Extract menu items data from response
      final dataField = response['data'];
      print('🔍 Data field type: ${dataField.runtimeType}');

      if (dataField is List) {
        // Case 1: { data: [menuItem1, menuItem2, ...] } - Most common
        print('✅ Found menu items array in data field');
        menuItemsData = List<dynamic>.from(dataField);
      } else if (dataField is Map<String, dynamic>) {
        // Case 2: { data: { menuItems: [...], ... } } - Nested structure
        print('📋 Data field keys: ${dataField.keys.toList()}');
        final menuItemsField = dataField['menuItems'];
        if (menuItemsField is List) {
          print('✅ Found menu items array in data.menuItems');
          menuItemsData = List<dynamic>.from(menuItemsField);
        }
      } else {
        print('⚠️ Unexpected data field type: ${dataField.runtimeType}');
        // Fallback: check if menuItems are at root level
        final rootMenuItems = response['menuItems'];
        if (rootMenuItems is List) {
          print('✅ Found menu items array at root level');
          menuItemsData = List<dynamic>.from(rootMenuItems);
        }
      }

      // Extract pagination info
      totalPages = (response['totalPages'] as num?)?.toInt() ?? 1;
      totalItems =
          (response['totalItems'] as num?)?.toInt() ?? menuItemsData.length;
      currentPageNum = (response['currentPage'] as num?)?.toInt() ?? page;

      print('📊 Extracted ${menuItemsData.length} menu items from response');
      print(
          '📊 Pagination: Page $currentPageNum of $totalPages (Total: $totalItems)');

      // Convert to MenuItemModel objects
      final List<MenuItemModel> menuItemsList = [];
      for (int i = 0; i < menuItemsData.length; i++) {
        try {
          final item = menuItemsData[i];
          if (item is Map<String, dynamic>) {
            final menuItem =
                MenuItemModel.fromJson(Map<String, dynamic>.from(item));
            menuItemsList.add(menuItem);
            print('✅ Parsed menu item ${i + 1}: ${menuItem.name}');
          } else {
            print('⚠️ Menu item $i is not a Map: ${item.runtimeType}');
          }
        } catch (e, stackTrace) {
          print('❌ Error parsing menu item $i: $e');
          print('   Item: ${menuItemsData[i]}');
          // Continue with other menu items even if one fails
        }
      }

      // Update menu items list
      if (page == 1) {
        menuItems.assignAll(menuItemsList);
      } else {
        menuItems.addAll(menuItemsList);
      }

      // Update pagination info
      currentPage.value = currentPageNum;
      this.totalPages.value = totalPages;
      this.totalItems.value = totalItems;

      print('✅ Successfully loaded ${menuItemsList.length} menu items');
      print('📊 Final state - Total menu items in list: ${menuItems.length}');
    } catch (e, stackTrace) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('❌ Error in fetchMenuItems: $e');
      print('📍 Stack trace: $stackTrace');
      _showErrorSnackbar('Failed to load menu items: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

// ✅ FIXED: Get menu items by store ID (ADMIN BISA AKSES)
  Future<void> fetchMenuItemsByStore(String storeId, {int page = 1}) async {
    try {
      isLoading.value = true;
      final response = await MenuItemService.getMenuItemsByStoreId(storeId,
          page: page, limit: itemsPerPage.value);

      print(
          '🔍 fetchMenuItemsByStore - Response type: ${response.runtimeType}');

      // ✅ Handle response consistently
      List<dynamic> menuItemsData = [];

      final dataField = response['data'];
      if (dataField is List) {
        menuItemsData = List<dynamic>.from(dataField);
      } else if (dataField is Map<String, dynamic> &&
          dataField['menuItems'] is List) {
        menuItemsData = List<dynamic>.from(dataField['menuItems']);
      } else if (response['menuItems'] is List) {
        menuItemsData = List<dynamic>.from(response['menuItems']);
      }

      final menuItemsList = menuItemsData
          .where((item) => item is Map<String, dynamic>)
          .map(
              (json) => MenuItemModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      menuItems.assignAll(menuItemsList);

      // Update pagination info
      currentPage.value = (response['currentPage'] as num?)?.toInt() ?? page;
      totalPages.value = (response['totalPages'] as num?)?.toInt() ?? 1;
      totalItems.value =
          (response['totalItems'] as num?)?.toInt() ?? menuItemsList.length;

      print(
          '✅ Successfully loaded ${menuItemsList.length} menu items for store $storeId');
    } catch (e) {
      print('❌ Error in fetchMenuItemsByStore: $e');
      _showErrorSnackbar('Failed to load store menu items: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

// ✅ FIXED: Search menu items by query (ADMIN BISA AKSES)
  Future<void> searchMenuItemsApi(String query) async {
    try {
      isLoading.value = true;
      final response = await MenuItemService.searchMenuItems(query,
          page: 1, limit: itemsPerPage.value);

      print('🔍 searchMenuItemsApi - Response type: ${response.runtimeType}');

      // ✅ Handle response consistently
      List<dynamic> menuItemsData = [];

      final dataField = response['data'];
      if (dataField is List) {
        menuItemsData = List<dynamic>.from(dataField);
      } else if (dataField is Map<String, dynamic> &&
          dataField['menuItems'] is List) {
        menuItemsData = List<dynamic>.from(dataField['menuItems']);
      } else if (response['menuItems'] is List) {
        menuItemsData = List<dynamic>.from(response['menuItems']);
      }

      final menuItemsList = menuItemsData
          .where((item) => item is Map<String, dynamic>)
          .map(
              (json) => MenuItemModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      menuItems.assignAll(menuItemsList);

      print(
          '✅ Successfully searched ${menuItemsList.length} menu items for query: "$query"');
    } catch (e) {
      print('❌ Error in searchMenuItemsApi: $e');
      _showErrorSnackbar('Failed to search menu items: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load more menu items (pagination)
  Future<void> loadMoreMenuItems() async {
    if (currentPage.value < totalPages.value && !isLoadingMore.value) {
      await fetchMenuItems(page: currentPage.value + 1);
    }
  }

  // Refresh menu items list
  Future<void> refreshMenuItems() async {
    await fetchMenuItems(page: 1, isRefresh: true);
  }

  // Search menu items
  void searchMenuItems(String query) {
    searchQuery.value = query;
    fetchMenuItems(page: 1, isRefresh: true);
  }

  // Filter menu items by store (ADMIN BISA AKSES)
  void filterMenuItemsByStore(String storeId) {
    selectedStoreFilter.value = storeId;
    if (storeId != 'all') {
      fetchMenuItemsByStore(storeId);
    } else {
      fetchMenuItems(page: 1, isRefresh: true);
    }
  }

  // Filter menu items by stock status
  void filterMenuItemsByStock(String stockFilter) {
    selectedStockFilter.value = stockFilter;
    fetchMenuItems(page: 1, isRefresh: true);
  }

  // Get menu item by ID (ADMIN BISA AKSES)
  Future<MenuItemModel?> getMenuItemById(String id) async {
    try {
      final response = await MenuItemService.getMenuItemById(id);
      return MenuItemModel.fromJson(response);
    } catch (e) {
      _showErrorSnackbar('Failed to get menu item: ${e.toString()}');
      return null;
    }
  }

  // CRUD Operations - ADMIN TIDAK BISA AKSES (Show notification)
  Future<bool> createMenuItem() async {
    _showCRUDNotAllowedNotification('create');
    return false;
  }

  Future<bool> updateMenuItem() async {
    _showCRUDNotAllowedNotification('update');
    return false;
  }

  Future<bool> deleteMenuItem(String id) async {
    _showCRUDNotAllowedNotification('delete');
    return false;
  }

  Future<bool> deleteMultipleMenuItems() async {
    _showCRUDNotAllowedNotification('delete multiple');
    return false;
  }

  void _showCRUDNotAllowedNotification(String action) {
    Get.snackbar(
      'Action Not Allowed',
      'Admin cannot $action menu items.\n\nBackend restriction: Only store owners (isOwner middleware) can create/update/delete menu items.',
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade800,
      duration: Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Utility methods
  List<MenuItemModel> get filteredMenuItems {
    var filtered = menuItems.where((menuItem) {
      // Store filter
      if (selectedStoreFilter.value != 'all' &&
          menuItem.storeId.toString() != selectedStoreFilter.value) {
        return false;
      }

      // Stock filter
      if (selectedStockFilter.value != 'all') {
        switch (selectedStockFilter.value) {
          case 'in_stock':
            if (!menuItem.isAvailable) return false;
            break;
          case 'out_of_stock':
            if (menuItem.isAvailable) return false;
            break;
          case 'low_stock':
            if (menuItem.quantity > 10) return false;
            break;
        }
      }

      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        return menuItem.name.toLowerCase().contains(query) ||
            (menuItem.description?.toLowerCase().contains(query) ?? false) ||
            menuItem.storeName.toLowerCase().contains(query);
      }

      return true;
    }).toList();

    return filtered;
  }

  // Statistics
  int get totalMenuItemsCount => totalItems.value;
  int get availableItemsCount =>
      menuItems.where((item) => item.isAvailable).length;
  int get outOfStockItemsCount =>
      menuItems.where((item) => item.isOutOfStock).length;
  int get lowStockItemsCount => menuItems
      .where((item) => item.quantity <= 10 && item.quantity > 0)
      .length;

  double get averagePrice => menuItems.isEmpty
      ? 0.0
      : menuItems.fold(0.0, (sum, item) => sum + item.price) / menuItems.length;

  int get totalStockQuantity =>
      menuItems.fold(0, (sum, item) => sum + item.quantity);

  String get averagePriceDisplay => 'Rp ${averagePrice.toStringAsFixed(0)}';

  // Filter options
  List<String> get stockFilterOptions =>
      ['all', 'in_stock', 'out_of_stock', 'low_stock'];

  // Helper methods for stock status colors
  Color getStockStatusColor(MenuItemModel menuItem) {
    if (menuItem.isOutOfStock) return Colors.red;
    if (menuItem.quantity <= 10) return Colors.orange;
    return Colors.green;
  }

  String getStockStatusText(MenuItemModel menuItem) {
    if (menuItem.isOutOfStock) return 'Out of Stock';
    if (menuItem.quantity <= 10) return 'Low Stock';
    return 'In Stock';
  }

  // Widget untuk menampilkan read-only badge
  Widget buildReadOnlyBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility, size: 16, color: Colors.blue.shade700),
          SizedBox(width: 4),
          Text(
            'Read-Only',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Snackbar helpers
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
