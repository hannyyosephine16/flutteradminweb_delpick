import 'package:flutter/material.dart';
import 'package:get/get.dart';
class SectionModel{
  final String title;
  final IconData icon;

  SectionModel({required this.title, required this.icon});
}

class DashboardController extends GetxController {
  final RxInt currentSectionIndex = 0.obs;
  // final RxBool sidebarOpen = false.obs;
  final RxBool sidebarOpen = true.obs;

  final RxList<SectionModel> sections = <SectionModel>[
    SectionModel(title: "Overview", icon: Icons.home),
    SectionModel(title: "Customers", icon: Icons.people),
    SectionModel(title: "Driver", icon: Icons.motorcycle_rounded),
    SectionModel(title: "Store", icon: Icons.shopping_bag),
    SectionModel(title: "Orders", icon: Icons.list_alt),
    // SectionModel(title: "Customers", icon: Icons.people),
    // SectionModel(title: "Inventory", icon: Icons.inventory),
    // SectionModel(title: "Sales", icon: Icons.attach_money),
    // SectionModel(title: "Overview", icon: Icons.home),
    SectionModel(title: "Statistic", icon: Icons.show_chart),
  ].obs;

  Future<List<Map<String, dynamic>>> fetchData() async {
    await Future.delayed(Duration(seconds: 1));
    return List.generate(
        6,
        (index)=>{
          'productName': 'Product $index',
          'sales' : '\$${(index + 1) * 1000}',
          'stock': '${(index + 1) * 20} units',
          'category': 'Category $index',
          'dateAdded' : '2024-10-1${index + 1}',
          'totalRevenue' : '\$${(index + 1)* 5000}',
          'averaqeOrderValue' : '\$${(index + 1)* 50}',
          'customerCount' : (index + 1) * 100,
        });
  }

  void changeSection(int index){
    currentSectionIndex.value = index;
  }

  void toggleSidebar(){
    sidebarOpen.value = !sidebarOpen.value;
  }
}