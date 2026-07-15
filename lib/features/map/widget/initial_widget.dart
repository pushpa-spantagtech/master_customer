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

import '../../../helper/display_helper.dart';

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

  static const Color _brandRed = Color(0xFFE71921);
  static const Color _brandGold = Color(0xFFFFB100);
  static const Color _ink = Color(0xFF121A2C);
  static const Color _muted = Color(0xFF6F7787);
  static const Color _cardBorder = Color(0xFFE8EBF0);

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
          if (selectedHour == 0) {
            selectedHour = rideController.rentalHour > 0
                ? rideController.rentalHour
                : rideController.rentalPackages.first["free_hours"];
            rideController.rentalHour = selectedHour;
          }

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
        final bool isVehicleSelectionFlow = rideController.isLocalRide ||
            rideController.isRentalRide ||
            rideController.isOutstationRide;

        final List<Widget> contentChildren = [];

        if (rideController.isLocalRide) {
          final distance = double.tryParse(rideController.estimatedDistance) ?? 0;
          final localVehicles = _buildLocalVehicleOptions(rideController);

          if (localVehicles.isEmpty) {
            contentChildren.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'No vehicles available',
                  textAlign: TextAlign.center,
                  style: textMedium.copyWith(color: _muted),
                ),
              ),
            );
          } else {
            for (final option in localVehicles) {
              final fare = _calculateLocalFare(
                option.tariff,
                distance,
                isNight,
              );
              contentChildren.add(
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: localCarCard(
                    option.name,
                    fare,
                    option.categoryId,
                    'Total distance: ${distance.toStringAsFixed(1)} km',
                    option.tariff,
                  ),
                ),
              );
            }
          }
        } else if (rideController.isRentalRide) {
          contentChildren.addAll([
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$selectedHour hr $selectedKm kms Package',
                style: textBold.copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 76,
              width: double.infinity,
              child: ListView.builder(
                controller: _packageScrollController,
                scrollDirection: Axis.horizontal,
                primary: false,
                physics: const ClampingScrollPhysics(),
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
          ]);

          final tariffs = rideController.hourlyTariffs
              .where((e) => e['free_hours'] == selectedHour)
              .toList();

          tariffs.sort(
                (a, b) =>
                (a['package_rate'] ?? 0).compareTo(b['package_rate'] ?? 0),
          );

          if (tariffs.isEmpty) {
            contentChildren.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No vehicle package available for $selectedHour hr',
                  textAlign: TextAlign.center,
                  style: textMedium.copyWith(color: _muted),
                ),
              ),
            );
          } else {
            for (final tariff in tariffs) {
              if (tariff['vehicle_category'] == null) continue;
              contentChildren.add(
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: rentalCarCard(
                    tariff['vehicle_category']['name'] ?? 'Unknown',
                    tariff['package_rate'] ?? 0,
                    tariff['vehicle_category']['id'],
                  ),
                ),
              );
            }
          }
        } else if (rideController.isOutstationRide) {
          final distance = double.tryParse(rideController.estimatedDistance) ?? 0;

          if (rideController.outstationTariffs.isEmpty) {
            contentChildren.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'No outstation vehicles available',
                  textAlign: TextAlign.center,
                  style: textMedium.copyWith(color: _muted),
                ),
              ),
            );
          } else {
            for (final tariff in rideController.outstationTariffs) {
              final totalFare = rideController.calculateOutstationFare(
                tariff,
                distance,
              );

              contentChildren.add(
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: outstationCarCard(
                    tariff.vehicleType ?? '',
                    totalFare,
                    distance,
                  ),
                ),
              );
            }
          }
        } else {
          contentChildren.addAll([
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
              extraOneAddress: locationController.extraRouteAddress?.address ?? '',
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
          ]);

          if (rideController.isCouponApplicable) {
            contentChildren.addAll([
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    borderRadius:
                    BorderRadius.circular(Dimensions.paddingSizeSmall),
                  ),
                  child: Text(
                    'coupon_applied'.tr,
                    style: textBold.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ]);
          }
        }

        final Widget bottomAction = rideController.isLoading || rideController.isSubmit
            ? const Center(
          child: SpinKitCircle(
            color: Color.fromRGBO(250, 173, 2, 1),
            size: 40.0,
          ),
        )
            : isVehicleSelectionFlow
            ? buildButtonWidget(rideController)
            : (Get.find<ConfigController>().config!.bidOnFare!)
            ? FareInputWidget(
          expandableKey: widget.expandableKey,
          fromRide: true,
          fare: rideController.discountAmount.toDouble() > 0
              ? rideController.discountFare.toString()
              : rideController.estimatedFare.toString(),
        )
            : buildButtonWidget(rideController);

        final double screenHeight = MediaQuery.of(context).size.height;
        final double bottomSafe = MediaQuery.of(context).padding.bottom;
        final double sheetHeight = (screenHeight * 0.43)
            .clamp(335.0, 390.0)
            .toDouble();

        return SizedBox(
          height: sheetHeight,
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  physics: const BouncingScrollPhysics(),
                  children: contentChildren,
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  0,
                  12,
                  0,
                  bottomSafe + 10,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(18, 26, 44, 0.10),
                      blurRadius: 18,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: bottomAction,
                ),
              ),
            ],
          ),
        );
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
            ? _brandGold.withValues(alpha: 0.20)
            : Colors.grey.shade300,
        backgroundColor: canBook
            ? _brandGold
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
          if (!canBook) {
            showCustomSnackBar('Please select a vehicle', isError: true);
            return;
          }

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
      double fare,
      String categoryId,
      String subtitle,
      dynamic tariff,
      ) {
    final bool selected = selectedLocalVehicle == title;
    return _PremiumVehicleFareCard(
      title: title,
      subtitle: subtitle,
      fareText: '₹${fare.round()}',
      selected: selected,
      onTap: () {
        setState(() {
          selectedLocalVehicle = title;
        });
        final rideController = Get.find<RideController>();
        rideController.localVehicle = title;
        rideController.localFare = fare;
        rideController.selectedCategoryId = categoryId;
        rideController.localVehicleCategoryId = categoryId;
        rideController.selectedIdleFee = double.tryParse(
          (tariff['idle_fee_per_min'] ?? tariff['waiting_fee_per_min'] ?? 0)
              .toString(),
        ) ??
            0;
      },
    );
  }

  Widget rentalBox(int hour, int km) {
    final bool selected = selectedHour == hour;
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 88,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
            colors: [Color(0xFFE71921), Color(0xFFFF5A1F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Colors.transparent : _cardBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? _brandRed.withValues(alpha: 0.20)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: selected ? 18 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$hour hr',
              style: textBold.copyWith(
                color: selected ? Colors.white : _ink,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$km kms',
              style: textMedium.copyWith(
                color: selected ? Colors.white.withValues(alpha: 0.85) : _muted,
                fontSize: 11,
              ),
            ),
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
    final bool isSelected = selectedVehicle == title;
    return _PremiumVehicleFareCard(
      title: title,
      subtitle: '$selectedHour hr • $selectedKm km package',
      fareText: '₹$fare',
      selected: isSelected,
      onTap: () {
        setState(() {
          selectedVehicle = title;
          selectedFare = fare;
        });

        final rideController = Get.find<RideController>();
        rideController.selectedCategoryId = categoryId;
        rideController.rentalVehicle = title;
      },
    );
  }

  Widget outstationCarCard(
      String title,
      double totalFare,
      double distanceKm,
      ) {
    final bool selected = selectedOutstationVehicle == title;

    return _PremiumVehicleFareCard(
      title: title,
      subtitle: '${distanceKm.toStringAsFixed(1)} km • Outstation',
      fareText: '₹${totalFare.round()}',
      selected: selected,
      onTap: () {
        setState(() {
          selectedOutstationVehicle = title;
        });
      },
    );
  }


  List<_LocalVehicleOption> _buildLocalVehicleOptions(
      RideController rideController,
      ) {
    final List<dynamic> tripFares = [];

    for (final zone in rideController.localTariffs) {
      final fares = zone['trip_fares'];
      if (fares is List) {
        for (final fare in fares) {
          if (fare['vehicle_category'] != null) {
            tripFares.add(fare);
          }
        }
      }
    }

    dynamic findTariff(String vehicleName) {
      final normalizedName = _normalizeVehicleName(vehicleName);

      for (final fare in tripFares) {
        final tariffName = _normalizeVehicleName(
          fare['vehicle_category']?['name']?.toString() ?? '',
        );
        if (tariffName == normalizedName) {
          return fare;
        }
      }

      final group = _localFareGroup(normalizedName);
      for (final fare in tripFares) {
        final tariffName = _normalizeVehicleName(
          fare['vehicle_category']?['name']?.toString() ?? '',
        );
        if (_localFareGroup(tariffName) == group) {
          return fare;
        }
      }

      return null;
    }

    final options = <_LocalVehicleOption>[];
    final addedNames = <String>{};
    final categories = Get.find<CategoryController>().categoryList;

    if (categories != null && categories.isNotEmpty) {
      for (final category in categories) {
        final name = category.name ?? '';
        final normalizedName = _normalizeVehicleName(name);
        if (!_isSupportedLocalVehicle(normalizedName)) continue;

        final tariff = findTariff(name);
        if (tariff == null) continue;

        final uniqueKey = normalizedName;
        if (addedNames.contains(uniqueKey)) continue;
        addedNames.add(uniqueKey);

        options.add(_LocalVehicleOption(
          name: name,
          categoryId: category.id ?? '',
          tariff: tariff,
        ));
      }
    }

    if (options.isEmpty) {
      for (final fare in tripFares) {
        final name = fare['vehicle_category']?['name']?.toString() ?? '';
        final normalizedName = _normalizeVehicleName(name);
        if (!_isSupportedLocalVehicle(normalizedName)) continue;
        if (addedNames.contains(normalizedName)) continue;
        addedNames.add(normalizedName);

        options.add(_LocalVehicleOption(
          name: name,
          categoryId: fare['vehicle_category']?['id']?.toString() ?? '',
          tariff: fare,
        ));
      }
    }

    const order = ['hatchback', 'sedan', 'omni', 'eeco'];
    options.sort((a, b) {
      final aIndex = order.indexOf(_normalizeVehicleName(a.name));
      final bIndex = order.indexOf(_normalizeVehicleName(b.name));
      return (aIndex == -1 ? 99 : aIndex)
          .compareTo(bIndex == -1 ? 99 : bIndex);
    });

    return options;
  }

  double _calculateLocalFare(
      dynamic tariff,
      double distanceKm,
      bool isNight,
      ) {
    final minimumKm = _readTariffDouble(
      tariff,
      const ['minimum_km', 'min_km', 'base_km'],
    );
    final baseFare = _readTariffDouble(
      tariff,
      isNight ? const ['night_rate'] : const ['day_rate'],
    );
    final extraFarePerKm = _readTariffDouble(
      tariff,
      isNight
          ? const ['night_extra_per_km', 'extra_per_km']
          : const ['day_extra_per_km', 'extra_per_km'],
    );

    if (distanceKm <= 0 || distanceKm <= minimumKm) {
      return baseFare;
    }

    return baseFare + ((distanceKm - minimumKm) * extraFarePerKm);
  }

  double _readTariffDouble(dynamic tariff, List<String> keys) {
    for (final key in keys) {
      final value = tariff[key];
      if (value == null) continue;
      final parsed = double.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return 0;
  }

  bool _isSupportedLocalVehicle(String name) {
    return name == 'hatchback' ||
        name == 'sedan' ||
        name == 'omni' ||
        name == 'eeco';
  }

  String _localFareGroup(String name) {
    if (name == 'omni' || name == 'eeco') {
      return 'omni_eeco';
    }
    return 'hatchback_sedan';
  }

  String _normalizeVehicleName(String name) {
    return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  @override
  void dispose() {
    _packageScrollController.dispose();
    super.dispose();
  }
}



class _LocalVehicleOption {
  final String name;
  final String categoryId;
  final dynamic tariff;

  const _LocalVehicleOption({
    required this.name,
    required this.categoryId,
    required this.tariff,
  });
}

class _PremiumVehicleFareCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String fareText;
  final bool selected;
  final VoidCallback onTap;

  const _PremiumVehicleFareCard({
    required this.title,
    required this.subtitle,
    required this.fareText,
    required this.selected,
    required this.onTap,
  });

  static const Color _brandRed = Color(0xFFE71921);
  static const Color _ink = Color(0xFF121A2C);
  static const Color _muted = Color(0xFF6F7787);
  static const Color _cardBorder = Color(0xFFE8EBF0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? _brandRed : _cardBorder,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? _brandRed.withValues(alpha: 0.16)
                  : Colors.black.withValues(alpha: 0.055),
              blurRadius: selected ? 22 : 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: selected
                      ? [const Color(0xFFFFEFEF), const Color(0xFFFFF8EC)]
                      : [const Color(0xFFF8F9FC), const Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.directions_car_filled_rounded,
                    size: 46,
                    color: selected
                        ? _brandRed.withValues(alpha: 0.10)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                  Image.asset(
                    Images.car,
                    width: 62,
                    height: 42,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textBold.copyWith(
                      color: _ink,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textRegular.copyWith(
                      color: _muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  fareText,
                  style: textBold.copyWith(
                    color: selected ? _brandRed : _ink,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: selected ? _brandRed : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? _brandRed : _cardBorder,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 18)
                      : const SizedBox(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
