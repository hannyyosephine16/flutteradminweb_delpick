import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delpick_admin/Views/Dashboard/StoreDetail/EditStore.dart';
import 'package:delpick_admin/Views/Dashboard/StoreDetail/addstore.dart';
import '../../UserControls/StoreController.dart';
import '../../Models/StoreModel.dart';

class StoreSection extends StatefulWidget {
  const StoreSection({Key? key}) : super(key: key);

  @override
  State<StoreSection> createState() => StoreSectionState();
}

class StoreSectionState extends State<StoreSection> {
  late final StoreController _storeController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _storeController = Get.put(StoreController());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Store',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddNewStoreScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3B89),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('+ New Store'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(builder: (context, constraints) {
          final bool isSmallScreen = constraints.maxWidth < 800;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and stats
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // Search and filter section
                  _buildSearchAndFilter(),
                  const SizedBox(height: 16),

                  // Table/List Section
                  Expanded(
                    child: Obx(() {
                      if (_storeController.isLoading.value &&
                          _storeController.stores.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (_storeController.hasError.value) {
                        return _buildErrorState();
                      }

                      return isSmallScreen ? _buildListView() : _buildTable();
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Pagination
                  Obx(() => _buildPagination()),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Store Management",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A3B89),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Total: ${_storeController.totalStoresCount} stores",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildStatCard(
                    "Active", _storeController.activeStoresCount, Colors.green),
                const SizedBox(width: 12),
                _buildStatCard("Inactive", _storeController.inactiveStoresCount,
                    Colors.orange),
                const SizedBox(width: 12),
                _buildStatCard("Avg Rating",
                    _storeController.averageRatingDisplay, Colors.blue),
              ],
            ),
          ],
        ));
  }

  Widget _buildStatCard(String label, dynamic value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search stores by name, address, or owner...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1A3B89)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _storeController.searchStores('');
                      },
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(color: Color(0xFF1A3B89), width: 2.0),
              ),
            ),
            onChanged: (value) {
              _storeController.searchStores(value);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Obx(() => DropdownButtonFormField<String>(
                value: _storeController.selectedStatusFilter.value,
                decoration: InputDecoration(
                  labelText: 'Filter by Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                items: _storeController.filterOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status.toUpperCase()),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _storeController.filterStoresByStatus(newValue);
                  }
                },
              )),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _storeController.refreshStores(),
          icon: Obx(() => _storeController.isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh)),
          label: const Text('Refresh'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A3B89),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading stores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                _storeController.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              )),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _storeController.refreshStores(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Obx(() {
      final stores = _storeController.filteredStores;

      if (stores.isEmpty) {
        return _buildEmptyState();
      }

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            // Header Row with gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A3B89), Color(0xFF2A5CAA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    _tableHeaderCell("Store ID", 1),
                    _tableHeaderCell("Store Name", 2),
                    _tableHeaderCell("Owner", 2),
                    _tableHeaderCell("Address", 2.5),
                    _tableHeaderCell("Phone", 1.5),
                    _tableHeaderCell("Status", 1),
                    _tableHeaderCell("Rating", 1),
                    _tableHeaderCell("Actions", 1.5),
                  ],
                ),
              ),
            ),

            // Table Body
            Expanded(
              child: ListView.builder(
                itemCount: stores.length,
                itemBuilder: (context, index) {
                  final store = stores[index];
                  return Container(
                    decoration: BoxDecoration(
                      color:
                          index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          _tableCell(store.id.toString(), 1),
                          _tableCell(store.name, 2),
                          _tableCell(store.ownerName, 2),
                          _tableCell(store.address, 2.5, isAddress: true),
                          _tableCell(store.phone, 1.5),
                          _tableStatusCell(store.status, 1),
                          _tableCell(store.ratingDisplay, 1),
                          _tableActionCell(store, 1.5),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Loading more indicator
            if (_storeController.isLoadingMore.value)
              Container(
                padding: const EdgeInsets.all(16),
                child: const CircularProgressIndicator(),
              ),
          ],
        ),
      );
    });
  }

  Widget _tableHeaderCell(String text, double flex) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _tableCell(String text, double flex, {bool isAddress = false}) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: isAddress ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _tableStatusCell(String status, double flex) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'inactive':
        statusColor = Colors.orange;
        break;
      case 'closed':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Expanded(
      flex: (flex * 10).toInt(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Text(
            status.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _tableActionCell(StoreModel store, double flex) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF1A3B89), size: 18),
              onPressed: () {
                _storeController.setEditMode(store);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditStoreScreen()),
                );
              },
              tooltip: "Edit Store",
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
              onPressed: () {
                _showDeleteConfirmationDialog(store);
              },
              tooltip: "Delete Store",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Obx(() {
      final stores = _storeController.filteredStores;

      if (stores.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        itemCount:
            stores.length + (_storeController.isLoadingMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == stores.length) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          final store = stores[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          store.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A3B89),
                          ),
                        ),
                      ),
                      _buildStatusChip(store.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _listTile("Store ID", store.id.toString()),
                  _listTile("Owner", store.ownerName),
                  _listTile("Address", store.address),
                  _listTile("Phone", store.phone),
                  _listTile("Operating Hours", store.operatingHours),
                  _listTile("Rating", "${store.ratingDisplay} ⭐"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _storeController.setEditMode(store);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditStoreScreen()),
                            );
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Edit"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3B89),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showDeleteConfirmationDialog(store);
                          },
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text("Delete"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildStatusChip(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'inactive':
        statusColor = Colors.orange;
        break;
      case 'closed':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _listTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(": ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _storeController.searchQuery.value.isNotEmpty
                ? 'No stores found matching your search'
                : 'No stores found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _storeController.searchQuery.value.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Add your first store to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          if (_storeController.searchQuery.value.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                _storeController.searchStores('');
              },
              child: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPagination() {
    final totalPages = _storeController.totalPages.value;
    final currentPage = _storeController.currentPage.value;

    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Showing ${_storeController.stores.length} of ${_storeController.totalItems.value} stores",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Color(0xFF1A3B89)),
                onPressed: currentPage > 1
                    ? () {
                        _storeController.fetchStores(page: currentPage - 1);
                      }
                    : null,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3B89),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "$currentPage / $totalPages",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Color(0xFF1A3B89)),
                onPressed: currentPage < totalPages
                    ? () {
                        _storeController.fetchStores(page: currentPage + 1);
                      }
                    : null,
              ),
            ],
          ),
          if (currentPage < totalPages)
            TextButton(
              onPressed: _storeController.isLoadingMore.value
                  ? null
                  : () => _storeController.loadMoreStores(),
              child: _storeController.isLoadingMore.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      "Load More",
                      style: TextStyle(color: Color(0xFF1A3B89)),
                    ),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(StoreModel store) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete this store?'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Store: ${store.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Owner: ${store.ownerName}'),
                    Text('Address: ${store.address}'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success =
                    await _storeController.deleteStore(store.id.toString());
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Store "${store.name}" deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
