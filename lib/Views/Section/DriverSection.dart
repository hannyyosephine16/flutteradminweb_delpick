import 'package:delpick_admin/Views/Dashboard/DriverDetail/EditDriver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';

import '../Dashboard/DriverDetail/adddriver.dart';

class DriverSection extends StatefulWidget {
  const DriverSection ({super.key});
  @override
  State<DriverSection> createState() =>  DriverSectionState();
// {
//   // TODO: implement createState
// }
}

class DriverSectionState extends State<DriverSection> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
                  // MaterialPageRoute(builder: (context) => NewCustomer()),
                  MaterialPageRoute(builder: (context) => AddNewDriverScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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
        padding: const EdgeInsets.all(13.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Enables horizontal scrolling
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                  columnSpacing: 12.0, // Adjust column spacing for better layout
                  columns: const [
                    DataColumn(label: Text('Customer ID')),
                    DataColumn(label: Text('Username')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('No Telp')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: List<DataRow>.generate(
                    6,
                    // 7,
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
                        // ['Sights', 'Personalized', 'Food', 'Event', 'Entertainments', 'Other'][index])),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xff6FCF97),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ON',
                            style: TextStyle(color: Color(0xffFFFFFF), fontWeight: FontWeight.bold),
                          ),
                        )),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditDriverScreen()
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
    // // throw UnimplementedError();
    // return Container();
  }
}