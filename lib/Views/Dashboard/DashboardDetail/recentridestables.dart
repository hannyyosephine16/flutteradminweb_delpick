// Updated recentridestables.dart - Menggunakan data real dari OrderModel
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../UserControls/DashboardController.dart';
import '../../../Models/OrderModel.dart';

class RecentRidesTable extends StatefulWidget {
  const RecentRidesTable({super.key});

  @override
  State<RecentRidesTable> createState() => _RecentRidesTableState();
}

class _RecentRidesTableState extends State<RecentRidesTable> {
  int _currentPage = 0;
  final int _rowsPerPage = 5;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchActive = false;

  // Get controller instance
  final DashboardController controller = Get.find<DashboardController>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrderModel> get _filteredOrders {
    if (_searchQuery.isEmpty) {
      return controller.recentOrders;
    }

    return controller.recentOrders.where((order) {
      return order.id
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          order.customerName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          order.driverName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.storeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.orderStatusDisplay
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isSmallScreen = constraints.maxWidth < 800;

      return Container(
        margin: const EdgeInsets.only(top: 5),
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
              // Header with title and search/refresh buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Orders",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A3B89),
                    ),
                  ),
                  Row(
                    children: [
                      // Refresh button
                      Obx(() => IconButton(
                            icon: controller.isLoadingOrders.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.refresh,
                                    color: Color(0xFF1A3B89)),
                            onPressed: controller.isLoadingOrders.value
                                ? null
                                : controller.refreshOrders,
                            tooltip: 'Refresh Orders',
                          )),
                      // Search
                      _isSearchActive
                          ? _buildSearchField()
                          : IconButton(
                              icon: const Icon(Icons.search,
                                  color: Color(0xFF1A3B89)),
                              onPressed: () {
                                setState(() {
                                  _isSearchActive = true;
                                });
                              },
                            ),
                    ],
                  ),
                ],
              ),

              // Show loading or error state
              Obx(() {
                if (controller.isLoadingOrders.value &&
                    controller.recentOrders.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.orderError.value.isNotEmpty &&
                    controller.recentOrders.isEmpty) {
                  return _buildErrorWidget();
                }

                return const SizedBox.shrink();
              }),

              const SizedBox(height: 16),

              // Table Section
              Obx(() => isSmallScreen ? _buildListView() : _buildTable()),

              const SizedBox(height: 16),

              // Pagination
              Obx(() => _buildPagination()),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.orange.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            "Unable to load orders",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.orderError.value.length > 100
                ? "${controller.orderError.value.substring(0, 100)}..."
                : controller.orderError.value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.refreshOrders,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3B89),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search orders...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _isSearchActive = false;
                });
              },
            ),
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
            setState(() {
              _searchQuery = value;
              _currentPage = 0;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTable() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) < _filteredOrders.length
        ? startIndex + _rowsPerPage
        : _filteredOrders.length;
    final displayedOrders = _filteredOrders.sublist(startIndex, endIndex);

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
                  _tableHeaderCell("Order ID", 1.5),
                  _tableHeaderCell("Customer", 2),
                  _tableHeaderCell("Store", 2),
                  _tableHeaderCell("Driver", 1.5),
                  _tableHeaderCell("Total Amount", 1.5),
                  _tableHeaderCell("Date", 1.5),
                  _tableHeaderCell("Status", 1.5),
                ],
              ),
            ),
          ),

          // No results message
          if (displayedOrders.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                _filteredOrders.isEmpty && _searchQuery.isNotEmpty
                    ? "No orders found matching your search"
                    : "No recent orders available",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),

          // Table Body
          ...List.generate(
            displayedOrders.length,
            (index) {
              final order = displayedOrders[index];
              return Container(
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    _tableCell("#${order.id}", 1.5),
                    _tableCell(order.customerName, 2),
                    _tableCell(order.storeName, 2),
                    _tableCell(order.driverName, 1.5),
                    _tableCell(order.totalDisplay, 1.5),
                    _tableCell(_formatDate(order.createdAt), 1.5),
                    Expanded(
                      flex: 15,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.orderStatus),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            order.orderStatusDisplay,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _tableCell(String text, double flex) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) < _filteredOrders.length
        ? startIndex + _rowsPerPage
        : _filteredOrders.length;
    final displayedOrders = _filteredOrders.sublist(startIndex, endIndex);

    if (displayedOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text(
          _filteredOrders.isEmpty && _searchQuery.isNotEmpty
              ? "No orders found matching your search"
              : "No recent orders available",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      children: List.generate(
        displayedOrders.length,
        (index) {
          final order = displayedOrders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _listTile("Order ID", "#${order.id}"),
                  _listTile("Customer", order.customerName),
                  _listTile("Store", order.storeName),
                  _listTile("Driver", order.driverName),
                  _listTile("Total Amount", order.totalDisplay),
                  _listTile("Date", _formatDate(order.createdAt)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.orderStatus),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.orderStatusDisplay,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _listTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    final int totalPages = (_filteredOrders.length / _rowsPerPage).ceil();

    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous page button
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF1A3B89)),
            onPressed: _currentPage > 0
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
            style: IconButton.styleFrom(
              foregroundColor: const Color(0xFF1A3B89),
            ),
          ),

          // Page number indicators
          if (totalPages > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                totalPages > 4 ? 4 : totalPages,
                (index) {
                  int pageNum;
                  if (totalPages <= 4) {
                    pageNum = index;
                  } else if (_currentPage <= 1) {
                    pageNum = index;
                  } else if (_currentPage >= totalPages - 2) {
                    pageNum = totalPages - 4 + index;
                  } else {
                    pageNum = _currentPage - 1 + index;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentPage = pageNum;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage == pageNum
                            ? const Color(0xFF1A3B89)
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: const Size(40, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: const Color(0xFF1A3B89).withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: Text(
                        "${pageNum + 1}",
                        style: TextStyle(
                          color: _currentPage == pageNum
                              ? Colors.white
                              : const Color(0xFF1A3B89),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Next page button
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Color(0xFF1A3B89)),
            onPressed: _currentPage < totalPages - 1
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
            style: IconButton.styleFrom(
              foregroundColor: const Color(0xFF1A3B89),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  MaterialColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready_for_pickup':
        return Colors.teal;
      case 'on_delivery':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
    }
  }
}
