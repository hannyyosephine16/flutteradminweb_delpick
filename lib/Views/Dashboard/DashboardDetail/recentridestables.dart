import 'package:flutter/material.dart';

class RecentRidesTable extends StatelessWidget {
  const RecentRidesTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white, // Table Background Color
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recent Rides",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff0F1B4C), // Heading color
              ),
            ),
            const SizedBox(height: 4),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(3),
                4: FlexColumnWidth(2),
                5: FlexColumnWidth(2),
                6: FlexColumnWidth(1.5),
              },
              border: TableBorder.symmetric(
                outside: BorderSide.none,
                inside: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              children: [
                _buildTableRow([
                  "Ride ID",
                  "Rider Name",
                  "Driver Name",
                  "Pickup and Dropoff",
                  "Pickup Date",
                  "Ride Fare",
                  "Status",
                ], isHeader: true),
                ...List.generate(
                  7,
                      (index) => _buildTableRow([
                    "ST747487459",
                    "Randy Aminoff",
                    "Jaylon Carder",
                    "Location 1 with complete address",
                    "12 May 2021,\n5:45",
                    "\$453",
                    "Complete",
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Colors.grey.shade200 : Colors.transparent,
      ),
      children: cells.map((cell) {
        if (cell == "Complete") {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                // backgroundColor: const Color(0xffFD953B), // Orange Button Color
                backgroundColor: const Color(0xFF228B22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Complete",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          );
        } else if (cell == "View") {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xff0F1B4C)),
              ),
              child: const Text(
                "View",
                style: TextStyle(
                  color: Color(0xff0F1B4C), // Blue text for View
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              cell,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isHeader ? 14 : 12,
                color: isHeader ? Colors.black87 : Colors.black54,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          );
        }
      }).toList(),
    );
  }
}
