import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/home/screens/local_tab.dart';
import 'package:ride_sharing_user_app/features/home/screens/outstation_tab.dart';
import 'package:ride_sharing_user_app/features/home/screens/rental_tab.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_search_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RideBottomSheet extends StatelessWidget {
  const RideBottomSheet({super.key});

  static const Color _brandRed = Color(0xFFE71921);
  static const Color _ink = Color(0xFF121A2C);
  static const Color _muted = Color(0xFF6F7787);

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

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.62,
          ),
          margin: const EdgeInsets.only(left: 0, right: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 30,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 54,
                    height: 5,
                    margin: const EdgeInsets.only(top: 3, bottom: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E5EA),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Choose your ride',
                          style: textBold.copyWith(color: _ink, fontSize: 19),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('SevenTaxi', style: textBold.copyWith(color: _brandRed, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    indicatorColor: Colors.transparent,
                    labelPadding: EdgeInsets.zero,
                    dividerColor: Colors.transparent,
                    overlayColor: WidgetStatePropertyAll(Colors.transparent),
                    tabs: [
                      _PremiumVehicleTab(title: 'Local', subtitle: 'Within city', image: Images.car, index: 0),
                      _PremiumVehicleTab(title: 'Rental', subtitle: 'By the hour', image: Images.car, index: 1),
                      _PremiumVehicleTab(title: 'Outstation', subtitle: 'Out of city', image: Images.car, index: 2),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: tabController,
                  builder: (context, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: HomeSearchWidget(
                        isLocal: tabController.index == 0,
                        isRental: tabController.index == 1,
                        isOutstation: tabController.index == 2,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Flexible(
                  fit: FlexFit.loose,
                  child: SizedBox(
                    height: tabController.index == 0
                        ? 115
                        : tabController.index == 1
                        ? 150
                        : 135,
                    child: const NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: _disableGlow,
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [LocalTab(), RentalTab(), OutstationTab()],
                      ),
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

bool _disableGlow(OverscrollIndicatorNotification overscroll) {
  overscroll.disallowIndicator();
  return true;
}

class _PremiumVehicleTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final int index;

  const _PremiumVehicleTab({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.index,
  });

  static const Color _brandRed = Color(0xFFE71921);
  static const Color _ink = Color(0xFF121A2C);
  static const Color _muted = Color(0xFF6F7787);

  @override
  Widget build(BuildContext context) {
    final TabController controller = DefaultTabController.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final bool selected = controller.index == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: 78,
          margin: EdgeInsets.only(
            left: index == 0 ? 0 : 5,
            right: index == 2 ? 0 : 5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
              colors: [Color(0xFFE71921), Color(0xFFFF4B2E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? Colors.transparent : const Color(0xFFE8EBF0)),
            boxShadow: [
              BoxShadow(
                color: selected ? _brandRed.withValues(alpha: 0.22) : Colors.black.withValues(alpha: 0.055),
                blurRadius: selected ? 16 : 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (selected)
                Positioned(
                  right: 0,
                  top: 6,
                  child: Icon(Icons.directions_car_filled_rounded, size: 54, color: Colors.white.withValues(alpha: 0.12)),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    child: Transform.translate(
                      offset: const Offset(-10, 0),
                      child: Image.asset(
                        image,
                        height: 22,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(),
                  ),
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textBold.copyWith(color: selected ? Colors.white : _ink, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: textMedium.copyWith(color: selected ? Colors.white.withValues(alpha: 0.85) : _muted, fontSize: 10)),
                ],
              ),
              if (selected)
                Positioned(
                  right: 0,
                  top: 10,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: _brandRed, size: 14),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
