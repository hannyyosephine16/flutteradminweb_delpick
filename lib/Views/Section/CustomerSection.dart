import 'package:flutter/material.dart';
import 'package:delpick_admin/Views/Dashboard/CustomerDetail/EditCustomer.dart';
import 'package:delpick_admin/Views/Dashboard/CustomerDetail/AddCustomer.dart';
import '../../src/ApiService.dart';
import '../../src/CustomerService.dart';

class CustomerSection extends StatefulWidget {
  const CustomerSection({super.key});

  @override
  State<CustomerSection> createState() => CustomerSectionState();
}

class CustomerSectionState extends State<CustomerSection> {
  int _currentPage = 1;
  final int _rowsPerPage = 5;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchActive = false;
  List<dynamic> customers = [];
  int _totalItems = 0;
  int _totalPages = 1;
  bool _isLoading = false;

  // FIXED: Proper type handling and null safety
  Future<void> fetchCustomers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print(
          '🔄 Fetching customers - Page: $_currentPage, Limit: $_rowsPerPage');

      // Use named parameters
      final data = await CustomerService.getAllCustomers(
        page: _currentPage,
        limit: _rowsPerPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      print('📄 Fetched data structure: ${data?.runtimeType}');
      print('📋 Data keys: ${data?.keys ?? "null"}');

      // FIXED: Proper null safety and type handling
      if (data != null) {
        print('📦 Response data: $data');

        // Handle different response formats from backend
        if (data.containsKey('data') && data['data'] != null) {
          final dataField = data['data'];
          print('📊 Data field type: ${dataField.runtimeType}');
          print('📊 Data content: $dataField');

          // FIXED: Check if data field contains customers
          if (dataField is Map<String, dynamic> &&
              dataField.containsKey('customers')) {
            final customersList = dataField['customers'];

            if (customersList is List) {
              setState(() {
                customers = customersList;
                _totalItems =
                    (dataField['totalItems'] as int?) ?? customersList.length;
                _totalPages = (dataField['totalPages'] as int?) ?? 1;
                _currentPage =
                    (dataField['currentPage'] as int?) ?? _currentPage;
              });

              print(
                  '✅ Standard format - Processed ${customersList.length} customers');
              print('📈 Total items: $_totalItems, Total pages: $_totalPages');
            } else {
              print(
                  '⚠️  customers field is not a List: ${customersList.runtimeType}');
              throw Exception("'customers' field is not a List");
            }
          }
          // FIXED: Check if data field is directly a List (alternative format)
          else if (dataField is List) {
            setState(() {
              customers = dataField;
              _totalItems = dataField.length;
              _totalPages = (dataField.length / _rowsPerPage).ceil();
            });
            print(
                '✅ Direct List format - Processed ${dataField.length} customers');
          }
          // Check if data field is Map but has different structure
          else if (dataField is Map<String, dynamic>) {
            print('⚠️  Data is Map but does not contain customers array');
            print('📄 Available data keys: ${dataField.keys}');

            // Try to find customers in different possible keys
            List<dynamic>? customersList;
            if (dataField.containsKey('rows')) {
              customersList = dataField['rows'] as List<dynamic>?;
            } else if (dataField.containsKey('results')) {
              customersList = dataField['results'] as List<dynamic>?;
            } else if (dataField.containsKey('items')) {
              customersList = dataField['items'] as List<dynamic>?;
            }

            if (customersList != null) {
              setState(() {
                customers = customersList!;
                _totalItems = (dataField['totalItems'] as int?) ??
                    (dataField['count'] as int?) ??
                    customersList.length;
                _totalPages = (dataField['totalPages'] as int?) ??
                    (((_totalItems / _rowsPerPage).ceil()));
              });
              print(
                  '✅ Alternative format - Processed ${customersList.length} customers');
            } else {
              throw Exception(
                  "No recognizable customer data found in response");
            }
          } else {
            throw Exception(
                "Unexpected data field type: ${dataField.runtimeType}");
          }
        }
        // FIXED: Check if response directly contains customers (no 'data' wrapper)
        else if (data.containsKey('customers')) {
          final customersList = data['customers'];

          if (customersList is List) {
            setState(() {
              customers = customersList;
              _totalItems =
                  (data['totalItems'] as int?) ?? customersList.length;
              _totalPages = (data['totalPages'] as int?) ?? 1;
              _currentPage = (data['currentPage'] as int?) ?? _currentPage;
            });
            print(
                '✅ Direct customers format - Processed ${customersList.length} customers');
          } else {
            throw Exception(
                "'customers' field is not a List: ${customersList.runtimeType}");
          }
        }
        // FIXED: Check if response is directly a List
        else if (data is List) {
          setState(() {
            customers = data;
            _totalItems = data.length;
            _totalPages = (data.length / _rowsPerPage).ceil();
          });
          print('✅ Direct array response - Processed ${data.length} customers');
        } else {
          print('❌ Unexpected response format');
          print('📄 Available keys: ${data.keys}');
          print('📄 Full response: $data');
          throw Exception(
              "Invalid response format - no recognizable customer data structure found");
        }
      } else {
        throw Exception("No response data received from server");
      }
    } catch (e) {
      print('❌ Error in fetchCustomers: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching customers: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => fetchCustomers(),
            ),
          ),
        );
      }

      // Set empty state on error
      setState(() {
        customers = [];
        _totalItems = 0;
        _totalPages = 1;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Delete customer implementation
  Future<void> _deleteCustomer(String customerId) async {
    if (customerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid customer ID')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      print('🗑️ Deleting customer: $customerId');

      final success = await CustomerService.deleteCustomer(customerId);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Refresh the list after successful deletion
        await fetchCustomers();
      } else {
        throw Exception('Delete operation failed');
      }
    } catch (e) {
      print('❌ Error deleting customer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting customer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // FIXED: Safe filtering with null checks
  List<dynamic> get _filteredCustomers {
    if (_searchQuery.isEmpty) {
      return customers;
    }

    return customers.where((customer) {
      if (customer == null) return false;

      // Safe access to customer data with null checks
      final name = customer["name"]?.toString().toLowerCase() ?? '';
      final email = customer["email"]?.toString().toLowerCase() ?? '';
      final phone = customer["phone"]?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return name.contains(query) ||
          email.contains(query) ||
          phone.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchCustomers().then((_) {
      print('Initial fetch completed. Customers: ${customers.length}');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Navigate to edit customer screen with proper error handling
  void _navigateToEditCustomer(dynamic customer) {
    try {
      if (customer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer data is null')),
        );
        return;
      }

      // Convert customer ID to string to ensure compatibility
      String customerId = customer["id"]?.toString() ?? '';

      if (customerId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer ID not found')),
        );
        return;
      }

      print('📝 Navigating to edit customer with ID: $customerId');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditCustomerScreen(
            customerId: customerId,
          ),
        ),
      ).then((_) {
        // Refresh the data when returning from edit screen
        print('🔄 Returned from edit screen, refreshing data');
        fetchCustomers();
      });
    } catch (e) {
      print('❌ Error navigating to edit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
          // Debug button for testing API connection
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.orange),
            onPressed: () async {
              await CustomerService.debugApiConnection();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Check console for debug info')),
                );
              }
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
                  // Refresh the data when returning from add screen
                  fetchCustomers();
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
                  // Header with title and search button/field
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

                  // Loading indicator or content
                  _isLoading
                      ? const Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Loading customers...'),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child:
                              isSmallScreen ? _buildListView() : _buildTable(),
                        ),

                  const SizedBox(height: 16),

                  // Pagination
                  if (!_isLoading) _buildPagination(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // Search bar
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
              _currentPage = 1; // Reset to first page when searching
            });
          },
        ),
      ),
    );
  }

  // Table to display customers
  Widget _buildTable() {
    final displayedCustomers = _filteredCustomers;

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
                  _tableHeaderCell("Customer ID", 1),
                  _tableHeaderCell("Username", 2),
                  _tableHeaderCell("Email", 3),
                  _tableHeaderCell("Phone", 2),
                  _tableHeaderCell("Actions", 2),
                ],
              ),
            ),
          ),

          // No results message
          if (displayedCustomers.isEmpty)
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

          // Table Body
          Expanded(
            child: ListView.builder(
              itemCount: displayedCustomers.length,
              itemBuilder: (context, index) {
                final customer = displayedCustomers[index];
                return Container(
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      _tableCell(customer["id"]?.toString() ?? '-', 1),
                      _tableCell(customer["name"]?.toString() ?? '-', 2),
                      _tableCell(customer["email"]?.toString() ?? '-', 3),
                      _tableCell(customer["phone"]?.toString() ?? '-', 2),
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
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _showDeleteConfirmation(
                                      customer["id"]?.toString() ?? '');
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
    final int totalPages = _totalPages;
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
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                    fetchCustomers();
                  }
                : null,
          ),

          // Page number indicators
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              totalPages > 4 ? 4 : totalPages,
              (index) {
                int pageNum;
                if (totalPages <= 4) {
                  pageNum = index + 1;
                } else if (_currentPage <= 2) {
                  pageNum = index + 1;
                } else if (_currentPage >= totalPages - 1) {
                  pageNum = totalPages - 3 + index;
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
                      fetchCustomers();
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
                      "$pageNum",
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
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                    fetchCustomers();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  // Delete confirmation with proper string handling
  void _showDeleteConfirmation(String customerId) {
    if (customerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer ID not found')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content:
              Text("Are you sure you want to delete customer #$customerId?"),
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
                _deleteCustomer(customerId);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildListView() {
    final displayedCustomers = _filteredCustomers;

    if (displayedCustomers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: const Text(
          "No customers found matching your search",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: displayedCustomers.length,
      itemBuilder: (context, index) {
        final customer = displayedCustomers[index];
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
                _listTile("Customer ID", customer["id"]?.toString() ?? '-'),
                _listTile("Username", customer["name"]?.toString() ?? '-'),
                _listTile("Email", customer["email"]?.toString() ?? '-'),
                _listTile("Phone", customer["phone"]?.toString() ?? '-'),
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
                          _showDeleteConfirmation(
                              customer["id"]?.toString() ?? '');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
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
