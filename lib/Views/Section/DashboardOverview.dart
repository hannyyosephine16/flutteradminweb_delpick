import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:fl_chart/fl_chart.dart';  // For graph
import '../../UserControls/DashboardController.dart';
import '../Dashboard/DashboardDetail/recentridestables.dart';
import '../Dashboard/DashboardDetail/statistics.dart';

class DashboardOverview extends StatefulWidget {
  @override
  State<DashboardOverview> createState() => DashboardOverviewState();
}

class DashboardOverviewState extends State<DashboardOverview> {
  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Section for Revenue & Visitor Stats
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // _buildStatsCard('Today Revenue', '\$7619', '+10%'),
                // _buildStatsCard('Today Visitor', '\$7619', '+19%'),
                // _buildStatsCard('Product Sold', '\$7619', '+10%'),
                // _buildStatsCard('Total Revenue', '\$7619', '+8%'),
                buildStatsCard('Total Order', '100', '+10%', Icons.shopping_basket,Colors.greenAccent ),
                buildStatsCard('Today Driver', '80', '+19%', Icons.motorcycle,Colors.greenAccent ),
                buildStatsCard('Total Store', '90', '+10%', Icons.store_mall_directory,Colors.purpleAccent),
                buildStatsCard('Total Customer', '50', '+8%', Icons.people,Colors.orangeAccent ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Statistics(),
          RecentRidesTable()
          // Earnings Graph
          // Container(
          //   padding: const EdgeInsets.all(8.0),
          //   height: 200,
          //   child: LineChart(
          //     LineChartData(
          //       gridData: FlGridData(show: false),
          //       titlesData: FlTitlesData(show: false),
          //       borderData: FlBorderData(show: true),
          //       lineBarsData: [
          //         LineChartBarData(
          //           spots: [
          //             FlSpot(0, 2),
          //             FlSpot(1, 1),
          //             FlSpot(2, 1.5),
          //             FlSpot(3, 2.5),
          //             FlSpot(4, 3),
          //             FlSpot(5, 2),
          //           ],
          //           isCurved: true,
          //           color: Colors.blue,
          //           barWidth: 3,
          //           isStrokeCapRound: true,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // Sales by Category Pie Chart
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Container(
          //     height: 200,
          //     child: PieChart(
          //       PieChartData(
          //         sections: [
          //           PieChartSectionData(value: 8.5, title: 'Electronics', color: Colors.blue),
          //           PieChartSectionData(value: 10.9, title: 'Women\'s', color: Colors.orange),
          //           PieChartSectionData(value: 10.3, title: 'Phones', color: Colors.green),
          //           PieChartSectionData(value: 5.5, title: 'Others', color: Colors.red),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // Helper Widget for creating stats cards
  Widget _buildStatsCard(String title, String value, String percentage) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(percentage, style: TextStyle(color: Colors.green)),
        ],
      ),
    );
  }

  Widget buildCard(String title, String value, IconData icon, Color color){
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 30,
                    color: color,
                  ),
                  SizedBox(width: 10,),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10,),
                ],
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatsCard(String title, String value, String percentage, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Menyelaraskan ikon dan teks secara vertikal
            children: [
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween, // Menjaga posisi ikon dan teks di kiri
                crossAxisAlignment: CrossAxisAlignment.center, // Menyelaraskan ikon dan teks secara vertikal
                children: [
                  Icon(icon, size: 30, color: color), // Ganti warna sesuai kebutuhan
                  SizedBox(width: 8), // Memberi jarak antara ikon dan judul
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(height: 10),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(percentage, style: TextStyle(color: Colors.green)),
            ],
          ),
          // child: Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Row(
          //       children: [
          //         Icon(
          //           icon,
          //           size: 30,
          //           color: color,
          //         ),
          //         SizedBox(width: 10,),
          //         Text(
          //           title,
          //           style: TextStyle(
          //             fontSize: 16,
          //             fontWeight: FontWeight.bold,
          //             color: Colors.black87,
          //           ),
          //         ),
          //         SizedBox(height: 10,),
          //       ],
          //     ),
          //     Text(
          //       value,
          //       style: TextStyle(
          //         fontWeight: FontWeight.bold,
          //         color: Colors.black.withOpacity(0.9),
          //       ),
          //     ),
          //   ],
          // ),
        ),
      ),
    );

    return Card(
      color: Colors.white70.withOpacity(0.9),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: EdgeInsets.all(5),
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Menyelaraskan ikon dan teks secara vertikal
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween, // Menjaga posisi ikon dan teks di kiri
              crossAxisAlignment: CrossAxisAlignment.center, // Menyelaraskan ikon dan teks secara vertikal
              children: [
                Icon(icon, size: 24, color: Colors.blue), // Ganti warna sesuai kebutuhan
                SizedBox(width: 8), // Memberi jarak antara ikon dan judul
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(percentage, style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }

}
