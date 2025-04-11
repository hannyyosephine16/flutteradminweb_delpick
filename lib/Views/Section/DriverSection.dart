import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../Dashboard/DriverDetail/adddriver.dart';
import '../Dashboard/DriverDetail/EditDriver.dart';

class DriverSection extends StatefulWidget {
  const DriverSection({super.key});
  @override
  State<DriverSection> createState() => DriverSectionState();
}

class DriverSectionState extends State<DriverSection> {
  int _currentPage = 0;
  final int _rowsPerPage = 5;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchActive = false;

  // Dummy data
  final List<Map<String, dynamic>> _allDrivers = [
    {"id": "1", "username": "John", "email": "john@gmail.com", "phone": "0821345678", "status": "ON"},
    {"id": "2", "username": "Rifqi", "email": "rifqi@gmail.com", "phone": "0821345678", "status": "ON"},
    {"id": "3", "username": "Yefta", "email": "yefta@gmail.com", "phone": "0821345678", "status": "ON"},
    {"id": "4", "username": "Haikal", "email": "haikal@gmail.com", "phone": "0821345678", "status": "ON"},
    {"id": "5", "username": "Miranda", "email": "Miranda@gmail.com", "phone": "0821345678", "status": "ON"},
    {"id": "6", "username": "Chairiansyah", "email": "chairiansyah@gmail.com", "phone": "0821345678", "status": "ON"},
    {"id": "7", "username": "Alex", "email": "alex@gmail.com", "phone": "0821345678", "status": "OFF"},
    {"id": "8", "username": "Sarah", "email": "sarah@gmail.com", "phone": "0821345678", "status": "ON"},
    {"id": "9", "username": "Michael", "email": "michael@gmail.com", "phone": "0821345678", "status": "OFF"},
    {"id": "10", "username": "Jessica", "email": "jessica@gmail.com", "phone": "0821345678", "status": "ON"},
  ];

  List<Map<String, dynamic>> get _filteredDrivers {
    if (_searchQuery.isEmpty) {
      return _allDrivers;
    }

    return _allDrivers.where((driver) {
      return driver["id"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver["username"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver["email"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver["phone"].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
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
          'Driver',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddNewDriverScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3B89),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('+ New Driver'),
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
                          "Driver List",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A3B89), // Darker blue for title
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

                    // Table Section
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
          },
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
            hintText: 'Search drivers...',
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
    final endIndex = (startIndex + _rowsPerPage) < _filteredDrivers.length
        ? startIndex + _rowsPerPage
        : _filteredDrivers.length;
    final displayedDrivers = _filteredDrivers.sublist(startIndex, endIndex);

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
                  _tableHeaderCell("No Telp", 2),
                  _tableHeaderCell("Status", 1),
                  _tableHeaderCell("Action", 2),
                ],
              ),
            ),
          ),

          // No results message
          if (displayedDrivers.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text(
                "No drivers found matching your search",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),

          // Table Body
          if (displayedDrivers.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: displayedDrivers.length,
                itemBuilder: (context, index) {
                  final driver = displayedDrivers[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        _tableCell(driver["id"], 1),
                        _tableCell(driver["username"], 2),
                        _tableCell(driver["email"], 3),
                        _tableCell(driver["phone"], 2),
                        Expanded(
                          flex: 10, // 1
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: driver["status"] == "ON"
                                    ? const Color(0xFF6FCF97)
                                    : Colors.red.shade400,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                driver["status"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 20, // 2
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
                                        builder: (context) => EditDriverScreen(),
                                      ),
                                    );
                                  },
                                  tooltip: "Edit",
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    // Show delete confirmation dialog
                                    _showDeleteConfirmation(context, driver["id"]);
                                  },
                                  tooltip: "Delete",
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

  void _showDeleteConfirmation(BuildContext context, String driverId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Driver"),
        content: const Text("Are you sure you want to delete this driver?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Delete logic would go here
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Driver deleted successfully")),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
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
    final endIndex = (startIndex + _rowsPerPage) < _filteredDrivers.length
        ? startIndex + _rowsPerPage
        : _filteredDrivers.length;
    final displayedDrivers = _filteredDrivers.sublist(startIndex, endIndex);

    if (displayedDrivers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: const Text(
          "No drivers found matching your search",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: displayedDrivers.length,
      itemBuilder: (context, index) {
        final driver = displayedDrivers[index];
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
                _listTile("Driver ID", driver["id"]),
                _listTile("Username", driver["username"]),
                _listTile("Email", driver["email"]),
                _listTile("Phone", driver["phone"]),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: driver["status"] == "ON"
                              ? const Color(0xFF6FCF97)
                              : Colors.red.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          driver["status"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditDriverScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Edit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3B89),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showDeleteConfirmation(context, driver["id"]);
                        },
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text("Delete"),
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
    final int totalPages = (_filteredDrivers.length / _rowsPerPage).ceil();

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
}