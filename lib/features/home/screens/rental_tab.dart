import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RentalTab extends StatelessWidget {
  const RentalTab({super.key});

  @override
  Widget build(BuildContext context) {
    final packages = [
      {"hour": "1 hr", "km": 10},
      {"hour": "2 hrs", "km": 20},
      {"hour": "3 hrs", "km": 30},
      {"hour": "4 hrs", "km": 40},
      {"hour": "5 hrs", "km": 50},
      {"hour": "6 hrs", "km": 60},
      {"hour": "7 hrs", "km": 70},
      {"hour": "8 hrs", "km": 80},
      {"hour": "9 hrs", "km": 90},
      {"hour": "10 hrs", "km": 100},
      {"hour": "11 hrs", "km": 100},
      {"hour": "12 hrs", "km": 100},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: packages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final package = packages[index];

              return GestureDetector(
                onTap: () {
                  Get.to(() => const SetDestinationScreen(isRental: true));
                },
                child: Container(
                  width: 70,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).hintColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        package["hour"].toString(),
                        style: textSemiBold.copyWith(
                          fontSize: Dimensions.paddingSizeDefault,
                        ),
                      ),
                      Text(
                        '${package["km"]} Kms',
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
            'Hourly Rentals, Budget-Friendly Prices,\n Trusted Journeys - Unlock a better ride with Seven Taxi Rental.',
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
  }
}
