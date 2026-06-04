import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/dashboard/domain/models/navigation_model.dart';
import 'package:ride_sharing_user_app/features/home/screens/home_screen.dart';
import 'package:ride_sharing_user_app/features/notification/screens/notification_screen.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_screen.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageStorageBucket bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    final List<NavigationModel> item = [
      NavigationModel(
        name: 'home'.tr,
        activeIcon: Images.home,
        inactiveIcon: Images.home,
        screen: const HomeScreen(),
      ),
      NavigationModel(
        name: 'notification'.tr,
        activeIcon: Images.notification,
        inactiveIcon: Images.notification,
        screen: const NotificationScreen(),
      ),
      NavigationModel(
        name: 'activity'.tr,
        activeIcon: Images.trips,
        inactiveIcon: Images.trips,
        screen: const TripScreen(fromProfile: false),
      ),
      NavigationModel(
        name: 'profile'.tr,
        activeIcon: Images.profile,
        inactiveIcon: Images.profile,
        screen: const ProfileScreen(),
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (val) async {
        if (Get.find<BottomMenuController>().currentTab != 0) {
          Get.find<BottomMenuController>().setTabIndex(0);
        } else {
          Get.find<BottomMenuController>().exitApp();
        }
      },
      child: GetBuilder<BottomMenuController>(
        builder: (menuController) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: PageStorage(
              bucket: bucket,
              child: item[menuController.currentTab].screen,
            ),
            bottomNavigationBar: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 5,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: generateBottomNavigationItems(menuController, item),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> generateBottomNavigationItems(
      BottomMenuController menuController, List<NavigationModel> item) {
    List<Widget> items = [];
    for (int index = 0; index < item.length; index++) {
      items.add(
        Expanded(
          child: CustomMenuItem(
            isSelected: menuController.currentTab == index,
            name: item[index].name,
            activeIcon: item[index].activeIcon,
            inActiveIcon: item[index].inactiveIcon,
            onTap: () => menuController.setTabIndex(index),
          ),
        ),
      );
    }
    return items;
  }
}

class CustomMenuItem extends StatelessWidget {
  final bool isSelected;
  final String name;
  final String activeIcon;
  final String inActiveIcon;
  final VoidCallback onTap;

  const CustomMenuItem({
    super.key,
    required this.isSelected,
    required this.name,
    required this.activeIcon,
    required this.inActiveIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            isSelected ? activeIcon : inActiveIcon,
            color: isSelected
                ? const Color.fromRGBO(255, 0, 0, 1)
                : const Color.fromRGBO(20, 20, 20, 1),
            width: 40,
            height: 40,
          ),
          Text(
            name.tr,
            style: textMedium.copyWith(
                fontSize: 8,
                color: isSelected
                    ? const Color.fromRGBO(255, 0, 0, 1)
                    : const Color.fromRGBO(20, 20, 20, 1)),
          ),
        ],
      ),
    );
  }
}
