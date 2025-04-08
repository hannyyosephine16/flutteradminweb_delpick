import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Statistics extends StatelessWidget {
  const Statistics({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If the screen width is large (e.g., 600 pixels or more), show the cards in a row
        if (constraints.maxWidth >= 600) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ride Statistics
              Flexible(
                flex: 2,
                child: Card(
                  elevation: 3,
                  color: const Color(0xffFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ride Statistics",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: LineChart(
                            LineChartData(
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: true,
                                  spots: [
                                    const FlSpot(0, 1000),
                                    const FlSpot(1, 1500),
                                    const FlSpot(2, 2000),
                                    const FlSpot(3, 1800),
                                    const FlSpot(4, 1200),
                                    const FlSpot(5, 800),
                                    const FlSpot(6, 1100),
                                    const FlSpot(7, 1400),
                                    const FlSpot(8, 1600),
                                  ],
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(show: false),
                                  color: const Color(0xff3BE8B2),
                                ),
                              ],
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xff9DA8BA),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const months = [
                                        "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct"
                                      ];
                                      return Text(
                                        months[value.toInt()],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xff9DA8BA),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalLine: true,
                                drawVerticalLine: true,
                                horizontalInterval: 400,
                                verticalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return const FlLine(
                                    color: Color(0xff9DA8BA),
                                    strokeWidth: 0.5,
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return const FlLine(
                                    color: Color(0xff9DA8BA),
                                    strokeWidth: 0.5,
                                  );
                                },
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: const Color(0xff9DA8BA),
                                  width: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Driver Statistics
              Flexible(
                flex: 1,
                child: Card(
                  color: const Color(0xffFFFFFF),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Driver Statistics",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 50, top: 10),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.20,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: 28,
                                    color: const Color(0xff0A84FF),
                                    title: "Active",
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: 4,
                                    color: const Color(0xffFFCB0A),
                                    title: "Blocked",
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                                centerSpaceRadius: 40,
                                sectionsSpace: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Total Drivers: 32\nBlocked Drivers: 4",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          // On small screens, show the cards in a column
          return Column(
            children: [
              // Ride Statistics
              Card(
                elevation: 3,
                color: const Color(0xffFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ride Statistics",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                spots: [
                                  const FlSpot(0, 1000),
                                  const FlSpot(1, 1500),
                                  const FlSpot(2, 2000),
                                  const FlSpot(3, 1800),
                                  const FlSpot(4, 1200),
                                  const FlSpot(5, 800),
                                  const FlSpot(6, 1100),
                                  const FlSpot(7, 1400),
                                  const FlSpot(8, 1600),
                                ],
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                                color: const Color(0xff3BE8B2),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xff9DA8BA),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const months = [
                                      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct"
                                    ];
                                    return Text(
                                      months[value.toInt()],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xff9DA8BA),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawHorizontalLine: true,
                              drawVerticalLine: true,
                              horizontalInterval: 400,
                              verticalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                return const FlLine(
                                  color: Color(0xff9DA8BA),
                                  strokeWidth: 0.5,
                                );
                              },
                              getDrawingVerticalLine: (value) {
                                return const FlLine(
                                  color: Color(0xff9DA8BA),
                                  strokeWidth: 0.5,
                                );
                              },
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: const Color(0xff9DA8BA),
                                width: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Driver Statistics
              Card(
                color: const Color(0xffFFFFFF),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Driver Statistics",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 10),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.20,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: 28,
                                  color: const Color(0xff0A84FF),
                                  title: "Active",
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: 4,
                                  color: const Color(0xffFFCB0A),
                                  title: "Blocked",
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Total Drivers: 32\nBlocked Drivers: 4",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
