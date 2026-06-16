import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/fare_input_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/route_widget.dart';
import 'package:ride_sharing_user_app/features/payment/controllers/payment_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/ride_category.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/trip_fare_summery.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class InitialWidget extends StatefulWidget {
  final GlobalKey<ExpandableBottomSheetState> expandableKey;

  const InitialWidget({super.key, required this.expandableKey});

  @override
  State<InitialWidget> createState() => _InitialWidgetState();
}

class _InitialWidgetState extends State<InitialWidget> {
  bool showRentalInfo = false;
  int selectedHour = 1;
  int selectedKm = 10;
  int selectedFare = 300;

  String? selectedVehicle;
  String? selectedLocalVehicle;
  String? selectedOutstationVehicle;

  Map<int, Map<String, int>> rentalFare = {
    1: {"Mini": 300, "Sedan": 310, "Eeco": 360},
    2: {"Mini": 440, "Sedan": 450, "Eeco": 490},
    3: {"Mini": 570, "Sedan": 610, "Eeco": 630},
    4: {"Mini": 710, "Sedan": 775, "Eeco": 790},
    5: {"Mini": 880, "Sedan": 945, "Eeco": 940},
    6: {"Mini": 1070, "Sedan": 1135, "Eeco": 1090},
    7: {"Mini": 1260, "Sedan": 1325, "Eeco": 1240},
    8: {"Mini": 1450, "Sedan": 1510, "Eeco": 1390},
    9: {"Mini": 1640, "Sedan": 1700, "Eeco": 1540},
    10: {"Mini": 1790, "Sedan": 1890},
    11: {"Mini": 1875, "Sedan": 1965},
    12: {"Mini": 1950, "Sedan": 2040},
  };

  @override
  void initState() {
    var rideController = Get.find<RideController>();
    if (Get.find<PaymentController>().paymentType == 'wallet' &&
        (rideController.discountAmount.toDouble() > 0
                ? rideController.discountFare
                : rideController.estimatedFare) >
            Get.find<ProfileController>()
                .profileModel!
                .data!
                .wallet!
                .walletBalance!) {
      Get.find<PaymentController>().setPaymentType(0);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        final hour = DateTime.now().hour;
        final bool isNight = hour >= 22 || hour < 6;
        return Column(mainAxisSize: MainAxisSize.min, children: [
          if (rideController.isLocalRide) ...[
            localCarCard(
              "Hatchback / Sedan",
              isNight ? 120 : 100,
            ),
            const SizedBox(height: 12),
            localCarCard(
              "Omni / Eeco",
              isNight ? 170 : 140,
            ),
            const SizedBox(height: 16),
          ] else if (rideController.isRentalRide) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$selectedHour hr $selectedKm kms Package',
                style: textBold.copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  rentalBox(1, 10),
                  rentalBox(2, 20),
                  rentalBox(3, 30),
                  rentalBox(4, 40),
                  rentalBox(5, 50),
                  rentalBox(6, 60),
                  rentalBox(7, 70),
                  rentalBox(8, 80),
                  rentalBox(9, 90),
                  rentalBox(10, 100),
                  rentalBox(11, 100),
                  rentalBox(12, 100),
                ],
              ),
            ),
            const SizedBox(height: 20),
            rentalCarCard(
              "Mini",
              rentalFare[selectedHour]!["Mini"] ?? 0,
            ),
            const SizedBox(height: 12),
            rentalCarCard(
              "Sedan",
              rentalFare[selectedHour]!["Sedan"] ?? 0,
            ),
            if (rentalFare[selectedHour]!.containsKey("Eeco")) ...[
              const SizedBox(height: 12),
              rentalCarCard(
                "Eeco",
                rentalFare[selectedHour]!["Eeco"] ?? 0,
              ),
            ],
            const SizedBox(height: 16),
          ] else if (rideController.isOutstationRide) ...[
            ...rideController.outstationTariffs.map((tariff) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: outstationCarCard(
                    tariff.vehicleType ?? '',
                    double.parse(tariff.baseFare ?? '0'),
                  ),
                )),
            const SizedBox(height: 16),
          ] else ...[
            RideCategoryWidget(onTap: (value) async {
              if (rideController.isCouponApplicable) {
                await Future.delayed(const Duration(milliseconds: 500));
                widget.expandableKey.currentState?.expand(duration: 1000);
              } else {
                widget.expandableKey.currentState?.contract(duration: 500);
                widget.expandableKey.currentState?.expand(duration: 1000);
              }
            }),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            RouteWidget(
              totalDistance: rideController.fareList.isEmpty
                  ? '0'
                  : rideController.fareList[rideController.rideCategoryIndex]
                          .estimatedDistance ??
                      '0',
              fromAddress: locationController.fromAddress?.address ?? '',
              extraOneAddress:
                  locationController.extraRouteAddress?.address ?? '',
              extraTwoAddress:
                  locationController.extraRouteTwoAddress?.address ?? '',
              toAddress: locationController.toAddress?.address ?? '',
              entrance: locationController.entranceController.text,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            TripFareSummery(
              tripFare: rideController.estimatedFare,
              fromParcel: false,
              discountFare: rideController.discountFare,
              discountAmount: rideController.discountAmount,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            if (rideController.isCouponApplicable) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                      vertical: Dimensions.paddingSizeExtraSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .primaryColor
                          .withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(Dimensions.paddingSizeSmall),
                    ),
                    child: Text('coupon_applied'.tr,
                        style: textBold.copyWith(
                            color: Theme.of(context).primaryColor))),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],
          ],
          rideController.isLoading || rideController.isSubmit
              ? const Center(
                  child: SpinKitCircle(
                      color: Color.fromRGBO(250, 173, 2, 1), size: 40.0))
              : (Get.find<ConfigController>().config!.bidOnFare!)
                  ? FareInputWidget(
                      expandableKey: widget.expandableKey,
                      fromRide: true,
                      fare: rideController.discountAmount.toDouble() > 0
                          ? rideController.discountFare.toString()
                          : rideController.estimatedFare.toString(),
                    )
                  : buildButtonWidget(rideController),
        ]);
      });
    });
  }

  ButtonWidget buildButtonWidget(RideController rideController) {
    bool canBook = rideController.isLocalRide
        ? selectedLocalVehicle != null
        : rideController.isOutstationRide
            ? selectedOutstationVehicle != null
            : rideController.isRentalRide
                ? selectedVehicle != null
                : true;
    return ButtonWidget(
        textColor: canBook ? Colors.white : Colors.grey.shade600,
        borderColor: canBook
            ? const Color.fromRGBO(255, 128, 128, 0.2)
            : Colors.grey.shade300,
        backgroundColor: canBook
            ? const Color.fromRGBO(250, 173, 2, 1)
            : Colors.grey.shade300,
        fontSize: 16.0,
        buttonText: rideController.isLocalRide
            ? (selectedLocalVehicle == null
                ? "Select Vehicle"
                : "Book $selectedLocalVehicle")
            : rideController.isOutstationRide
                ? (selectedOutstationVehicle == null
                    ? "Select Vehicle"
                    : "Book $selectedOutstationVehicle")
                : rideController.isRentalRide
                    ? (selectedVehicle == null
                        ? "Select Vehicle"
                        : "Book $selectedVehicle")
                    : "find_rider".tr,
        radius: 12,
        onPressed: () {
          if (rideController.isLocalRide) {
            rideController.localVehicle = selectedLocalVehicle!;

            rideController.localFare =
                selectedLocalVehicle == "Hatchback / Sedan"
                    ? ((DateTime.now().hour >= 22 || DateTime.now().hour < 6)
                        ? 120
                        : 100)
                    : ((DateTime.now().hour >= 22 || DateTime.now().hour < 6)
                        ? 170
                        : 140);
          } else if (rideController.isOutstationRide) {
            rideController.outstationVehicle = selectedOutstationVehicle!;

            final tariff = rideController.outstationTariffs.firstWhere(
              (e) =>
                  e.vehicleType!.toUpperCase() ==
                  selectedOutstationVehicle!.toUpperCase(),
            );

            final distance =
                double.tryParse(rideController.estimatedDistance) ?? 0;

            rideController.outstationFare =
                rideController.calculateOutstationFare(
              tariff,
              distance,
            );
          } else if (rideController.isRentalRide) {
            rideController.rentalVehicle = selectedVehicle!;
            rideController.rentalHour = selectedHour;
            rideController.rentalPackageFare = selectedFare.toDouble();
          }
          print('selectedLocalVehicle=$selectedLocalVehicle, '
              'localFare=${rideController.localFare}');
          rideController
              .submitRideRequest(rideController.noteController.text, false)
              .then((value) {
            if (value.statusCode == 200) {
              if (rideController.isOutstationRide) {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Thank You!'),
                    content: const Text(
                      'Thank you for choosing Seven Taxi.\n'
                      'Our team will contact you shortly.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          rideController.tripDetails = null;
                          rideController.rideDetails = null;
                          rideController
                              .updateRideCurrentState(RideState.initial);

                          Get.back();
                          Get.offAll(() => const DashboardScreen());
                        },
                        child: const Text('OK, Got It'),
                      ),
                    ],
                  ),
                  barrierDismissible: false,
                );
              } else {
                Get.find<AuthController>().saveFindingRideCreatedTime();
                rideController.updateRideCurrentState(RideState.findingRider);
                Get.find<MapController>().initializeData();
                Get.find<MapController>().setOwnCurrentLocation();
                Get.find<MapController>().notifyMapController();
              }
            }
          });
        });
  }

  Widget localCarCard(
    String title,
    int fare,
  ) {
    bool selected = selectedLocalVehicle == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLocalVehicle = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected
              ? const Color.fromRGBO(250, 173, 2, 1).withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? const Color.fromRGBO(250, 173, 2, 1)
                : Theme.of(context).hintColor,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              Images.car,
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: textMedium.copyWith(
                    color: const Color.fromRGBO(20, 20, 20, 0.6),
                    fontSize: Dimensions.fontSizeDefault,
                  )),
            ),
            Text('₹$fare',
                style: textBold.copyWith(
                  color: const Color.fromRGBO(20, 20, 20, 0.8),
                  fontSize: Dimensions.fontSizeDefault,
                )),
          ],
        ),
      ),
    );
  }

  Widget rentalBox(int hour, int km) {
    bool selected = selectedHour == hour;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedHour = hour;
          selectedKm = km;
          selectedVehicle = null;
          selectedFare = 0;
        });
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color.fromRGBO(250, 173, 2, 1).withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? const Color.fromRGBO(250, 173, 2, 1)
                : Theme.of(context).hintColor,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$hour hr',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text('$km kms'),
          ],
        ),
      ),
    );
  }

  Widget rentalCarCard(String title, int fare) {
    bool isSelected = selectedVehicle == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedVehicle = title;
          selectedFare = fare;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromRGBO(250, 173, 2, 1).withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color.fromRGBO(250, 173, 2, 1)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              Images.car,
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: textMedium.copyWith(
                    color: const Color.fromRGBO(20, 20, 20, 0.6),
                    fontSize: Dimensions.fontSizeDefault,
                  )),
            ),
            Text('₹$fare',
                style: textBold.copyWith(
                  color: const Color.fromRGBO(20, 20, 20, 0.8),
                  fontSize: Dimensions.fontSizeDefault,
                )),
          ],
        ),
      ),
    );
  }

  Widget outstationCarCard(
    String title,
    double fare,
  ) {
    bool selected = selectedOutstationVehicle == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOutstationVehicle = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected
              ? const Color.fromRGBO(250, 173, 2, 1).withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? const Color.fromRGBO(250, 173, 2, 1)
                : Theme.of(context).hintColor,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              Images.car,
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: textMedium.copyWith(
                    color: const Color.fromRGBO(20, 20, 20, 0.6),
                    fontSize: Dimensions.fontSizeDefault,
                  )),
            ),
            Text('₹$fare',
                style: textBold.copyWith(
                  color: const Color.fromRGBO(20, 20, 20, 0.8),
                  fontSize: Dimensions.fontSizeDefault,
                )),
          ],
        ),
      ),
    );
  }
}
