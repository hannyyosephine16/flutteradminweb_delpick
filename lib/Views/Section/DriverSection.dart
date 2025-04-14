import 'package:flutter/material.dart';
import 'dart:convert';
import '../../src/DriverService.dart';
import '../Dashboard/DriverDetail/adddriver.dart';
import '../Dashboard/DriverDetail/EditDriver.dart';

class DriverSection extends StatefulWidget {
  const DriverSection({super.key});
  @override
  State<DriverSection> createState() => DriverSectionState();
}

class DriverSectionState extends State<DriverSection> {
  int _currentPage = 1;
  final int _rowsPerPage = 5;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  List<Map<String, dynamic>> _allDrivers = [];
  int _totalItems = 0;
  int _totalPages = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await DriverService.getAllDrivers(
        page: _currentPage,
        limit: _rowsPerPage,
      );

      if (response.containsKey('data') && response['data'] is List) {
        final List<dynamic> driversData = response['data'];
        setState(() {
          _allDrivers = driversData.map((driver) {
            return {
              'id': driver['id'].toString(),
              'username': driver['user']['name'],
              'email': driver['user']['email'],
              'phone': driver['user']['phone'],
              'status': driver['status'] == 'active' ? 'ON' : 'OFF',
              'vehicle_number': driver['vehicle_number'],
              'userId': driver['userId'],
              'driverData': driver,
              'userData': driver['user'],
            };
          }).toList();
          _totalItems = response['totalItems'] ?? 0;
          _totalPages = response['totalPages'] ?? 1;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Invalid response format';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Error fetching drivers: $e');
    }
  }

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

  Future<void> _deleteDriver(String id) async {
    try {
      await DriverService.deleteDriver(id);
      // Refresh the driver list after deletion
      _fetchDrivers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Driver deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete driver: $e")),
      );
    }
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
                ).then((_) => _fetchDrivers()); // Refresh after adding
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

                    // Error message if any
                    if (_hasError)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Error: $_errorMessage',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _fetchDrivers,
                            ),
                          ],
                        ),
                      ),

                    // Loading indicator
                    if (_isLoading)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                    // Table Section
                      Expanded(
                        child: isSmallScreen ? _buildListView() : _buildTable(),
                      ),

                    const SizedBox(height: 16),

                    // Pagination
                    if (!_isLoading) _buildPagination(),
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
            });
          },
        ),
      ),
    );
  }

  Widget _buildTable() {
    final displayedDrivers = _filteredDrivers;

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
                                        builder: (context) => EditDriverScreen(
                                          driverId: driver["id"],
                                          initialData: driver,
                                        ),
                                      ),
                                    ).then((_) => _fetchDrivers()); // Refresh after editing
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
              Navigator.of(context).pop();
              _deleteDriver(driverId);
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
    final displayedDrivers = _filteredDrivers;

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
                _listTile("Vehicle", driver["vehicle_number"] ?? "N/A"),
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
                              builder: (context) => EditDriverScreen(
                                driverId: driver["id"],
                                initialData: driver,
                              ),
                            ),
                          ).then((_) => _fetchDrivers()); // Refresh after editing
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
    if (_totalPages == 0) {
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
                _fetchDrivers();
              });
            }
                : null,
            style: IconButton.styleFrom(
              foregroundColor: const Color(0xFF1A3B89),
            ),
          ),

          // Page number indicators
          if (_totalPages > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _totalPages > 4 ? 4 : _totalPages,
                    (index) {
                  // Calculate which page numbers to show
                  int pageNum;
                  if (_totalPages <= 4) {
                    pageNum = index;
                  } else if (_currentPage <= 2) {
                    pageNum = index;
                  } else if (_currentPage >= _totalPages - 1) {
                    pageNum = _totalPages - 4 + index;
                  } else {
                    pageNum = _currentPage - 2 + index;
                  }

                  // Make sure pageNum is in valid range
                  pageNum = pageNum.clamp(0, _totalPages - 1);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage != pageNum + 1) {
                          setState(() {
                            _currentPage = pageNum + 1;
                            _fetchDrivers();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage == pageNum + 1
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
                          color: _currentPage == pageNum + 1
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
            onPressed: _currentPage < _totalPages
                ? () {
              setState(() {
                _currentPage++;
                _fetchDrivers();
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