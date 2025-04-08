import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = MediaQuery.of(context).size.width;
        int crossAxisCount = _getCrossAxisCount(screenWidth);
        double childAspectRatio = _getChildAspectRatio(screenWidth);

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: statCards.length,
          itemBuilder: (context, index) {
            return _StatCard(
              icon: statCards[index]['icon'],
              value: statCards[index]['value'],
              label: statCards[index]['label'],
              backgroundColor: statCards[index]['backgroundColor'],
            );
          },
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
        );
      },
    );
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth >= 1100) {
      return 4;
    } else if (screenWidth >= 600) {
      return 2;
    } else {
      return 1;
    }
  }

  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth >= 1300) {
      return 1.1;
    } else if (screenWidth >= 800) {
      return 2.6;
    } else if (screenWidth >= 600) {
      return 2.2;
    } else if (screenWidth >= 400) {
      return 3;
    } else {
      return 2.2;
    }
  }
}

final List<Map<String, dynamic>> statCards = [
  {
    'icon': Icons.person,
    'value': '400',
    'label': 'Total Customers',
    'backgroundColor': const Color(0xffFD953B),
  },
  {
    'icon': Icons.person_add,
    'value': '420',
    'label': 'Total Driver',
    'backgroundColor': const Color(0xff0A84FF),
  },
  {
    'icon': Icons.receipt_long,
    'value': '150',
    'label': 'Total Rides',
    'backgroundColor': const Color(0xff00A957),
  },
  {
    'icon': Icons.attach_money,
    'value': '170',
    'label': 'Total Revenue',
    'backgroundColor': const Color(0xffB2914E),
  },
];


class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color backgroundColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }
}
