import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:delpick_admin/Views/Dashboard/CustomerDetail/EditCustomer.dart';
import 'package:delpick_admin/Views/Dashboard/CustomerDetail/addcustomer.dart';

class CustomerSection extends StatefulWidget {
  const CustomerSection({super.key});

  @override
  State<CustomerSection> createState() => CustomerSectionState();
}

class CustomerSectionState extends State<CustomerSection> {
  static const String baseUrl = 'https://delpick.fun/api/v1';

  // Pagination
  int _currentPage = 0;
  final int _rowsPerPage = 5;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchActive = false;

  // Customer data
  List<Customer> customers = [];

  // Dummy data untuk sementara
  final List<Map<String, dynamic>> _allCustomers = List.generate(
    20,
        (index) => {
      "id": index + 1,
      "username": ["John", "Rifqi", "Yefta", "Haikal", "Miranda", "Chairiansyah",
        "Dimas", "Maya", "Putri", "Budi", "Sofyan", "Anisa", "Galih",
        "Reza", "Dewi", "Sarah", "Rizki", "Ayu", "Joko", "Rina"][index % 20],
      "email": ["john@gmail.com", "rifqi@gmail.com", "yefta@gmail.com",
        "haikal@gmail.com", "miranda@gmail.com", "chairiansyah@gmail.com",
        "dimas@gmail.com", "maya@gmail.com", "putri@gmail.com",
        "budi@gmail.com", "sofyan@gmail.com", "anisa@gmail.com",
        "galih@gmail.com", "reza@gmail.com", "dewi@gmail.com",
        "sarah@gmail.com", "rizki@gmail.com", "ayu@gmail.com",
        "joko@gmail.com", "rina@gmail.com"][index % 20],
      "phone": ["0821345678${index % 10}", "0821345679${index % 10}", "0821345670${index % 10}",
        "0821345671${index % 10}", "0821345672${index % 10}", "0821345673${index % 10}",
        "0821345674${index % 10}", "0821345675${index % 10}", "0821345676${index % 10}",
        "0821345677${index % 10}", "0821345678${index % 10}", "0821345679${index % 10}",
        "0821345670${index % 10}", "0821345671${index % 10}", "0821345672${index % 10}",
        "0821345673${index % 10}", "0821345674${index % 10}", "0821345675${index % 10}",
        "0821345676${index % 10}", "0821345677${index % 10}"][index % 20],
    },
  );

  List<Map<String, dynamic>> get _filteredCustomers {
    if (_searchQuery.isEmpty) {
      return _allCustomers;
    }

    return _allCustomers.where((customer) {
      return customer["username"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer["email"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer["phone"].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // API call
  Future<void> fetchCustomers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/customers'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          customers = data.map((json) => Customer.fromJson(json)).toList();
        });
      } else {
        // Handle error silently for now
        // In production, you might want to show a snackbar or some other UI feedback
      }
    } catch (e) {
      // Handle exception silently
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCustomers();
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
          'Customer Management',
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
                  MaterialPageRoute(builder: (context) => AddNewCustomerScreen()),
                );
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
        child: LayoutBuilder(
            builder: (context, constraints) {
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
                            icon: const Icon(Icons.search, color: Color(0xFF1A3B89)),
                            onPressed: () {
                              setState(() {
                                _isSearchActive = true;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Table/List Section based on screen size
                      Expanded(
                        child: isSmallScreen
                            ? _buildListView()
                            : _buildTable(),
                      ),

                      const SizedBox(height: 16),

                      // Pagination
                      _buildPagination(),
                    ],
                  ),
                ),
              );
            }
        ),
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
                  _searchQuery = '';
                  _isSearchActive = false;
                });
              },
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Color(0xFF1A3B89), width: 2.0),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _currentPage = 0; // Reset to first page when searching
            });
          },
        ),
      ),
    );
  }

  Widget _buildTable() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) < _filteredCustomers.length
        ? startIndex + _rowsPerPage
        : _filteredCustomers.length;
    final displayedCustomers = _filteredCustomers.sublist(
        startIndex,
        endIndex
    );

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
                      _tableCell(customer["id"].toString(), 1),
                      _tableCell(customer["username"], 2),
                      _tableCell(customer["email"], 3),
                      _tableCell(customer["phone"], 2),
                      Expanded(
                        flex: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF1A3B89)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditCustomerScreen(),
                                    ),
                                  );
                                },
                                tooltip: "Edit Customer",
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _showDeleteConfirmation(customer["id"]);
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

  Widget _buildListView() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) < _filteredCustomers.length
        ? startIndex + _rowsPerPage
        : _filteredCustomers.length;
    final displayedCustomers = _filteredCustomers.sublist(
        startIndex,
        endIndex
    );

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
                _listTile("Customer ID", customer["id"].toString()),
                _listTile("Username", customer["username"]),
                _listTile("Email", customer["email"]),
                _listTile("Phone", customer["phone"]),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text("Edit"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCustomerScreen(),
                            ),
                          );
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
                          _showDeleteConfirmation(customer["id"]);
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

  Widget _buildPagination() {
    // Calculate total pages based on filtered results
    final int totalPages = (_filteredCustomers.length / _rowsPerPage).ceil();

    // If no results, don't show pagination
    if (totalPages == 0) {
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
                  // Calculate which page numbers to show
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

  void _showDeleteConfirmation(int customerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text("Are you sure you want to delete customer #$customerId?"),
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
              child: const Text("Delete", style: TextStyle(color: Colors.white)),
              onPressed: () {
                // Implementasikan logika delete di sini
                // deleteCustomer(customerId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// Model untuk Customer
class Customer {
  final int id;
  final String username;
  final String email;
  final String phone;

  Customer({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
  });

  // Method untuk mengonversi JSON menjadi objek Customer
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}