import 'package:delpick_admin/UserControls/DashboardController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class StatisticsSection extends StatefulWidget {

  @override
  State<StatisticsSection> createState() =>  StatisticsSectionState();
// {
//   // TODO: implement createState
//   throw UnimplementedError();
// }
}

class StatisticsSectionState extends State<StatisticsSection> {

  //region variables
  final DashboardController controller = Get.put(DashboardController());

  bool ascending = true;
  String sortColumn = 'sales';
  String filterCategory = "All";
  TextEditingController searchControler = TextEditingController();

  //end region

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // throw UnimplementedError();
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dashboard Overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 20),
            buildDashboardCards(),
            SizedBox(height: 30),
            buildChartsRow(),
            SizedBox(height: 30),
            buildFilters(),
          ],
        ),
      ),
    );

  }

  Widget buildDashboardCards(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildCard("Total Revenue", "\$25,000", Icons.attach_money, Colors.greenAccent),
        buildCard("Avg Order Value", "\$100", Icons.bar_chart, Colors.greenAccent),
        buildCard("Total Customers", "1500", Icons.people, Colors.purpleAccent),
        buildCard("Total Products", "500", Icons.inventory, Colors.orangeAccent),
      ],
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

  Widget buildChartsRow(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 350,
          child: buildLineChart(),
        ),
        // SizedBox(height: 20,),
        SizedBox(
          width: 350,
          child: buildBarChart(),
        ),
        // SizedBox(height: 30,),
        SizedBox(
          width: 350,
          child: buildPieChart(),
        ),
        // SizedBox(height: 30,),

      ],
    );
  }

  Widget buildLineChart(){
    return buildChartContainer(
      title: "Sales Trend",
      chart: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
           bottomTitles: AxisTitles(
             sideTitles: SideTitles(
               showTitles: true,
               getTitlesWidget: (value, meta) => Text(
                 [
                   'Jan',
                   'Feb',
                   'Mar',
                   'Apr',
                   'May',
                 ][value.toInt()],
                 style: TextStyle(
                   fontSize: 12,
                   color: Colors.grey,
                 ),
               ),
             ),
           ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) =>
                    Text('${value.toInt()}K',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: false
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false
          ),
          lineBarsData:[
            LineChartBarData(
                spots: [
                  FlSpot(0, 1),
                  FlSpot(1, 1.5),
                  FlSpot(2, 2),
                  FlSpot(3, 2.5),
                  FlSpot(4, 3),
                ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              // dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              )
            ),
          ],
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedBarSports){
                return touchedBarSports.map((barSpot){
                  final flSpot = barSpot;
                  return LineTooltipItem(
                  '${flSpot.y}K',
                  TextStyle(
                    color: Colors.white
                  ));
                }).toList();

              }
            )
          )
        ),
      ),
    );
  }

  Widget buildBarChart(){
    return buildChartContainer(
        title: "Category Sales",
        chart: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 20,
            barTouchData: BarTouchData(
              handleBuiltInTouches: true,
                touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex,){
                      return BarTooltipItem(
                        rod.toY.round().toString(),
                        TextStyle(color: Colors.white),
                      );
                    })),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta){
                    const titles = ['A', "B", "C", "D"];
                    return Text(
                      titles [value.toInt()],
                      // '${value.toInt()}K',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    );
                  }),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) =>
                      Text('${value.toInt()}K',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false
                )
              ),
              rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: false
                  )
              ),
            ),
            gridData: FlGridData(
              show: false,
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: 10,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                      toY: 12,
                      color: Colors.blue
                  ),
                ],
              ),
              BarChartGroupData(
                x: 2,
                barRods: [
                  BarChartRodData(
                      toY: 14,
                      color: Colors.blue
                  ),
                ],
              ),
              BarChartGroupData(
                x: 3,
                barRods: [
                  BarChartRodData(
                      toY: 8,
                      color: Colors.blue
                  ),
                ],
              ),
              // BarChartGroupData(
              //   x: 4,
              //   barRods: [
              //     BarChartRodData(
              //         toY: 10,
              //         color: Colors.blue
              //     ),
              //   ],
              // ),
            ],
          ),
        ));
  }

  Widget buildPieChart(){
    return buildChartContainer(
      title: 'Revenue Distribution',
      chart: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: 40,
              color: Colors.blueAccent,
              title: '40%',
              titleStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white
              )
            ),
            PieChartSectionData(
                value: 30,
                color: Colors.green,
                title: '30%',
                titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                )
            ),
            PieChartSectionData(
                value: 20,
                color: Colors.orange,
                title: '20%',
                titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                )
            ),
            PieChartSectionData(
                value: 10,
                color: Colors.redAccent,
                title: '10%',
                titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                )
            ),
          ]
        )
      ),
    );
  }

  Widget buildChartContainer({required String title, required Widget chart}){
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow:[
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 16 ,),
          SizedBox(
              height: 200,
              child: chart
          ),


        ],
      ),
    );
  }

  Widget buildFilters(){
   return Container(
     padding: EdgeInsets.all(16),
     decoration: BoxDecoration(
       color: Colors.white,
       borderRadius: BorderRadius.circular(10),
       boxShadow: [
         BoxShadow(
           color: Colors.grey.withOpacity(0.1),
           spreadRadius: 1,
           blurRadius: 5,
           offset: Offset(0, 3),
         ),
       ],
     ),
     child: Row(
       children: [
         Expanded(
             child: TextField(
               controller: searchControler,
               onChanged: (value) => setState(() {

               }),
               decoration: InputDecoration(
                 hintText: "Search Product",
                 prefixIcon: Icon(Icons.search, color: Colors.grey,),
                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(30),
                   borderSide: BorderSide.none,
                 ),
                 // fillColor: Colors.white,
                 fillColor: Colors.grey[100],
                 filled: true,
               ),
             ),
         ),
         SizedBox(width: 16,),
         DropdownButton<String>(
           value: filterCategory,
           onChanged: (value) => setState(() {

           }),
           underline: Container(),
           icon: Icon(Icons.filter_list),
           style: TextStyle(
             color: Colors.black87,
             fontSize: 16,
           ),
           items: [
             'All', 'Category 0', 'Category 1', 'Category 2', 'Category 3', 'Category 4', 'Category 5'
           ].map((category) => DropdownMenuItem(
             value: category,
             child: Text(category),
           )).toList(),
         ),
       ],
     ),
   );
  }
}