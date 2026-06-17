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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RideController>().getHourlyTariffs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(
      builder: (rideController) {
        final packages = rideController.rentalPackages;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Text(
                'Choose Package',
                style: textBold.copyWith(
                  fontSize: Dimensions.paddingSizeSixteen,
                  color: const Color.fromRGBO(20, 20, 20, 1),
                ),
              ),
            ),
            const SizedBox(height: 12),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: packages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final package = packages[index];

                        return GestureDetector(
                          onTap: () {
                            Get.to(
                              () => const SetDestinationScreen(
                                isRental: true,
                              ),
                            );
                          },
                          child: Container(
                            width: 70,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).hintColor,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${package["free_hours"]} hr',
                                  style: textSemiBold.copyWith(
                                    fontSize: Dimensions.paddingSizeDefault,
                                  ),
                                ),
                                Text(
                                  '${package["free_km"]} Kms',
                                  style: textMedium.copyWith(
                                    fontSize: Dimensions.paddingSizeMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xffF3F5F7),
                borderRadius: BorderRadius.circular(12),
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
        );
      },
    );
  }
}
