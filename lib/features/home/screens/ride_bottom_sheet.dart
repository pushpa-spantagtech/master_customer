import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/features/home/screens/local_tab.dart';
import 'package:ride_sharing_user_app/features/home/screens/outstation_tab.dart';
import 'package:ride_sharing_user_app/features/home/screens/rental_tab.dart';
import 'package:ride_sharing_user_app/util/images.dart';

class RideBottomSheet extends StatelessWidget {
  const RideBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 1),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            const TabBar(
              indicatorColor: Colors.transparent,
              labelPadding: EdgeInsets.zero,
              dividerColor: Colors.transparent,
              tabs: [
                _VehicleTab(
                  title: 'Local',
                  image: Images.car,
                ),
                _VehicleTab(
                  title: 'Rental',
                  image: Images.car,
                ),
                _VehicleTab(
                  title: 'Outstation',
                  image: Images.car,
                ),
              ],
            ),
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

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              image,
              height: 28,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFF5A5F) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
