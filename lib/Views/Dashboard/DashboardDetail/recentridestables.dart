import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecentRidesTable extends StatefulWidget {
  const RecentRidesTable({super.key});

  @override
  State<RecentRidesTable> createState() => _RecentRidesTableState();
}

class _RecentRidesTableState extends State<RecentRidesTable> {
  int _currentPage = 0;
  final int _rowsPerPage = 5;
  final int _totalRows = 20; // Total number of data rows

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchActive = false;

  // Dummy data
  final List<Map<String, dynamic>> _allRides = List.generate(
    20,
        (index) {
      final fare = 45897 + index;
      final formattedFare = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(fare);
      return {
        "id": "ST${747487459 + index}",
        "customer": "Randy Aminoff",
        "driver": "Jaylon Carder",
        "location": "Location ${index + 1} with complete address",
        "date": "12 May 2021",
        "time": "5:45",
        "fare": formattedFare,
        "status": "Complete",
      };
    },
  );

  List<Map<String, dynamic>> get _filteredRides {
    if (_searchQuery.isEmpty) {
      return _allRides;
    }

    return _allRides.where((ride) {
      return ride["id"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ride["customer"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ride["driver"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ride["location"].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
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
                  // Header with title and search button/field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Rides",
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
                  isSmallScreen
                      ? _buildListView()
                      : _buildTable(),

                  const SizedBox(height: 16),

                  // Pagination
                  _buildPagination(),
                ],
              ),
            ),
          );
        }
    );
  }

  Widget _buildSearchField() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search rides...',
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
    final endIndex = (startIndex + _rowsPerPage) < _filteredRides.length
        ? startIndex + _rowsPerPage
        : _filteredRides.length;
    final displayedRides = _filteredRides.sublist(
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
                  _tableHeaderCell("Ride ID", 2),
                  _tableHeaderCell("Customer Name", 2),
                  _tableHeaderCell("Driver Name", 2),
                  _tableHeaderCell("Pickup and Dropoff", 3),
                  _tableHeaderCell("Pickup Date", 2),
                  _tableHeaderCell("Total Fee", 1.5),
                  _tableHeaderCell("Status", 1.5),
                ],
              ),
            ),
          ),

          // No results message
          if (displayedRides.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text(
                "No rides found matching your search",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),

          // Table Body
          ...List.generate(
            displayedRides.length,
                (index) {
              final ride = displayedRides[index];
              return Container(
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    _tableCell(ride["id"], 2),
                    _tableCell(ride["customer"], 2),
                    _tableCell(ride["driver"], 2),
                    _tableCell(ride["location"], 3),
                    _tableCell("${ride["date"]},\n${ride["time"]}", 2),
                    _tableCell(ride["fare"], 1.5),
                    Expanded(
                      flex: 15,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF228B22),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Complete",
                            style: TextStyle(
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
    final endIndex = (startIndex + _rowsPerPage) < _filteredRides.length
        ? startIndex + _rowsPerPage
        : _filteredRides.length;
    final displayedRides = _filteredRides.sublist(
        startIndex,
        endIndex
    );

    if (displayedRides.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: const Text(
          "No rides found matching your search",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      children: List.generate(
        displayedRides.length,
            (index) {
          final ride = displayedRides[index];
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
                  _listTile("Ride ID", ride["id"]),
                  _listTile("Customer", ride["customer"]),
                  _listTile("Driver", ride["driver"]),
                  _listTile("Location", ride["location"]),
                  _listTile("Date", "${ride["date"]}, ${ride["time"]}"),
                  _listTile("Fare", ride["fare"]),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Complete",
                        style: TextStyle(
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
    final int totalPages = (_filteredRides.length / _rowsPerPage).ceil();

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