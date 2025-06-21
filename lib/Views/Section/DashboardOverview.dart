// Updated DashboardOverview.dart - Dengan integrasi data real
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../UserControls/DashboardController.dart';
import '../Dashboard/DashboardDetail/recentridestables.dart';
import '../Dashboard/DashboardDetail/statistics.dart';

class DashboardOverview extends StatefulWidget {
  const DashboardOverview({Key? key}) : super(key: key);

  @override
  State<DashboardOverview> createState() => DashboardOverviewState();
}

class DashboardOverviewState extends State<DashboardOverview> {
  final DashboardController controller = Get.put(DashboardController());

  @override
  void initState() {
    super.initState();
    // Pastikan data diambil saat widget diinisialisasi
    controller.fetchDashboardStats();
    controller.fetchRecentOrders();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[100]!,
            Colors.grey[50]!,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Header with Title and Date Selector
            _buildDashboardHeader(isSmallScreen),

            const SizedBox(height: 24),

            // Stats Cards Section - Improved Grid Layout
            _buildStatsCardGrid(isSmallScreen, isMediumScreen),

            const SizedBox(height: 30),

            // Statistics Section
            _buildStatisticsCard(),

            const SizedBox(height: 30),

            // Recent Orders Section (Updated from Recent Rides)
            _buildRecentOrdersCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHeader(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isSmallScreen
          // For small screens, stack components vertically
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.dashboard_rounded,
                          color: Colors.indigo[700], size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard Overview',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo[800],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDateSelector(),
              ],
            )
          // For larger screens, use a row layout
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.dashboard_rounded,
                      color: Colors.indigo[700], size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard Overview',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome back! Here\'s your business overview',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildDateSelector(),
              ],
            ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.withOpacity(0.1)),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.indigo[700]),
            const SizedBox(width: 8),
            Text(
              'Last 30 days',
              style: TextStyle(
                color: Colors.indigo[800],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.indigo[700], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCardGrid(bool isSmallScreen, bool isMediumScreen) {
    final statCards = [
      // Using Obx to reactively update values from API data
      Obx(() => _buildEnhancedStatsCard(
            'Total Orders',
            controller.totalOrdersFormatted,
            controller.ordersPercentage.value,
            Icons.shopping_basket_rounded,
            const Color(0xFF4CAF50),
          )),
      Obx(() => _buildEnhancedStatsCard(
            'Total Drivers',
            controller.totalDriversFormatted,
            controller.driversPercentage.value,
            Icons.motorcycle_rounded,
            const Color(0xFF2196F3),
          )),
      Obx(() => _buildEnhancedStatsCard(
            'Total Stores',
            controller.totalStoresFormatted,
            controller.storesPercentage.value,
            Icons.store_rounded,
            const Color(0xFF9C27B0),
          )),
      Obx(() => _buildEnhancedStatsCard(
            'Total Customers',
            controller.totalCustomersFormatted,
            controller.customersPercentage.value,
            Icons.people_rounded,
            const Color(0xFFFF9800),
          )),
    ];

    // For small screens, show cards in a single column
    if (isSmallScreen) {
      return Column(
        children: statCards
            .map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: card,
                ))
            .toList(),
      );
    }
    // For medium screens, show cards in a 2x2 grid
    else if (isMediumScreen) {
      return Wrap(
        spacing: 20.0,
        runSpacing: 20.0,
        alignment: WrapAlignment.spaceBetween,
        children: statCards,
      );
    }
    // For large screens, show cards in a row
    else {
      return Row(
        children: statCards
            .map((card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: card,
                  ),
                ))
            .toList(),
      );
    }
  }

  Widget _buildEnhancedStatsCard(String title, String value, String percentage,
      IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          // Background design element
          Positioned(
            right: -30,
            bottom: -30,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Icon(
                icon,
                size: 120,
                color: color.withOpacity(0.07),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        percentage,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 2),
                      // Use Flexible to prevent overflow
                      Flexible(
                        child: Text(
                          'vs last month',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.indigo.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(Icons.bar_chart, color: Colors.indigo[700], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Order Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                ),
                child: DropdownButton<String>(
                  value: 'Monthly',
                  items: ['Daily', 'Weekly', 'Monthly'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (_) {},
                  underline: const SizedBox(),
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: Colors.indigo[700]),
                  style: TextStyle(
                      color: Colors.indigo[800], fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Statistics(),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.indigo.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_long,
                    color: Colors.indigo[700], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Show loading indicator in refresh button
              Obx(() => ElevatedButton.icon(
                    onPressed: controller.isLoadingOrders.value
                        ? null
                        : controller.refreshOrders,
                    icon: controller.isLoadingOrders.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.refresh, size: 18),
                    label: Text(controller.isLoadingOrders.value
                        ? 'Loading...'
                        : 'Refresh'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.indigo[600],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 16),

          // Show orders count
          Obx(() => controller.recentOrders.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Showing ${controller.recentOrders.length} recent orders',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                )
              : const SizedBox.shrink()),

          const SizedBox(height: 8),
          const RecentRidesTable(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
