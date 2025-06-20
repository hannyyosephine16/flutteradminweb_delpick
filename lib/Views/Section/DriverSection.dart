// import 'package:flutter/material.dart';
// import 'dart:convert';
// import '../../src/DriverService.dart';
// import '../Dashboard/DriverDetail/adddriver.dart';
// import '../Dashboard/DriverDetail/EditDriver.dart';
//
// class DriverSection extends StatefulWidget {
//   const DriverSection({super.key});
//   @override
//   State<DriverSection> createState() => DriverSectionState();
// }
//
// class DriverSectionState extends State<DriverSection> {
//   int _currentPage = 1;
//   final int _rowsPerPage = 5;
//   bool _isLoading = true;
//   bool _hasError = false;
//   String _errorMessage = '';
//
//   List<Map<String, dynamic>> _allDrivers = [];
//   int _totalItems = 0;
//   int _totalPages = 0;
//
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   bool _isSearchActive = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchDrivers();
//   }
//
//   // ✅ FIXED: Fetch drivers with proper null safety handling
//   Future<void> _fetchDrivers() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });
//
//     try {
//       final response = await DriverService.getAllDrivers(
//         page: _currentPage,
//         limit: _rowsPerPage,
//       );
//
//       // ✅ Add null check for response
//       if (response == null) {
//         setState(() {
//           _hasError = true;
//           _errorMessage = 'No response received from server';
//           _isLoading = false;
//         });
//         return;
//       }
//
//       // ✅ Safe access to response data with null checks
//       if (response.containsKey('data') && response['data'] != null) {
//         final data = response['data'];
//
//         // Handle both List and Map<String, dynamic> cases
//         List<dynamic> driversData = [];
//
//         if (data is List) {
//           driversData = data;
//         } else if (data is Map<String, dynamic> &&
//             data.containsKey('drivers')) {
//           final drivers = data['drivers'];
//           if (drivers is List) {
//             driversData = drivers;
//           }
//         }
//
//         setState(() {
//           _allDrivers = driversData.map((driver) {
//             // ✅ Safe access to nested data with null checks
//             final driverMap = driver as Map<String, dynamic>? ?? {};
//             final userData = driverMap['user'] as Map<String, dynamic>? ?? {};
//
//             return {
//               'id': (driverMap['id'] ?? 0).toString(),
//               'username': userData['name'] ?? 'Unknown',
//               'email': userData['email'] ?? 'No email',
//               'phone': userData['phone'] ?? 'No phone',
//               'status': (driverMap['status'] ?? 'inactive') == 'active'
//                   ? 'ON'
//                   : 'OFF',
//               'vehicle_number': driverMap['vehicle_number'] ?? 'N/A',
//               'userId': driverMap['userId'] ?? 0,
//               'driverData': driverMap,
//               'userData': userData,
//             };
//           }).toList();
//
//           // ✅ Safe access to pagination data with null checks
//           _totalItems = (response['totalItems'] as int?) ?? 0;
//           _totalPages = (response['totalPages'] as int?) ?? 1;
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _hasError = true;
//           _errorMessage = 'Invalid response format: missing data field';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _hasError = true;
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//       print('Error fetching drivers: $e');
//     }
//   }
//
//   List<Map<String, dynamic>> get _filteredDrivers {
//     if (_searchQuery.isEmpty) {
//       return _allDrivers;
//     }
//
//     return _allDrivers.where((driver) {
//       final id = driver["id"]?.toString().toLowerCase() ?? '';
//       final username = driver["username"]?.toString().toLowerCase() ?? '';
//       final email = driver["email"]?.toString().toLowerCase() ?? '';
//       final phone = driver["phone"]?.toString().toLowerCase() ?? '';
//       final query = _searchQuery.toLowerCase();
//
//       return id.contains(query) ||
//           username.contains(query) ||
//           email.contains(query) ||
//           phone.contains(query);
//     }).toList();
//   }
//
//   Future<void> _deleteDriver(String id) async {
//     try {
//       await DriverService.deleteDriver(id);
//       // Refresh the driver list after deletion
//       _fetchDrivers();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Driver deleted successfully")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to delete driver: $e")),
//       );
//     }
//   }
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
//           'Driver',
//           style: TextStyle(color: Colors.black),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 1,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0),
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => AddNewDriverScreen()),
//                 ).then((_) => _fetchDrivers()); // Refresh after adding
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1A3B89),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//               ),
//               child: const Text('+ New Driver'),
//             ),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final bool isSmallScreen = constraints.maxWidth < 800;
//
//             return Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header with title and search button/field
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           "Driver List",
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF1A3B89), // Darker blue for title
//                           ),
//                         ),
//                         _isSearchActive
//                             ? _buildSearchField()
//                             : IconButton(
//                                 icon: const Icon(Icons.search,
//                                     color: Color(0xFF1A3B89)),
//                                 onPressed: () {
//                                   setState(() {
//                                     _isSearchActive = true;
//                                   });
//                                 },
//                               ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//
//                     // Error message if any
//                     if (_hasError)
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         margin: const EdgeInsets.only(bottom: 16),
//                         decoration: BoxDecoration(
//                           color: Colors.red.shade100,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.error, color: Colors.red),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 'Error: $_errorMessage',
//                                 style: const TextStyle(color: Colors.red),
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.refresh),
//                               onPressed: _fetchDrivers,
//                             ),
//                           ],
//                         ),
//                       ),
//
//                     // Loading indicator
//                     if (_isLoading)
//                       const Expanded(
//                         child: Center(
//                           child: CircularProgressIndicator(),
//                         ),
//                       )
//                     else
//                       // Table Section
//                       Expanded(
//                         child: isSmallScreen ? _buildListView() : _buildTable(),
//                       ),
//
//                     const SizedBox(height: 16),
//
//                     // Pagination
//                     if (!_isLoading) _buildPagination(),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSearchField() {
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.only(left: 16.0),
//         child: TextField(
//           controller: _searchController,
//           decoration: InputDecoration(
//             hintText: 'Search drivers...',
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
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide:
//                   const BorderSide(color: Color(0xFF1A3B89), width: 2.0),
//             ),
//           ),
//           onChanged: (value) {
//             setState(() {
//               _searchQuery = value;
//             });
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTable() {
//     final displayedDrivers = _filteredDrivers;
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
//                   _tableHeaderCell("Driver ID", 1),
//                   _tableHeaderCell("Username", 2),
//                   _tableHeaderCell("Email", 3),
//                   _tableHeaderCell("No Telp", 2),
//                   _tableHeaderCell("Status", 1),
//                   _tableHeaderCell("Action", 2),
//                 ],
//               ),
//             ),
//           ),
//
//           // No results message
//           if (displayedDrivers.isEmpty)
//             Container(
//               padding: const EdgeInsets.all(24),
//               alignment: Alignment.center,
//               child: const Text(
//                 "No drivers found matching your search",
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                 ),
//               ),
//             ),
//
//           // Table Body
//           if (displayedDrivers.isNotEmpty)
//             Expanded(
//               child: ListView.builder(
//                 itemCount: displayedDrivers.length,
//                 itemBuilder: (context, index) {
//                   final driver = displayedDrivers[index];
//                   return Container(
//                     decoration: BoxDecoration(
//                       color:
//                           index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
//                       border: Border(
//                         bottom: BorderSide(color: Colors.grey.shade200),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         _tableCell(driver["id"] ?? "N/A", 1),
//                         _tableCell(driver["username"] ?? "N/A", 2),
//                         _tableCell(driver["email"] ?? "N/A", 3),
//                         _tableCell(driver["phone"] ?? "N/A", 2),
//                         Expanded(
//                           flex: 10, // 1
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 6),
//                               decoration: BoxDecoration(
//                                 color: (driver["status"] ?? "OFF") == "ON"
//                                     ? const Color(0xFF6FCF97)
//                                     : Colors.red.shade400,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               alignment: Alignment.center,
//                               child: Text(
//                                 driver["status"] ?? "OFF",
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 20, // 2
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.edit,
//                                       color: Color(0xFF1A3B89)),
//                                   onPressed: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => EditDriverScreen(
//                                           driverId: driver["id"] ?? "0",
//                                           initialData: driver,
//                                         ),
//                                       ),
//                                     ).then((_) =>
//                                         _fetchDrivers()); // Refresh after editing
//                                   },
//                                   tooltip: "Edit",
//                                 ),
//                                 const SizedBox(width: 8),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete,
//                                       color: Colors.red),
//                                   onPressed: () {
//                                     // Show delete confirmation dialog
//                                     _showDeleteConfirmation(
//                                         context, driver["id"] ?? "0");
//                                   },
//                                   tooltip: "Delete",
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   void _showDeleteConfirmation(BuildContext context, String driverId) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Delete Driver"),
//         content: const Text("Are you sure you want to delete this driver?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               _deleteDriver(driverId);
//             },
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text("Delete"),
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
//   Widget _buildListView() {
//     final displayedDrivers = _filteredDrivers;
//
//     if (displayedDrivers.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(24),
//         alignment: Alignment.center,
//         child: const Text(
//           "No drivers found matching your search",
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.grey,
//           ),
//         ),
//       );
//     }
//
//     return ListView.builder(
//       itemCount: displayedDrivers.length,
//       itemBuilder: (context, index) {
//         final driver = displayedDrivers[index];
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
//                 _listTile("Driver ID", driver["id"] ?? "N/A"),
//                 _listTile("Username", driver["username"] ?? "N/A"),
//                 _listTile("Email", driver["email"] ?? "N/A"),
//                 _listTile("Phone", driver["phone"] ?? "N/A"),
//                 _listTile("Vehicle", driver["vehicle_number"] ?? "N/A"),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Status",
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey.shade700,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: (driver["status"] ?? "OFF") == "ON"
//                               ? const Color(0xFF6FCF97)
//                               : Colors.red.shade400,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           driver["status"] ?? "OFF",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => EditDriverScreen(
//                                 driverId: driver["id"] ?? "0",
//                                 initialData: driver,
//                               ),
//                             ),
//                           ).then(
//                               (_) => _fetchDrivers()); // Refresh after editing
//                         },
//                         icon: const Icon(Icons.edit, size: 18),
//                         label: const Text("Edit"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF1A3B89),
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           _showDeleteConfirmation(context, driver["id"] ?? "0");
//                         },
//                         icon: const Icon(Icons.delete, size: 18),
//                         label: const Text("Delete"),
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
//   Widget _buildPagination() {
//     if (_totalPages == 0) {
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
//                     setState(() {
//                       _currentPage--;
//                       _fetchDrivers();
//                     });
//                   }
//                 : null,
//             style: IconButton.styleFrom(
//               foregroundColor: const Color(0xFF1A3B89),
//             ),
//           ),
//
//           // Page number indicators
//           if (_totalPages > 0)
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: List.generate(
//                 _totalPages > 4 ? 4 : _totalPages,
//                 (index) {
//                   // Calculate which page numbers to show
//                   int pageNum;
//                   if (_totalPages <= 4) {
//                     pageNum = index;
//                   } else if (_currentPage <= 2) {
//                     pageNum = index;
//                   } else if (_currentPage >= _totalPages - 1) {
//                     pageNum = _totalPages - 4 + index;
//                   } else {
//                     pageNum = _currentPage - 2 + index;
//                   }
//
//                   // Make sure pageNum is in valid range
//                   pageNum = pageNum.clamp(0, _totalPages - 1);
//
//                   return Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 4),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (_currentPage != pageNum + 1) {
//                           setState(() {
//                             _currentPage = pageNum + 1;
//                             _fetchDrivers();
//                           });
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _currentPage == pageNum + 1
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
//                           color: _currentPage == pageNum + 1
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
//             onPressed: _currentPage < _totalPages
//                 ? () {
//                     setState(() {
//                       _currentPage++;
//                       _fetchDrivers();
//                     });
//                   }
//                 : null,
//             style: IconButton.styleFrom(
//               foregroundColor: const Color(0xFF1A3B89),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
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

  // ✅ FIXED: Fetch drivers with proper backend data structure
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

      // ✅ FIXED: Handle backend response format properly
      // Backend format: { "message": "...", "data": [...], "totalItems": 10, ... }

      List<dynamic> driversData = [];

      if (response.containsKey('data') && response['data'] != null) {
        final data = response['data'];

        if (data is List) {
          // Direct array in data field
          driversData = data;
        } else if (data is Map<String, dynamic>) {
          // Check for nested structure
          if (data.containsKey('drivers') && data['drivers'] is List) {
            driversData = data['drivers'];
          } else {
            // Handle case where data is wrapped
            driversData = [data];
          }
        }
      }

      print('📊 Found ${driversData.length} drivers in response');

      // ✅ FIXED: Map backend data to frontend format
      setState(() {
        _allDrivers = driversData.map((driver) {
          if (driver is! Map<String, dynamic>) {
            print('⚠️ Invalid driver data: ${driver.runtimeType}');
            return <String, dynamic>{};
          }

          final driverMap = Map<String, dynamic>.from(driver);
          final userData = driverMap['user'] as Map<String, dynamic>? ?? {};

          // ✅ Map backend fields correctly
          return {
            'id': (driverMap['id'] ?? 0).toString(),
            'username': userData['name'] ?? 'Unknown Driver',
            'email': userData['email'] ?? 'No email',
            'phone': userData['phone'] ?? 'No phone',
            'license_number': driverMap['license_number'] ?? 'N/A',
            'vehicle_plate': driverMap['vehicle_plate'] ?? 'N/A',
            'status': driverMap['status'] ??
                'inactive', // ✅ Use actual backend status
            'rating': (driverMap['rating'] ?? 0.0).toDouble(),
            'reviews_count': driverMap['reviews_count'] ?? 0,
            'latitude': driverMap['latitude'],
            'longitude': driverMap['longitude'],
            'created_at': driverMap['created_at'],
            'updated_at': driverMap['updated_at'],
            // Keep original data for editing
            'driverData': driverMap,
            'userData': userData,
          };
        }).toList();

        // ✅ FIXED: Handle pagination properly
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
    if (_searchQuery.isEmpty) {
      return _allDrivers;
    }

    return _allDrivers.where((driver) {
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
    }).toList();
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

  // ✅ NEW: Get status color based on backend status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF4CAF50); // Green
      case 'busy':
        return const Color(0xFFFF9800); // Orange
      case 'inactive':
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  // ✅ NEW: Get status display text
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
                    // Header with statistics and search
                    _buildHeader(),
                    const SizedBox(height: 16),

                    // Error message if any
                    if (_hasError) _buildErrorMessage(),

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

  // ✅ NEW: Enhanced header with statistics
  Widget _buildHeader() {
    final activeDrivers =
        _allDrivers.where((d) => d['status'] == 'active').length;
    final busyDrivers = _allDrivers.where((d) => d['status'] == 'busy').length;
    final inactiveDrivers =
        _allDrivers.where((d) => d['status'] == 'inactive').length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Driver List",
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

        // Statistics cards
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    'Total', _totalItems.toString(), Colors.blue)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatCard(
                    'Active', activeDrivers.toString(), Colors.green)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatCard(
                    'Busy', busyDrivers.toString(), Colors.orange)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatCard(
                    'Inactive', inactiveDrivers.toString(), Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
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

  // ✅ FIXED: Enhanced table with all backend fields
  Widget _buildTable() {
    final displayedDrivers = _filteredDrivers;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header Row
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

          // No results message
          if (displayedDrivers.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text(
                "No drivers found matching your search",
                style: TextStyle(fontSize: 16, color: Colors.grey),
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
                              "⭐ ${(driver["rating"] ?? 0.0).toStringAsFixed(1)}",
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

  // ✅ NEW: Enhanced status cell with proper colors
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

  // ✅ FIXED: Enhanced mobile list view
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
                    "⭐ ${(driver["rating"] ?? 0.0).toStringAsFixed(1)}"),

                // Status with proper styling
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

                // Action buttons
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

  Widget _buildPagination() {
    if (_totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info text
          Text(
            'Showing ${(_currentPage - 1) * _rowsPerPage + 1} - ${(_currentPage * _rowsPerPage).clamp(0, _totalItems)} of $_totalItems drivers',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          // Pagination controls
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: _currentPage > 1
                    ? () {
                        setState(() {
                          _currentPage = 1;
                          _fetchDrivers();
                        });
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 1
                    ? () {
                        setState(() {
                          _currentPage--;
                          _fetchDrivers();
                        });
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
                          _fetchDrivers();
                        });
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: _currentPage < _totalPages
                    ? () {
                        setState(() {
                          _currentPage = _totalPages;
                          _fetchDrivers();
                        });
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
