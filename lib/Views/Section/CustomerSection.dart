// lib/Views/Section/CustomerSection.dart
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
    // Load customers when widget initializes
    controller.loadCustomers();
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
        'Error: $e',
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
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.orange),
            onPressed: () async {
              await controller.diagnoseConnection();
            },
            tooltip: 'Debug API',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddNewCustomerScreen()),
                ).then((_) {
                  controller.refreshCustomers();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3B89),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Add Customer'),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Customer List",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A3B89),
                        ),
                      ),
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
                  const SizedBox(height: 16),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Loading customers...'),
                            ],
                          ),
                        );
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
                  const SizedBox(height: 16),
                  Obx(() {
                    if (!controller.isLoading.value) {
                      return _buildPagination();
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          );
        }),
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
            hintText: 'Search customers...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
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
            controller.searchCustomers(value);
          },
        ),
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
          const Text(
            "No customers found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? "Try adjusting your search criteria"
                : "Add your first customer to get started",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
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
            icon: const Icon(Icons.add),
            label: const Text('Add Customer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3B89),
              foregroundColor: Colors.white,
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
            "Error loading customers",
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => controller.refreshCustomers(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3B89),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => controller.diagnoseConnection(),
                icon: const Icon(Icons.bug_report),
                label: const Text('Diagnose'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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
                    _tableHeaderCell("Customer ID", 1),
                    _tableHeaderCell("Username", 2),
                    _tableHeaderCell("Email", 3),
                    _tableHeaderCell("Phone", 2),
                    _tableHeaderCell("Actions", 2),
                  ],
                ),
              ),
            ),
            if (customers.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                child: const Text(
                  "No customers found matching your search",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return Container(
                    decoration: BoxDecoration(
                      color:
                          index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
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
                        Expanded(
                          flex: 20,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Color(0xFF1A3B89)),
                                  onPressed: () {
                                    _navigateToEditCustomer(customer);
                                  },
                                  tooltip: "Edit Customer",
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _showDeleteConfirmation(customer);
                                  },
                                  tooltip: "Delete Customer",
                                ),
                              ],
                            ),
                          ),
                        ),
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
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Obx(() {
      final int totalPages = controller.totalPages.value;
      final int currentPage = controller.currentPage.value;

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
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Color(0xFF1A3B89)),
              onPressed: currentPage > 1
                  ? () {
                      controller.loadCustomers(page: currentPage - 1);
                    }
                  : null,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                totalPages > 4 ? 4 : totalPages,
                (index) {
                  int pageNum;
                  if (totalPages <= 4) {
                    pageNum = index + 1;
                  } else if (currentPage <= 2) {
                    pageNum = index + 1;
                  } else if (currentPage >= totalPages - 1) {
                    pageNum = totalPages - 3 + index;
                  } else {
                    pageNum = currentPage - 1 + index;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        controller.loadCustomers(page: pageNum);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentPage == pageNum
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
                        "$pageNum",
                        style: TextStyle(
                          color: currentPage == pageNum
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
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Color(0xFF1A3B89)),
              onPressed: currentPage < totalPages
                  ? () {
                      controller.loadCustomers(page: currentPage + 1);
                    }
                  : null,
            ),
          ],
        ),
      );
    });
  }

  void _showDeleteConfirmation(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text(
              "Are you sure you want to delete customer '${customer.displayName}'?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
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
                  _listTile("Customer ID", customer.id.toString()),
                  _listTile("Username", customer.displayName),
                  _listTile("Email", customer.displayEmail),
                  _listTile("Phone", customer.displayPhone),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Edit"),
                          onPressed: () {
                            _navigateToEditCustomer(customer);
                          },
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
                          onPressed: () {
                            _showDeleteConfirmation(customer);
                          },
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
