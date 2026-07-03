import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/features/home/screens/local_tab.dart';
import 'package:ride_sharing_user_app/features/home/screens/outstation_tab.dart';
import 'package:ride_sharing_user_app/features/home/screens/rental_tab.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

class RideBottomSheet extends StatelessWidget {
  const RideBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Builder(builder: (context) {
        final tabController = DefaultTabController.of(context);

        tabController.addListener(() {
          if (tabController.indexIsChanging) {
            final rideController = Get.find<RideController>();

            if (tabController.index == 0) {
              rideController.setLocalRide(true);
            } else if (tabController.index == 1) {
              rideController.setRentalRide(true);
            } else if (tabController.index == 2) {
              rideController.setOutstationRide(true);
            }
          }
        });

        return Material(
          color: Colors.transparent,
          elevation: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.47,
            padding: EdgeInsets.only(
              top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const TabBar(
                  indicatorColor: Colors.transparent,
                  labelPadding: EdgeInsets.zero,
                  dividerColor: Colors.transparent,
                  overlayColor: WidgetStatePropertyAll(Colors.transparent),
                  tabs: [
                    _VehicleTab(title: 'Local', image: Images.car),
                    _VehicleTab(title: 'Rental', image: Images.car),
                    _VehicleTab(title: 'Outstation', image: Images.car),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: const TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        LocalTab(),
                        RentalTab(),
                        OutstationTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _VehicleTab extends StatelessWidget {
  final String title;
  final String image;

  const _VehicleTab({
    required this.title,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final TabController controller = DefaultTabController.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        int index = 0;

        if (title == 'Rental') {
          index = 1;
        } else if (title == 'Outstation') {
          index = 2;
        }

        final bool selected = controller.index == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                image,
                height: selected ? 32 : 28,
              ),
              const SizedBox(height: 7),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFF5A5F)
                      : const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : const Color(0xFF7A7A7A),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}