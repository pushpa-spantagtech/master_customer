import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RentalTab extends StatefulWidget {
  const RentalTab({super.key});

  @override
  State<RentalTab> createState() => _RentalTabState();
}

class _RentalTabState extends State<RentalTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rideController = Get.find<RideController>();

      // Do not reset rentalHour here. It must be kept for the next page.
      if (rideController.rentalPackages.isEmpty) {
        rideController.getHourlyTariffs();
      }
    });
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      final packages = rideController.rentalPackages;

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Package',
              style: textBold.copyWith(
                fontSize: 17,
                color: const Color(0xFF121A2C),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 75,
              width: double.infinity,
              child: packages.isEmpty
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFB100),
                ),
              )
                  : ListView.separated(
                scrollDirection: Axis.horizontal,
                primary: false,
                shrinkWrap: false,
                physics: const ClampingScrollPhysics(),
                itemCount: packages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final package = packages[index];
                  final int hour = _readInt(package['free_hours']);
                  final int km = _readInt(
                    package['free_km'] ??
                        package['free_distance'] ??
                        package['distance'],
                  );
                  final bool isSelected = rideController.rentalHour == hour;

                  return _PackageCard(
                    hour: hour,
                    km: km,
                    selected: isSelected,
                    onTap: () {
                      rideController.rentalHour = hour;
                      rideController.setRentalRide(true);
                      rideController.setLocalRide(false);
                      rideController.setOutstationRide(false);
                      rideController.update();

                      Get.to(
                            () => const SetDestinationScreen(isRental: true),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _PackageCard extends StatelessWidget {
  final int hour;
  final int km;
  final bool selected;
  final VoidCallback onTap;

  const _PackageCard({
    required this.hour,
    required this.km,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 94,
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFE8EBF0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$hour hr',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textBold.copyWith(
                color: selected ? Colors.white : const Color(0xFF121A2C),
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '$km kms',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textMedium.copyWith(
                color: selected ? Colors.white70 : const Color(0xFF6F7787),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
