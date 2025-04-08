import 'dart:convert'; // Untuk mengonversi data JSON
import 'package:delpick_admin/Views/Dashboard/CustomerDetail/EditCustomer.dart';
import 'package:delpick_admin/Views/Dashboard/CustomerDetail/addcustomer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CustomerSection extends StatefulWidget {
  const CustomerSection({super.key});

  @override
  State<CustomerSection> createState() => CustomerSectionState();
}

class CustomerSectionState extends State<CustomerSection> {
  static const String baseUrl = 'https://delpick.fun/api/v1';

  // List untuk menyimpan data customer yang diambil dari API
  List<Customer> customers = [];

  // Mengambil data dari API
  Future<void> fetchCustomers() async {
    final response = await http.get(Uri.parse('$baseUrl/customers'));

    if (response.statusCode == 200) {
      // Jika response berhasil (status code 200), parsing data JSON
      List<dynamic> data = json.decode(response.body);
      setState(() {
        // Mengubah data menjadi list customer
        customers = data.map((json) => Customer.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load customers');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCustomers(); // Memanggil fungsi fetch saat widget pertama kali dibangun
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text(
          'Customer',
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
                    // MaterialPageRoute(builder: (context) => NewCustomer()),
                  MaterialPageRoute(builder: (context) => AddNewCustomerScreen()),

                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('+ New Customer'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(13.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Memungkinkan scroll horizontal
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                // child: customers.isEmpty
                //     ? Center(child: CircularProgressIndicator()) // Tampilkan loading jika belum ada data
                //     : DataTable(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                  columnSpacing: 16.0,
                  columns: const [
                    DataColumn(label: Text('Customer ID')),
                    DataColumn(label: Text('Username')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('No Telp')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: List<DataRow>.generate(
                    6,
                    // customers.length,
                        (index) => DataRow(
                      cells: [
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(
                            ['John', 'Rifqi', 'Yefta', 'Haikal', 'Miranda', 'Chairiansyah'][index])
                        ),
                        DataCell(Text(
                            ['john@gmail.com', 'rifqi@gmail.com', 'yefta@gmail.com', 'haikal@gmail.com', 'Miranda@gmail.com', 'chairiansyah@gmail.com'][index])
                        ),
                        DataCell(Text(
                            ['0821345678', '0821345678', '0821345678', '0821345678', '0821345678', '0821345678'][index])
                        ),
                        // DataCell(Text('${customers[index].id}')),
                        // DataCell(Text(customers[index].username)),
                        // DataCell(Text(customers[index].email)),
                        // DataCell(Text(customers[index].phone)),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // Navigasi ke halaman edit customer
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditCustomerScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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

// import 'package:delpick_admin/Views/Dashboard/CustomerDetail/NewCustomer.dart';
// import 'package:delpick_admin/Views/Dashboard/CustomerDetail/addcustomer.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
//
// import '../Dashboard/CustomerDetail/EditCustomer.dart';
// import '../Dashboard/DriverDetail/EditDriver.dart';
//
// class CustomerSection extends StatefulWidget {
//   const CustomerSection ({super.key});
//
//   @override
//   State<CustomerSection> createState() =>  CustomerSectionState();
// // {
// //   // TODO: implement createState
// // }
// }
//
// class CustomerSectionState extends State<CustomerSection> {
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Customer',
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
//                     context,
//                     // MaterialPageRoute(builder: (context) => NewCustomer()),
//                   MaterialPageRoute(builder: (context) => AddNewCustomerScreen()),
//
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//               ),
//               child: const Text('+ New Customer'),
//             ),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(13.0),
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal, // Enables horizontal scrolling
//           child: ConstrainedBox(
//             constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
//             child: Card(
//               color: Colors.white,
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: DataTable(
//                   headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
//                   columnSpacing: 16.0, // Adjust column spacing for better layout
//                   columns: const [
//                     DataColumn(label: Text('Customer ID')),
//                     DataColumn(label: Text('Username')),
//                     DataColumn(label: Text('Email')),
//                     DataColumn(label: Text('No Telp')),
//                     DataColumn(label: Text('Action')),
//                   ],
//                   rows: List<DataRow>.generate(
//                     6,
//                     // 7,
//                         (index) => DataRow(
//                       cells: [
//                         DataCell(Text('${index + 1}')),
//                         DataCell(Text(
//                             ['John', 'Rifqi', 'Yefta', 'Haikal', 'Miranda', 'Chairiansyah'][index])
//                         ),
//                         DataCell(Text(
//                             ['john@gmail.com', 'rifqi@gmail.com', 'yefta@gmail.com', 'haikal@gmail.com', 'Miranda@gmail.com', 'chairiansyah@gmail.com'][index])
//                         ),
//                         DataCell(Text(
//                             ['0821345678', '0821345678', '0821345678', '0821345678', '0821345678', '0821345678'][index])
//                         ),
//                             // ['Sights', 'Personalized', 'Food', 'Event', 'Entertainments', 'Other'][index])),
//                         // DataCell(Container(
//                         //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                         //   decoration: BoxDecoration(
//                         //     color: const Color(0xff6FCF97),
//                         //     borderRadius: BorderRadius.circular(12),
//                         //   ),
//                         //   child: const Text(
//                         //     'ON',
//                         //     style: TextStyle(color: Color(0xffFFFFFF), fontWeight: FontWeight.bold),
//                         //   ),
//                         // )),
//                         DataCell(Row(
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.delete, color: Colors.red),
//                               onPressed: () {},
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.edit, color: Colors.blue),
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => EditCustomerScreen()
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         )),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//     // // throw UnimplementedError();
//     // return Container();
//   }
// }