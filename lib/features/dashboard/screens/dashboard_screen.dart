import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/domain/models/navigation_model.dart';
import 'package:ride_sharing_user_app/features/home/screens/home_screen.dart';
import 'package:ride_sharing_user_app/features/notification/screens/notification_screen.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageStorageBucket bucket = PageStorageBucket();

  bool _isChangingTab = false;
  bool _isHandlingBack = false;

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

  Future<void> _changeTab(
    BottomMenuController menuController,
    int index,
  ) async {
    if (_isChangingTab || menuController.currentTab == index) {
      return;
    }

    _isChangingTab = true;

    menuController.setTabIndex(index);

    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (mounted) {
      _isChangingTab = false;
    }
  }

  Future<void> _handleBack() async {
    if (_isHandlingBack) {
      return;
    }

    _isHandlingBack = true;

    final BottomMenuController menuController =
        Get.find<BottomMenuController>();

    if (menuController.currentTab != 0) {
      menuController.setTabIndex(0);
    } else {
      menuController.exitApp();
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (mounted) {
      _isHandlingBack = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _handleBack();
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
                children:
                    _items.map((item) => item.screen).toList(growable: false),
              ),
            ),
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.all(
                Dimensions.paddingSizeDefault,
              ),
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE7E9EE),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x17101828),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: generateBottomNavigationItems(
                    menuController,
                    _items,
                  ),
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
    List<NavigationModel> items,
  ) {
    return List.generate(items.length, (index) {
      return Expanded(
        child: CustomMenuItem(
          index: index,
          isSelected: menuController.currentTab == index,
          name: items[index].name,
          onTap: () {
            _changeTab(menuController, index);
          },
        ),
      );
    });
  }
}

class CustomMenuItem extends StatelessWidget {
  final int index;
  final bool isSelected;
  final String name;
  final VoidCallback onTap;

  const CustomMenuItem({
    super.key,
    required this.index,
    required this.isSelected,
    required this.name,
    required this.onTap,
  });

  static const Color _selectedColor = Color(0xFFE71921);
  static const Color _unselectedColor = Color(0xFF98A2B3);

  IconData get _activeIcon {
    switch (index) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.notifications_rounded;
      case 2:
        return Icons.receipt_long_rounded;
      case 3:
        return Icons.person_rounded;
      default:
        return Icons.circle;
    }
  }

  IconData get _inactiveIcon {
    switch (index) {
      case 0:
        return Icons.home_outlined;
      case 1:
        return Icons.notifications_none_rounded;
      case 2:
        return Icons.receipt_long_outlined;
      case 3:
        return Icons.person_outline_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? _activeIcon : _inactiveIcon,
              size: 24,
              color: isSelected ? _selectedColor : _unselectedColor,
            ),
            const SizedBox(height: 3),
            Text(
              name.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textRegular.copyWith(
                color: isSelected ? _selectedColor : _unselectedColor,
                fontSize: 11.5,
                height: 1,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
