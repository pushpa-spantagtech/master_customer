import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
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
  int selectedHour = 0;
  int selectedKm = 0;
  int selectedFare = 0;

  String? selectedVehicle;
  String? selectedLocalVehicle;
  String? selectedOutstationVehicle;

  final ScrollController _packageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final rideController = Get.find<RideController>();
    rideController.getLocalTariffs();
    if (rideController.rentalPackages.isEmpty) {
      rideController.getHourlyTariffs();
    }
    selectedHour = rideController.rentalHour;

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
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        if (rideController.isRentalRide &&
            rideController.rentalPackages.isNotEmpty) {
          final selectedPackage = rideController.rentalPackages.firstWhere(
            (e) => e["free_hours"] == selectedHour,
            orElse: () => rideController.rentalPackages.first,
          );

          selectedKm = selectedPackage["free_km"];

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_packageScrollController.hasClients) return;

            final index = rideController.rentalPackages.indexWhere(
              (e) => e["free_hours"] == selectedHour,
            );

            if (index != -1) {
              final maxScroll =
                  _packageScrollController.position.maxScrollExtent;

              final itemExtent = rideController.rentalPackages.length > 1
                  ? maxScroll / (rideController.rentalPackages.length - 1)
                  : 0.0;

              _packageScrollController.animateTo(
                itemExtent * index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });
        }
        final hour = DateTime.now().hour;
        final bool isNight = hour >= 22 || hour < 6;
        return Column(mainAxisSize: MainAxisSize.min, children: [
          if (rideController.isLocalRide) ...[
            ...rideController.localTariffs.expand((zone) {
              return (zone['trip_fares'] as List).map((tripFare) {
                if (tripFare['vehicle_category'] == null) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: localCarCard(
                    tripFare['vehicle_category']['name'],
                    (isNight ? tripFare['night_rate'] : tripFare['day_rate']) ??
                        0,
                  ),
                );
              });
            }),
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
              child: ListView.builder(
                controller: _packageScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: rideController.rentalPackages.length,
                itemBuilder: (context, index) {
                  final package = rideController.rentalPackages[index];
                  return rentalBox(
                    package['free_hours'],
                    package['free_km'],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ...(() {
              final tariffs = rideController.hourlyTariffs
                  .where((e) => e['free_hours'] == selectedHour)
                  .toList();

              tariffs.sort(
                (a, b) =>
                    (a['package_rate'] ?? 0).compareTo(b['package_rate'] ?? 0),
              );

              for (var tariff in tariffs) {
                print('Rental Tariff => $tariff');
              }

              return tariffs.map((tariff) {
                if (tariff['vehicle_category'] == null) {
                  print('RENTAL TARIFF ERROR => $tariff');
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: rentalCarCard(
                    tariff['vehicle_category']['name'] ?? 'Unknown',
                    tariff['package_rate'] ?? 0,
                    tariff['vehicle_category']['id'],
                  ),
                );
              }).toList();
            })(),
            const SizedBox(height: 16),
          ] else if (rideController.isOutstationRide) ...[
            ...rideController.outstationTariffs.map((tariff) {
              final distance =
                  double.tryParse(rideController.estimatedDistance) ?? 0;

              final totalFare = rideController.calculateOutstationFare(
                tariff,
                distance,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: outstationCarCard(
                  tariff.vehicleType ?? '',
                  totalFare,
                  distance,
                ),
              );
            }),
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
        onPressed: () {
          if (rideController.isLocalRide) {
            rideController.localVehicle = selectedLocalVehicle!;
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
        final rideController = Get.find<RideController>();
        rideController.localVehicle = title;
        rideController.localFare = fare.toDouble();
        final categoryController = Get.find<CategoryController>();
        for (var category in categoryController.categoryList ?? []) {
          if ((category.name ?? '').toUpperCase() == title.toUpperCase()) {
            rideController.selectedCategoryId = category.id ?? '';
            rideController.localVehicleCategoryId = category.id ?? '';

            for (var zone in rideController.localTariffs) {
              for (var tripFare in (zone['trip_fares'] as List)) {
                if ((tripFare['vehicle_category']?['name'] ?? '')
                        .toString()
                        .toUpperCase() ==
                    title.toUpperCase()) {
                  rideController.selectedIdleFee = double.tryParse(
                          tripFare['idle_fee_per_min'].toString()) ??
                      0;
                  break;
                }
              }
            }
            break;
          }
        }
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
        final rideController = Get.find<RideController>();

        setState(() {
          selectedHour = hour;
          selectedKm = km;
          selectedVehicle = null;
          selectedFare = 0;
        });

        rideController.rentalHour = hour;
        rideController.update();
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

  Widget rentalCarCard(
    String title,
    int fare,
    String categoryId,
  ) {
    bool isSelected = selectedVehicle == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedVehicle = title;
          selectedFare = fare;
        });

        final rideController = Get.find<RideController>();
        rideController.selectedCategoryId = categoryId;
        rideController.rentalVehicle = title;
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
    double totalFare,
    double distanceKm,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${totalFare.toStringAsFixed(2)}',
                  style: textMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${distanceKm.toStringAsFixed(2)} km',
                  style: textRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _packageScrollController.dispose();
    super.dispose();
  }
}
