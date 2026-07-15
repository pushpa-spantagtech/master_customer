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

  late final List<NavigationModel> _items = [
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

  static const double _radius = 20;

  @override
  Widget build(BuildContext context) {
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
            extendBody: true,
            backgroundColor: const Color(0xFFF7F8FB),
            body: PageStorage(
              bucket: bucket,
              child: IndexedStack(
                index: menuController.currentTab,
                children: _items.map((item) => item.screen).toList(growable: false),
              ),
            ),
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(_radius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: generateBottomNavigationItems(menuController, _items),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> generateBottomNavigationItems(
      BottomMenuController menuController,
      List<NavigationModel> item,
      ) {
    return List.generate(item.length, (index) {
      return Expanded(
        child: CustomMenuItem(
          isSelected: menuController.currentTab == index,
          name: item[index].name,
          activeIcon: item[index].activeIcon,
          inActiveIcon: item[index].inactiveIcon,
          onTap: () => menuController.setTabIndex(index),
        ),
      );
    });
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

  static const double _radius = 20;
  static const Color _brandRed = Color(0xFFE71921);
  static const Color _ink = Color(0xFF1F2937);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_radius),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF1F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              isSelected ? activeIcon : inActiveIcon,
              color: isSelected ? _brandRed : _ink,
              width: 26,
              height: 26,
            ),
            const SizedBox(height: 3),
            Text(
              name.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textMedium.copyWith(
                fontSize: 11.2,
                height: 1.0,
                color: isSelected ? _brandRed : _ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
