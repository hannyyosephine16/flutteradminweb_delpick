// CustomerSection.dart dengan debug tools untuk mendiagnosa masalah data
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delpick_admin/Views/Dashboard/CustomerDetail/EditCustomer.dart';
import 'package:delpick_admin/Views/Dashboard/CustomerDetail/AddCustomer.dart';
import '../../UserControls/CustomerController.dart';
import '../../Models/CustomerModel.dart';

class CustomerSection extends StatefulWidget {
  const CustomerSection({super.key});

  @override
  State<CustomerSection> createState() => CustomerSectionState();
}

class CustomerSectionState extends State<CustomerSection> {
  final CustomerController controller = Get.put(CustomerController());
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    print('🔧 CustomerSection initState');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadCustomers(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToEditCustomer(CustomerModel customer) {
    try {
      print('📝 Navigating to edit customer with ID: ${customer.id}');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditCustomerScreen(
            customerId: customer.id.toString(),
          ),
        ),
      ).then((_) {
        print('🔄 Returned from edit screen, refreshing data');
        controller.refreshCustomers();
      });
    } catch (e) {
      print('❌ Error navigating to edit: $e');
      Get.snackbar(
        'Error',
        'Navigation error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customer Management',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          // // ✅ ENHANCED DEBUG TOOLS - More prominent
          // Container(
          //   margin: const EdgeInsets.symmetric(horizontal: 4.0),
          //   child: ElevatedButton.icon(
          //     onPressed: () async {
          //       print('🐛 === MANUAL DEBUG TRIGGERED ===');
          //       await controller.debugCustomerData();
          //     },
          //     icon: const Icon(Icons.bug_report, size: 18),
          //     label: const Text('Debug API'),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.orange,
          //       foregroundColor: Colors.white,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8.0),
          //       ),
          //       padding:
          //           const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //     ),
          //   ),
          // ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                print('🔄 === MANUAL REFRESH TRIGGERED ===');
                await controller.refreshCustomers();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          // Container(
          //   margin: const EdgeInsets.symmetric(horizontal: 4.0),
          //   child: ElevatedButton.icon(
          //     onPressed: () async {
          //       print('🔬 === CONNECTION TEST TRIGGERED ===');
          //       await controller.testConnection();
          //     },
          //     icon: const Icon(Icons.healing, size: 18),
          //     label: const Text('Test'),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.green,
          //       foregroundColor: Colors.white,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8.0),
          //       ),
          //       padding:
          //           const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //     ),
          //   ),
          // ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddNewCustomerScreen()),
                ).then((_) {
                  controller.refreshCustomers();
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Customer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3B89),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
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
                  // ✅ ENHANCED DEBUG INFO
                  // _buildDebugInfo(),
                  // const SizedBox(height: 12),

                  // ✅ HEADER WITH STATUS INFO
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // ✅ MAIN CONTENT
                  Expanded(
                    child: Obx(() {
                      print(
                          '🔄 UI Rebuild - Loading: ${controller.isLoading.value}, Error: ${controller.hasError.value}, Customers: ${controller.customers.length}');

                      if (controller.isLoading.value) {
                        return _buildLoadingState();
                      }

                      if (controller.hasError.value) {
                        return _buildErrorState();
                      }

                      if (controller.isEmpty) {
                        return _buildEmptyState();
                      }

                      return isSmallScreen ? _buildListView() : _buildTable();
                    }),
                  ),

                  // ✅ FOOTER WITH PAGINATION AND STATS
                  _buildFooter(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ✅ NEW: DEBUG INFO PANEL
  Widget _buildDebugInfo() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Debug Info',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Live Status',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _debugInfoItem(
                      'Loading',
                      controller.isLoading.value.toString(),
                      controller.isLoading.value
                          ? Colors.orange
                          : Colors.green),
                  _debugInfoItem(
                      'Has Error',
                      controller.hasError.value.toString(),
                      controller.hasError.value ? Colors.red : Colors.green),
                  _debugInfoItem(
                      'Customers Count',
                      controller.customers.length.toString(),
                      controller.customers.length > 0
                          ? Colors.green
                          : Colors.orange),
                  _debugInfoItem('Total Items',
                      controller.totalItems.value.toString(), Colors.blue),
                  _debugInfoItem('Current Page',
                      controller.currentPage.value.toString(), Colors.blue),
                  _debugInfoItem(
                      'Search Query',
                      controller.searchQuery.value.isEmpty
                          ? 'None'
                          : controller.searchQuery.value,
                      Colors.purple),
                ],
              ),
              if (controller.hasError.value) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Error: ${controller.errorMessage.value}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ));
  }

  Widget _debugInfoItem(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ✅ IMPROVED HEADER WITH SEARCH AND STATUS
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Customer Management",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A3B89),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        _getStatusMessage(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                ],
              ),
            ),
            _isSearchActive ? _buildSearchField() : _buildSearchButton(),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatsBar(),
      ],
    );
  }

  Widget _buildSearchButton() {
    return IconButton(
      icon: const Icon(Icons.search, color: Color(0xFF1A3B89)),
      onPressed: () {
        setState(() {
          _isSearchActive = true;
        });
      },
      tooltip: 'Search Customers',
    );
  }

  Widget _buildSearchField() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by name, email, or phone...',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _isSearchActive = false;
                });
                controller.clearSearch();
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
            if (value.length > 2 || value.isEmpty) {
              controller.searchCustomers(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Obx(() {
      if (controller.customers.isEmpty && !controller.isLoading.value) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A3B89).withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1A3B89).withOpacity(0.1)),
        ),
        child: Row(
          children: [
            _buildStatItem(
                Icons.people, 'Total', controller.totalItems.value.toString()),
            const SizedBox(width: 24),
            _buildStatItem(Icons.visibility, 'Showing',
                controller.customers.length.toString()),
            const SizedBox(width: 24),
            _buildStatItem(Icons.pages, 'Page',
                '${controller.currentPage.value}/${controller.totalPages.value}'),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1A3B89)),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3B89),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A3B89)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading customers...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            "Error Loading Customers",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                controller.errorMessage.value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              )),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => controller.refreshCustomers(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3B89),
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => controller.debugCustomerData(),
                icon: const Icon(Icons.bug_report, size: 18),
                label: const Text('Debug'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => controller.testConnection(),
                icon: const Icon(Icons.healing, size: 18),
                label: const Text('Test'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? "No customers found"
                : "No customers yet",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? "Try different search terms or clear the search"
                : "Add your first customer to get started",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // ✅ ENHANCED DEBUG BUTTON IN EMPTY STATE
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => controller.debugCustomerData(),
                icon: const Icon(Icons.bug_report, size: 18),
                label: const Text('Debug API Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddNewCustomerScreen()),
                  ).then((_) {
                    controller.refreshCustomers();
                  });
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3B89),
                  foregroundColor: Colors.white,
                ),
              ),
              if (controller.searchQuery.value.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _isSearchActive = false;
                    });
                    controller.clearSearch();
                  },
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Obx(() {
      final customers = controller.customers;
      print('🔄 Building table with ${customers.length} customers');

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
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
                    _tableHeaderCell("ID", 1),
                    _tableHeaderCell("Name", 2),
                    _tableHeaderCell("Email", 3),
                    _tableHeaderCell("Phone", 2),
                    _tableHeaderCell("Joined", 2),
                    _tableHeaderCell("Actions", 2),
                  ],
                ),
              ),
            ),
            Expanded(
              child: customers.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: const Text(
                        "No customers match your criteria",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: index % 2 == 0
                                ? Colors.grey.shade50
                                : Colors.white,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              _tableCell(customer.id.toString(), 1),
                              _tableCell(customer.displayName, 2),
                              _tableCell(customer.displayEmail, 3),
                              _tableCell(customer.displayPhone, 2),
                              _tableCell(customer.registeredDate, 2),
                              _tableActionCell(customer),
                            ],
                          ),
                        );
                      },
                    ),
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
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _tableActionCell(CustomerModel customer) {
    return Expanded(
      flex: 20,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF1A3B89), size: 18),
              onPressed: () => _navigateToEditCustomer(customer),
              tooltip: "Edit Customer",
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
              onPressed: () => _showDeleteConfirmation(customer),
              tooltip: "Delete Customer",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Obx(() {
      final customers = controller.customers;

      if (customers.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
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
                  _listTile("ID", customer.id.toString()),
                  _listTile("Name", customer.displayName),
                  _listTile("Email", customer.displayEmail),
                  _listTile("Phone", customer.displayPhone),
                  _listTile("Joined", customer.registeredDate),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Edit"),
                          onPressed: () => _navigateToEditCustomer(customer),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3B89),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text("Delete"),
                          onPressed: () => _showDeleteConfirmation(customer),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Obx(() {
      if (controller.isLoading.value || controller.totalPages.value <= 1) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(top: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            _buildPaginationControls(),
          ],
        ),
      );
    });
  }

  Widget _buildPaginationControls() {
    return Obx(() {
      final int totalPages = controller.totalPages.value;
      final int currentPage = controller.currentPage.value;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1
                ? () => controller.loadCustomers(page: currentPage - 1)
                : null,
            color: const Color(0xFF1A3B89),
          ),
          ...List.generate(
            totalPages > 5 ? 5 : totalPages,
            (index) {
              int pageNum;
              if (totalPages <= 5) {
                pageNum = index + 1;
              } else if (currentPage <= 3) {
                pageNum = index + 1;
              } else if (currentPage >= totalPages - 2) {
                pageNum = totalPages - 4 + index;
              } else {
                pageNum = currentPage - 2 + index;
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: ElevatedButton(
                  onPressed: () => controller.loadCustomers(page: pageNum),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentPage == pageNum
                        ? const Color(0xFF1A3B89)
                        : Colors.white,
                    foregroundColor: currentPage == pageNum
                        ? Colors.white
                        : const Color(0xFF1A3B89),
                    minimumSize: const Size(36, 36),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(
                        color: const Color(0xFF1A3B89).withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Text("$pageNum", style: const TextStyle(fontSize: 12)),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () => controller.loadCustomers(page: currentPage + 1)
                : null,
            color: const Color(0xFF1A3B89),
          ),
        ],
      );
    });
  }

  void _showDeleteConfirmation(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Are you sure you want to delete this customer?"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: ${customer.displayName}"),
                    Text("Email: ${customer.displayEmail}"),
                    Text("ID: ${customer.id}"),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  const Text("Delete", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteCustomer(customer.id.toString());
              },
            ),
          ],
        );
      },
    );
  }

  String _getStatusMessage() {
    if (controller.isLoading.value) {
      return 'Loading customers...';
    }
    if (controller.hasError.value) {
      return 'Error: ${controller.errorMessage.value}';
    }
    if (controller.isEmpty) {
      return controller.searchQuery.value.isNotEmpty
          ? 'No customers found for "${controller.searchQuery.value}"'
          : 'No customers yet';
    }
    return 'Showing ${controller.customers.length} of ${controller.totalItems.value} customers';
  }

  Color _getStatusColor() {
    if (controller.isLoading.value) {
      return Colors.blue;
    }
    if (controller.hasError.value) {
      return Colors.red;
    }
    if (controller.isEmpty) {
      return Colors.orange;
    }
    return Colors.green;
  }
}
