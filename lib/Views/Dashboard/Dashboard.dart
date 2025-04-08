import 'package:delpick_admin/UserControls/DashboardController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Section/CustomerSection.dart';
import '../Section/DriverSection.dart';
import '../Section/InventorySection.dart' show InventorySection;
import '../Section/OrderSection.dart';
import '../Section/ProductionSection.dart' show ProductionSection;
import '../Section/SalesSection.dart' show SalesSection;
import '../Section/StatisticsSection.dart';
import '../Section/DashboardOverview.dart';
import '../Section/StoreSection.dart';

class Dashboard extends StatelessWidget {
  // final DashboardController controller = Get.find();
  final DashboardController controller = Get.put(DashboardController());

  // const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFFEBEE),
        body: Row(children: [
            Obx(()=> AnimatedContainer(
    width: controller.sidebarOpen.value ? 200 : 80,
        // color: Color(0xFFD32F2F),
        color: Color(0xff0A84FF),
        duration: Duration(milliseconds: 300),
        child: buildSideBar(),
        )),
        Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  buildHeader(),
                  Expanded(child: buildContent()),
                ],
              ),
            ),
        )
        ],
    )
    ,
    );
  }

  Widget buildSideBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          if (controller.sidebarOpen.value) {
            return Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Main Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            );
          }
          else {
            return SizedBox.shrink();
          }
        }),
        Obx(()=>Column(
          children: List.generate(controller.sections.length,
              (index)=> buildSideBarItem(
                controller.sections[index].icon,
                controller.sections[index].title,
                index,
              )
          ),
        ),),

      ],
    );
  }

  Widget buildSideBarItem(IconData icon, String title, int index){
    return Obx((){
      final isSelected = controller.currentSectionIndex.value == index;
      return GestureDetector(
        onTap: () {
          controller.changeSection(index);
          controller.toggleSidebar(); // Close sidebar after selection
        },
        child: Container(
          color: Color(0xff0A84FF),
          // color: Color(0xFFD32F2F),
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                  child: Container(
                    // color: Color(0xFFD32F2F),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected?   Colors.white : Color(0xff0A84FF),
                      // Colors.white : Color(0xFFD32F2F),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: isSelected?   Color(0xff0A84FF): Colors.white,
                          // Color(0xFFB71C1C): Colors.white,
                        ),
                        if(controller.sidebarOpen.value) SizedBox(width: 15,),
                        if(controller.sidebarOpen.value)
                          Text(title,
                          style: TextStyle(
                            color: isSelected ? Color(0xff0A84FF) : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal
                          ),
                          )
                      ],
                    ),
                  )
              )

            ],
          ),
        ),
      );
    });
  }

  Widget buildHeader(){
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => controller.toggleSidebar(),
            child: Icon(Icons.menu),
          ),
          SizedBox(width: 10,),
          Text(
            "Welcome Back, Admin",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Icon(
            Icons.logout,
            color: Color(0xFFB71C1C),
            size: 30,
          
          )
        ],
      ),
    );
  }

  Widget buildContent(){
    return Obx((){
      switch(controller.currentSectionIndex.value){
        case 0:
          return DashboardOverview();
        case 1:
          return CustomerSection();
        case 2:
          return DriverSection();
        case 3:
          return StoreSection();
        case 4:
          return OrderSection();
        case 5:
          return StatisticsSection();
        default:
          return Center(child: Text("Data Not Found"),);
      }
    });
  }
}

