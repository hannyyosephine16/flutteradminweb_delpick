import 'package:flutter/material.dart';
import 'package:delpick_admin/Views/Dashboard/CustomerDetail/EditCustomer.dart';
import 'package:delpick_admin/Views/Dashboard/CustomerDetail/AddCustomer.dart';
import '../../src/ApiService.dart';

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

  // Fetch customers using ApiService
  Future<void> fetchCustomers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get customers data
      final data = await ApiService.getAllCustomers(_currentPage, _rowsPerPage);

      print('Fetched data structure: ${data.runtimeType}');
      print('Data keys: ${data.keys}');

      // Check the exact structure that's coming back
      if (data != null && data['data'] != null) {
        // Inspect what's in the data['data'] field
        print('Data content: ${data['data']}');

        if (data['data']['customers'] != null) {
          setState(() {
            customers = data['data']['customers'];
            _totalItems = data['data']['totalItems'] ?? 0;
            _totalPages = data['data']['totalPages'] ?? 1;
            _currentPage = data['data']['currentPage'] ?? 1;
          });
          print('Processed customers: $customers');
        } else {
          // If 'customers' key doesn't exist, try to find the actual data
          setState(() {
            // Adjust based on your actual API response structure
            if (data['data']['customers'] is List) {
              customers = data['data']['customers'];
            } else if (data['data']['rows'] != null) {
              customers = data['data']['customers']['rows'];
            }
            _totalItems = data['data']['count'] ?? 0;
            _totalPages = ((_totalItems / _rowsPerPage).ceil()).toInt();
          });
        }
      } else {
        throw Exception("Invalid response data format");
      }
    } catch (e) {
      print('Error in fetchCustomers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching customers: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Get filtered customers based on search query
  List<dynamic> get _filteredCustomers {
    if (_searchQuery.isEmpty) {
      return customers;
    }

    return customers.where((customer) {
      return customer["name"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer["email"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer["phone"].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchCustomers().then((_) {
      print('Fetched customers: $customers');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Handle navigation to edit customer screen
  void _navigateToEditCustomer(dynamic customer) {
    // Convert customer ID to string to ensure compatibility
    String customerId = customer["id"].toString();

    print('Navigating to edit customer with ID: $customerId');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCustomerScreen(
          customerId: customerId,
        ),
      ),
    ).then((_) {
      // Refresh the data when returning from edit screen
      print('Returned from edit screen, refreshing data');
      fetchCustomers();
    });
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
                      _isLoading
                          ? const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                          : Expanded(
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
                      _tableCell(customer["id"].toString(), 1),
                      _tableCell(customer["name"], 2),
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
                                  _navigateToEditCustomer(customer);
                                },
                                tooltip: "Edit Customer",
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _showDeleteConfirmation(customer["id"].toString());
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

  void _showDeleteConfirmation(String customerId) {
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
                // Implement logic to delete customer
                Navigator.of(context).pop();
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
                _listTile("Customer ID", customer["id"].toString()),
                _listTile("Username", customer["name"]),
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
                          _showDeleteConfirmation(customer["id"].toString());
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

// import 'package:flutter/material.dart';
// import 'package:delpick_admin/Views/Dashboard/CustomerDetail/EditCustomer.dart';
// import 'package:delpick_admin/Views/Dashboard/CustomerDetail/AddCustomer.dart';
// import 'dart:math' as math;
// import '../../src/ApiService.dart';
//
// class CustomerSection extends StatefulWidget {
//   const CustomerSection({super.key});
//
//   @override
//   State<CustomerSection> createState() => CustomerSectionState();
// }
//
// class CustomerSectionState extends State<CustomerSection> {
//   int _currentPage = 1;
//   final int _rowsPerPage = 5;
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   bool _isSearchActive = false;
//   List<dynamic> customers = [];
//   int _totalItems = 0;
//   int _totalPages = 1;
//   bool isLoading = false;
//
//   // Fetch customers using ApiService
//   Future<void> fetchCustomers() async {
//     try {
//       setState(() {
//         // Show loading indicator if needed
//       });
//
//       // Get customers data
//       final data = await ApiService.getAllCustomers(_currentPage, _rowsPerPage);
//
//       print('Fetched data structure: ${data.runtimeType}');
//       print('Data keys: ${data.keys}');
//
//       // Check the exact structure that's coming back
//       if (data != null && data['data'] != null) {
//         // Inspect what's in the data['data'] field
//         print('Data content: ${data['data']}');
//
//         if (data['data']['customers'] != null) {
//           setState(() {
//             customers = data['data']['customers'];
//             _totalItems = data['data']['totalItems'] ?? 0;
//             _totalPages = data['data']['totalPages'] ?? 1;
//             _currentPage = data['data']['currentPage'] ?? 1;
//           });
//           print('Processed customers: $customers');
//         } else {
//           // If 'customers' key doesn't exist, try to find the actual data
//           setState(() {
//             // Adjust based on your actual API response structure
//             if (data['data']['customers'] is List) {
//               customers = data['data']['customers'];
//             } else if (data['data']['rows'] != null) {
//               customers = data['data']['customers']['rows'];
//             }
//             _totalItems = data['data']['count'] ?? 0;
//             _totalPages = ((_totalItems / _rowsPerPage).ceil()).toInt();          });
//         }
//       } else {
//         throw Exception("Invalid response data format");
//       }
//     } catch (e) {
//       print('Error in fetchCustomers: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching customers: $e')),
//       );
//     }
//   }
//   // Get filtered customers based on search query
//   List<dynamic> get _filteredCustomers {
//     if (_searchQuery.isEmpty) {
//       return customers;
//     }
//
//     return customers.where((customer) {
//       return customer["name"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           customer["email"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           customer["phone"].toLowerCase().contains(_searchQuery.toLowerCase());
//     }).toList();
//   }
//
//
//   //delete customer
//   Future<void> _deleteCustomer(String customerId) async {
//     try {
//       setState(() {
//         isLoading = true;
//       });
//
//       // Implement your delete API call here
//       // Example: await ApiService.deleteCustomer(customerId);
//
//       // After successful deletion, refresh the list
//       await fetchCustomers();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Customer deleted successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting customer: $e')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchCustomers().then((_) {
//       print('Fetched customers: $customers');
//     });
//   }
//
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Customer Management',
//           style: TextStyle(color: Colors.black),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 1,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => AddNewCustomerScreen()),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1A3B89),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//               ),
//               child: const Text('Add Customer'),
//             ),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: LayoutBuilder(
//             builder: (context, constraints) {
//               final bool isSmallScreen = constraints.maxWidth < 800;
//
//               return Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Header with title and search button/field
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             "Customer List",
//                             style: TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF1A3B89),
//                             ),
//                           ),
//                           _isSearchActive
//                               ? _buildSearchField()
//                               : IconButton(
//                             icon: const Icon(Icons.search, color: Color(0xFF1A3B89)),
//                             onPressed: () {
//                               setState(() {
//                                 _isSearchActive = true;
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//
//                       // Table/List Section based on screen size
//                       Expanded(
//                         child: isSmallScreen
//                             ? _buildListView()
//                             : _buildTable(),
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       // Pagination
//                       _buildPagination(),
//                     ],
//                   ),
//                 ),
//               );
//             }
//         ),
//       ),
//     );
//   }
//
//   // Search bar
//   Widget _buildSearchField() {
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.only(left: 16.0),
//         child: TextField(
//           controller: _searchController,
//           decoration: InputDecoration(
//             hintText: 'Search customers...',
//             suffixIcon: IconButton(
//               icon: const Icon(Icons.close),
//               onPressed: () {
//                 setState(() {
//                   _searchController.clear();
//                   _searchQuery = '';
//                   _isSearchActive = false;
//                 });
//               },
//             ),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: const BorderSide(color: Color(0xFF1A3B89), width: 2.0),
//             ),
//           ),
//           onChanged: (value) {
//             setState(() {
//               _searchQuery = value;
//               _currentPage = 1; // Reset to first page when searching
//             });
//           },
//         ),
//       ),
//     );
//   }
//
//   // Table to display customers
//   Widget _buildTable() {
//     final displayedCustomers = _filteredCustomers;
//
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         children: [
//           // Header Row with gradient
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF1A3B89), Color(0xFF2A5CAA)],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(8),
//                 topRight: Radius.circular(8),
//               ),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12.0),
//               child: Row(
//                 children: [
//                   _tableHeaderCell("Customer ID", 1),
//                   _tableHeaderCell("Username", 2),
//                   _tableHeaderCell("Email", 3),
//                   _tableHeaderCell("Phone", 2),
//                   _tableHeaderCell("Actions", 2),
//                 ],
//               ),
//             ),
//           ),
//
//           // No results message
//           if (displayedCustomers.isEmpty)
//             Container(
//               padding: const EdgeInsets.all(24),
//               alignment: Alignment.center,
//               child: const Text(
//                 "No customers found matching your search",
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                 ),
//               ),
//             ),
//
//           // Table Body
//           Expanded(
//             child: ListView.builder(
//               itemCount: displayedCustomers.length,
//               itemBuilder: (context, index) {
//                 final customer = displayedCustomers[index];
//                 return Container(
//                   decoration: BoxDecoration(
//                     color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
//                     border: Border(
//                       bottom: BorderSide(color: Colors.grey.shade200),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       _tableCell(customer["id"].toString(), 1),
//                       _tableCell(customer["name"], 2),
//                       _tableCell(customer["email"], 3),
//                       _tableCell(customer["phone"], 2),
//                       Expanded(
//                         flex: 20,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.edit, color: Color(0xFF1A3B89)),
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => EditCustomerScreen(customerId: '',),
//                                     ),
//                                   );
//                                 },
//                                 tooltip: "Edit Customer",
//                               ),
//                               const SizedBox(width: 8),
//                               IconButton(
//                                 icon: const Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () {
//                                   _showDeleteConfirmation(customer["id"]);
//                                 },
//                                 tooltip: "Delete Customer",
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _tableHeaderCell(String text, double flex) {
//     return Expanded(
//       flex: (flex * 10).toInt(),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//         child: Text(
//           text,
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _tableCell(String text, double flex) {
//     return Expanded(
//       flex: (flex * 10).toInt(),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Text(
//           text,
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             fontSize: 13,
//             color: Colors.black87,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPagination() {
//     // final int totalPages = (_filteredCustomers.length / _rowsPerPage).ceil();
//     final int totalPages = _totalPages;
//     if (totalPages == 0) {
//       return const SizedBox.shrink();
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         color: Colors.grey.shade50,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Previous page button
//           IconButton(
//             icon: const Icon(Icons.chevron_left, color: Color(0xFF1A3B89)),
//             onPressed: _currentPage > 1
//                 ? () {
//               setState(() {
//                 _currentPage--;
//               });
//               fetchCustomers();
//             }
//                 : null,
//           ),
//
//           // Page number indicators
//           if (totalPages > 0)
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: List.generate(
//                 totalPages > 4 ? 4 : totalPages,
//                     (index) {
//                   int pageNum;
//                   if (totalPages <= 4) {
//                     pageNum = index;
//                   } else if (_currentPage <= 1) {
//                     pageNum = index;
//                   } else if (_currentPage >= totalPages - 2) {
//                     pageNum = totalPages - 4 + index;
//                   } else {
//                     pageNum = _currentPage - 1 + index;
//                   }
//
//                   return Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 4),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           _currentPage = pageNum;
//                         });
//                         fetchCustomers();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _currentPage == pageNum
//                             ? const Color(0xFF1A3B89)
//                             : Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         minimumSize: const Size(40, 40),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           side: BorderSide(
//                             color: const Color(0xFF1A3B89).withOpacity(0.3),
//                           ),
//                         ),
//                       ),
//                       child: Text(
//                         "${pageNum + 1}",
//                         style: TextStyle(
//                           color: _currentPage == pageNum
//                               ? Colors.white
//                               : const Color(0xFF1A3B89),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//
//           // Next page button
//           IconButton(
//             icon: const Icon(Icons.chevron_right, color: Color(0xFF1A3B89)),
//             onPressed: _currentPage < totalPages
//                 ? () {
//               setState(() {
//                 _currentPage++;
//               });
//               fetchCustomers();
//             }
//                 : null,
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showDeleteConfirmation(int customerId) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Confirm Delete"),
//           content: Text("Are you sure you want to delete customer #$customerId?"),
//           actions: [
//             TextButton(
//               child: const Text("Cancel"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//               ),
//               child: const Text("Delete", style: TextStyle(color: Colors.white)),
//               onPressed: () {
//                 // Implement logic to delete customer
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildListView() {
//     final startIndex = (_currentPage - 1) * _rowsPerPage;
//     final endIndex = (startIndex + _rowsPerPage) < _filteredCustomers.length
//         ? startIndex + _rowsPerPage
//         : _filteredCustomers.length;
//     final displayedCustomers = _filteredCustomers.sublist(startIndex, endIndex);
//
//     if (displayedCustomers.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(24),
//         alignment: Alignment.center,
//         child: const Text(
//           "No customers found matching your search",
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.grey,
//           ),
//         ),
//       );
//     }
//
//     return ListView.builder(
//       itemCount: displayedCustomers.length,
//       itemBuilder: (context, index) {
//         final customer = displayedCustomers[index];
//         return Card(
//           margin: const EdgeInsets.only(bottom: 12),
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//             side: BorderSide(color: Colors.grey.shade200),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               children: [
//                 // Make sure that you're accessing customer data correctly
//                 _listTile("Customer ID", customer["id"].toString()),  // Ensure it's a string
//                 _listTile("Username", customer["name"]), // Or adjust to the actual field name
//                 _listTile("Email", customer["email"]),
//                 _listTile("Phone", customer["phone"]),
//
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         icon: const Icon(Icons.edit, size: 16),
//                         label: const Text("Edit"),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => EditCustomerScreen(customerId: '',),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF1A3B89),
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         icon: const Icon(Icons.delete, size: 16),
//                         label: const Text("Delete"),
//                         onPressed: () {
//                           _showDeleteConfirmation(customer["id"]);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _listTile(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.grey.shade700,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
// }
//
