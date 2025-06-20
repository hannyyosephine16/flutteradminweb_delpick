import 'package:flutter/material.dart';
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
  int _rowsPerPage = 10;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  List<Map<String, dynamic>> _allDrivers = [];
  int _totalItems = 0;
  int _totalPages = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchActive = false;

  String _selectedStatusFilter = 'all';
  final List<String> _statusOptions = ['all', 'active', 'inactive', 'busy'];
  final List<int> _itemsPerPageOptions = [5, 10, 20, 50, 100];

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  double _parseDoubleValue(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Future<void> _fetchDrivers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      print('🔄 Fetching drivers - Page: $_currentPage, Limit: $_rowsPerPage');

      final response = await DriverService.getAllDrivers(
        page: _currentPage,
        limit: _rowsPerPage,
      );

      if (response == null) {
        setState(() {
          _hasError = true;
          _errorMessage = 'No response received from server';
          _isLoading = false;
        });
        return;
      }

      print('📡 Response received: ${response.keys.toList()}');

      List<dynamic> driversData = [];

      if (response.containsKey('data') && response['data'] != null) {
        final data = response['data'];

        if (data is List) {
          driversData = data;
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('drivers') && data['drivers'] is List) {
            driversData = data['drivers'];
          } else {
            driversData = [data];
          }
        }
      }

      print('📊 Found ${driversData.length} drivers in response');

      setState(() {
        _allDrivers = driversData.map((driver) {
          if (driver is! Map<String, dynamic>) {
            print('⚠️ Invalid driver data: ${driver.runtimeType}');
            return <String, dynamic>{};
          }

          final driverMap = Map<String, dynamic>.from(driver);
          final userData = driverMap['user'] as Map<String, dynamic>? ?? {};

          return {
            'id': (driverMap['id'] ?? 0).toString(),
            'username': userData['name'] ?? 'Unknown Driver',
            'email': userData['email'] ?? 'No email',
            'phone': userData['phone'] ?? 'No phone',
            'license_number': driverMap['license_number'] ?? 'N/A',
            'vehicle_plate': driverMap['vehicle_plate'] ?? 'N/A',
            'status': driverMap['status'] ?? 'inactive',
            'rating': _parseDoubleValue(driverMap['rating']),
            'reviews_count': (driverMap['reviews_count'] ?? 0) is int
                ? driverMap['reviews_count']
                : int.tryParse(driverMap['reviews_count'].toString()) ?? 0,
            'latitude': driverMap['latitude'] != null
                ? _parseDoubleValue(driverMap['latitude'])
                : null,
            'longitude': driverMap['longitude'] != null
                ? _parseDoubleValue(driverMap['longitude'])
                : null,
            'created_at': driverMap['created_at'],
            'updated_at': driverMap['updated_at'],
            'driverData': driverMap,
            'userData': userData,
          };
        }).toList();

        _totalItems = (response['totalItems'] as num?)?.toInt() ??
            (response['total_items'] as num?)?.toInt() ??
            driversData.length;

        _totalPages = (response['totalPages'] as num?)?.toInt() ??
            (response['total_pages'] as num?)?.toInt() ??
            (_totalItems / _rowsPerPage).ceil();

        _isLoading = false;

        print('✅ Successfully loaded ${_allDrivers.length} drivers');
        print(
            '📊 Pagination: Page $_currentPage of $_totalPages (Total: $_totalItems)');
      });
    } catch (e, stackTrace) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('❌ Error fetching drivers: $e');
      print('📍 Stack trace: $stackTrace');
    }
  }

  List<Map<String, dynamic>> get _filteredDrivers {
    var filtered = _allDrivers.where((driver) {
      // Status filter
      if (_selectedStatusFilter != 'all' &&
          driver["status"] != _selectedStatusFilter) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final id = driver["id"]?.toString().toLowerCase() ?? '';
        final username = driver["username"]?.toString().toLowerCase() ?? '';
        final email = driver["email"]?.toString().toLowerCase() ?? '';
        final phone = driver["phone"]?.toString().toLowerCase() ?? '';
        final licensePlate =
            driver["vehicle_plate"]?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();

        return id.contains(query) ||
            username.contains(query) ||
            email.contains(query) ||
            phone.contains(query) ||
            licensePlate.contains(query);
      }

      return true;
    }).toList();

    return filtered;
  }

  Future<void> _deleteDriver(String id) async {
    try {
      await DriverService.deleteDriver(id);
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF4CAF50);
      case 'busy':
        return const Color(0xFFFF9800);
      case 'inactive':
      default:
        return const Color(0xFF757575);
    }
  }

  String _getStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'ACTIVE';
      case 'busy':
        return 'BUSY';
      case 'inactive':
      default:
        return 'INACTIVE';
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
          'Driver Management',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddNewDriverScreen()),
                ).then((_) => _fetchDrivers());
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Driver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3B89),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isSmallScreen = constraints.maxWidth < 900;

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
                    _buildHeader(),
                    const SizedBox(height: 16),
                    if (_hasError) _buildErrorMessage(),
                    if (_isLoading)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      Expanded(
                        flex: 3,
                        child: isSmallScreen ? _buildListView() : _buildTable(),
                      ),
                    const SizedBox(height: 16),
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

  Widget _buildHeader() {
    final filteredDrivers = _filteredDrivers;
    final showingCount = filteredDrivers.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Driver Management",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A3B89),
              ),
            ),
            _isSearchActive ? _buildSearchField() : _buildSearchButton(),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Total card
            Expanded(
              child: _buildInfoCard(
                icon: Icons.people,
                label: 'Total',
                value: _totalItems.toString(),
                color: const Color(0xFF1976D2),
              ),
            ),
            const SizedBox(width: 16),

            // Showing card
            Expanded(
              child: _buildInfoCard(
                icon: Icons.visibility,
                label: 'Showing',
                value: showingCount.toString(),
                color: const Color(0xFF388E3C),
              ),
            ),
            const SizedBox(width: 16),

            // Page card
            Expanded(
              child: _buildInfoCard(
                icon: Icons.view_agenda,
                label: 'Page',
                value: '$_currentPage/$_totalPages',
                color: const Color(0xFFF57C00),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: _buildStatusFilter(),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: _buildItemsPerPageSelector(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsPerPageSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.view_list,
              color: Color(0xFFE91E63),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Per Page',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                DropdownButton<int>(
                  value: _rowsPerPage,
                  isExpanded: true,
                  underline: const SizedBox(),
                  isDense: true,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                  items: _itemsPerPageOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _rowsPerPage = newValue;
                        _currentPage = 1; // ✅ Reset to first page
                      });
                      _fetchDrivers(); // ✅ Refetch with new limit
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12), // ✅ REDUCED from 16 to 12
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6), // ✅ REDUCED from 8 to 6
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18, // ✅ REDUCED from 20 to 18
            ),
          ),
          const SizedBox(width: 10), // ✅ REDUCED from 12 to 10
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // ✅ ADDED to minimize height
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11, // ✅ REDUCED from 12 to 11
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1), // ✅ REDUCED from 2 to 1
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16, // ✅ REDUCED from 18 to 16
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.filter_list,
              color: Color(0xFF9C27B0),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                DropdownButton<String>(
                  value: _selectedStatusFilter,
                  isExpanded: true,
                  underline: const SizedBox(),
                  isDense: true,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C27B0),
                  ),
                  items: _statusOptions.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedStatusFilter = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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
            });
          },
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
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
                  _tableHeaderCell("ID", 0.8),
                  _tableHeaderCell("Driver Name", 2),
                  _tableHeaderCell("Email", 2.5),
                  _tableHeaderCell("Phone", 1.5),
                  _tableHeaderCell("Vehicle", 1.5),
                  _tableHeaderCell("Rating", 1),
                  _tableHeaderCell("Status", 1.2),
                  _tableHeaderCell("Actions", 1.5),
                ],
              ),
            ),
          ),
          if (displayedDrivers.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text(
                "No drivers found matching your search",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          if (displayedDrivers.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: displayedDrivers.length,
                itemBuilder: (context, index) {
                  final driver = displayedDrivers[index];
                  return Container(
                    decoration: BoxDecoration(
                      color:
                          index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          _tableCell(driver["id"] ?? "N/A", 0.8),
                          _tableCell(driver["username"] ?? "N/A", 2),
                          _tableCell(driver["email"] ?? "N/A", 2.5),
                          _tableCell(driver["phone"] ?? "N/A", 1.5),
                          _tableCell(driver["vehicle_plate"] ?? "N/A", 1.5),
                          _tableCell(
                              "⭐ ${_parseDoubleValue(driver["rating"]).toStringAsFixed(1)}",
                              1),
                          _buildStatusCell(driver["status"] ?? "inactive", 1.2),
                          _buildActionCell(driver, 1.5),
                        ],
                      ),
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
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildStatusCell(String status, double flex) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            _getStatusDisplay(status),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCell(Map<String, dynamic> driver, double flex) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF1A3B89), size: 18),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditDriverScreen(
                      driverId: driver["id"] ?? "0",
                      initialData: driver,
                    ),
                  ),
                ).then((_) => _fetchDrivers());
              },
              tooltip: "Edit Driver",
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
              onPressed: () {
                _showDeleteConfirmation(context, driver["id"] ?? "0");
              },
              tooltip: "Delete Driver",
            ),
          ],
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
          style: TextStyle(fontSize: 16, color: Colors.grey),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _listTile("Driver ID", driver["id"] ?? "N/A"),
                _listTile("Name", driver["username"] ?? "N/A"),
                _listTile("Email", driver["email"] ?? "N/A"),
                _listTile("Phone", driver["phone"] ?? "N/A"),
                _listTile("License", driver["license_number"] ?? "N/A"),
                _listTile("Vehicle", driver["vehicle_plate"] ?? "N/A"),
                _listTile("Rating",
                    "⭐ ${_parseDoubleValue(driver["rating"]).toStringAsFixed(1)}"),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              _getStatusColor(driver["status"] ?? "inactive"),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusDisplay(driver["status"] ?? "inactive"),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditDriverScreen(
                                driverId: driver["id"] ?? "0",
                                initialData: driver,
                              ),
                            ),
                          ).then((_) => _fetchDrivers());
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Edit"),
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showDeleteConfirmation(context, driver["id"] ?? "0");
                        },
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text("Delete"),
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
              fontSize: 14,
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
              textAlign: TextAlign.right,
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
        content: const Text(
            "Are you sure you want to delete this driver? This action cannot be undone."),
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

  // Widget _buildPagination() {
  //   if (_totalPages <= 1) {
  //     return const SizedBox.shrink();
  //   }
  //
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 8),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           'Showing ${(_currentPage - 1) * _rowsPerPage + 1} - ${(_currentPage * _rowsPerPage).clamp(0, _totalItems)} of $_totalItems drivers',
  //           style: TextStyle(
  //             fontSize: 14,
  //             color: Colors.grey.shade600,
  //           ),
  //         ),
  //         Row(
  //           children: [
  //             IconButton(
  //               icon: const Icon(Icons.first_page),
  //               onPressed: _currentPage > 1
  //                   ? () {
  //                       setState(() {
  //                         _currentPage = 1;
  //                         _fetchDrivers();
  //                       });
  //                     }
  //                   : null,
  //             ),
  //             IconButton(
  //               icon: const Icon(Icons.chevron_left),
  //               onPressed: _currentPage > 1
  //                   ? () {
  //                       setState(() {
  //                         _currentPage--;
  //                         _fetchDrivers();
  //                       });
  //                     }
  //                   : null,
  //             ),
  //             Container(
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFF1A3B89),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Text(
  //                 '$_currentPage / $_totalPages',
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //             IconButton(
  //               icon: const Icon(Icons.chevron_right),
  //               onPressed: _currentPage < _totalPages
  //                   ? () {
  //                       setState(() {
  //                         _currentPage++;
  //                         _fetchDrivers();
  //                       });
  //                     }
  //                   : null,
  //             ),
  //             IconButton(
  //               icon: const Icon(Icons.last_page),
  //               onPressed: _currentPage < _totalPages
  //                   ? () {
  //                       setState(() {
  //                         _currentPage = _totalPages;
  //                         _fetchDrivers();
  //                       });
  //                     }
  //                   : null,
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildPagination() {
    if (_totalPages <= 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $_totalItems of $_totalItems drivers',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          // ✅ ADD: Show All button when there are multiple pages possible
          if (_totalItems > _rowsPerPage)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _rowsPerPage = _totalItems; // ✅ Set to total items
                  _currentPage = 1;
                });
                _fetchDrivers();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('Show All'),
            ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${(_currentPage - 1) * _rowsPerPage + 1} - ${(_currentPage * _rowsPerPage).clamp(0, _totalItems)} of $_totalItems drivers',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Row(
            children: [
              // ✅ ADD: Show All button
              if (_totalItems > _rowsPerPage)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _rowsPerPage = _totalItems;
                        _currentPage = 1;
                      });
                      _fetchDrivers();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child:
                        const Text('Show All', style: TextStyle(fontSize: 12)),
                  ),
                ),

              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: _currentPage > 1
                    ? () {
                        setState(() {
                          _currentPage = 1;
                        });
                        _fetchDrivers();
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 1
                    ? () {
                        setState(() {
                          _currentPage--;
                        });
                        _fetchDrivers();
                      }
                    : null,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3B89),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages
                    ? () {
                        setState(() {
                          _currentPage++;
                        });
                        _fetchDrivers();
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: _currentPage < _totalPages
                    ? () {
                        setState(() {
                          _currentPage = _totalPages;
                        });
                        _fetchDrivers();
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
