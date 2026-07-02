import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RentalTab extends StatefulWidget {
  const RentalTab({super.key});

  @override
  State<RentalTab> createState() => _RentalTabState();
}

class _RentalTabState extends State<RentalTab> {
  final RideController rideController = Get.find<RideController>();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rideController = Get.find<RideController>();

      rideController.rentalHour = 0;
      rideController.update();

      if (rideController.rentalPackages.isEmpty) {
        rideController.getHourlyTariffs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(
      builder: (rideController) {
        final packages = rideController.rentalPackages;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Choose Package',
                style: textBold.copyWith(
                  fontSize: Dimensions.paddingSizeSixteen,
                  color: const Color.fromRGBO(20, 20, 20, 1),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 60,
                child: packages.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color.fromRGBO(250, 173, 2, 1),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        itemCount: packages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final package = packages[index];

                          final bool isSelected = rideController.rentalHour ==
                              package["free_hours"];

                          return GestureDetector(
                            onTap: () {
                              rideController.rentalHour = package["free_hours"];
                              rideController.update();

                              Get.to(
                                () => const SetDestinationScreen(
                                  isRental: true,
                                ),
                              );
                            },
                            child: Container(
                              width: 70,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color.fromRGBO(250, 173, 2, 0.08)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color.fromRGBO(250, 173, 2, 1)
                                      : Theme.of(context).hintColor,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${package["free_hours"]} hr'),
                                  Text('${package["free_km"]} Kms'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF3F5F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Hourly Rentals, Budget-Friendly Prices,\nTrusted Journeys - Unlock a better ride with Seven Taxi Rental.',
                  textAlign: TextAlign.center,
                  style: textMedium.copyWith(
                    fontSize: Dimensions.paddingSizeSmall,
                    color: const Color.fromRGBO(
                      20,
                      20,
                      20,
                      0.6,
                    ),
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
