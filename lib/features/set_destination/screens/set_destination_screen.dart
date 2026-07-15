import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_search_field.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';

class SetDestinationScreen extends StatefulWidget {
  final Address? address;
  final String? searchText;
  final bool isRental;
  final bool isLocal;
  final bool isOutstation;

  const SetDestinationScreen({
    super.key,
    this.address,
    this.searchText,
    this.isRental = false,
    this.isLocal = false,
    this.isOutstation = false,
  });

  @override
  State<SetDestinationScreen> createState() => _SetDestinationScreenState();
}

class _SetDestinationScreenState extends State<SetDestinationScreen> {
  FocusNode pickLocationFocus = FocusNode();
  FocusNode destinationLocationFocus = FocusNode();

  static const Color brandRed = Color(0xFFE71921);
  static const Color brandYellow = Color(0xFFFFB100);
  static const Color lightYellow = Color(0xFFFFF8EC);
  static const Color softYellow = Color(0xFFFFF0C7);
  static const Color cardBorder = Color(0xFFE8EBF0);
  static const Color textDark = Color(0xFF121A2C);
  static const Color textGrey = Color(0xFF6F7787);

  @override
  void initState() {
    super.initState();

    Get.find<LocationController>().initAddLocationData();
    Get.find<LocationController>().initTextControllers();
    final rideController = Get.find<RideController>();
    final int selectedRentalHour = rideController.rentalHour;

    rideController.clearExtraRoute();
    Get.find<MapController>().initializeData();
    rideController.initData();

    if (widget.isRental && selectedRentalHour > 0) {
      rideController.rentalHour = selectedRentalHour;
    }

    Get.find<ParcelController>().updatePaymentPerson(false, notify: false);
    Get.find<LocationController>()
        .setPickUp(Get.find<LocationController>().getUserAddress());
    if (widget.address != null) {
      Get.find<LocationController>().setDestination(widget.address);
    }
    if (widget.searchText != null) {
      Get.find<LocationController>()
          .setDestination(Address(address: widget.searchText));
      Future.delayed(const Duration(seconds: 1)).then((_) {
        Get.find<LocationController>().searchLocation(
          context,
          widget.searchText ?? '',
          type: LocationType.to,
        );
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      rideController.setLocalRide(widget.isLocal);
      rideController.setRentalRide(widget.isRental);
      rideController.setOutstationRide(widget.isOutstation);
      if (widget.isRental && selectedRentalHour > 0) {
        rideController.rentalHour = selectedRentalHour;
      }
      rideController.update();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = screenSize.width < 380 ? 16 : 22;
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      body: GetBuilder<LocationController>(builder: (locationController) {
        return GetBuilder<RideController>(builder: (rideController) {
          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      topPadding + 10,
                      horizontalPadding,
                      28,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE71921), Color(0xFFFF2D2D)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Positioned(
                          right: 0,
                          bottom: -20,
                          child: _HeaderIllustration(),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Get.back();
                                } else {
                                  Get.offAll(() => const DashboardScreen());
                                }
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Select Location',
                              style: textBold.copyWith(
                                color: Colors.white,
                                fontSize: 26,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Choose your pickup and\ndrop-off locations',
                              style: textMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: 15,
                                height: 1.30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7F8FB),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(34),
                          topRight: Radius.circular(34),
                        ),
                      ),
                      transform: Matrix4.translationValues(0, -18, 0),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                22,
                                horizontalPadding,
                                20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (widget.isRental || rideController.isRentalRide) ...[
                                    _SelectedRentalPackageCard(
                                      hour: _selectedRentalHour(rideController),
                                      km: _selectedRentalKm(rideController),
                                    ),
                                    const SizedBox(height: 18),
                                  ],
                                  Text(
                                    'Pickup location',
                                    style: textBold.copyWith(
                                      color: textDark,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _LocationCard(
                                    label: 'Current location',
                                    title: 'Pickup location',
                                    icon: Icons.location_on_rounded,
                                    trailingIcon: Icons.my_location_rounded,
                                    focusNode: pickLocationFocus,
                                    controller: locationController.pickupLocationController,
                                    hint: 'pick_location'.tr,
                                    isHighlighted: true,
                                    isReadOnly: rideController.rideDetails != null,
                                    onIconTap: () {
                                      if (rideController.rideDetails != null) {
                                        showCustomSnackBar(
                                          'your_ride_is_ongoing_complete'.tr,
                                          isError: true,
                                        );
                                      } else {
                                        RouteHelper.goPageAndHideTextField(
                                          context,
                                          PickMapScreen(
                                            type: LocationType.from,
                                            oldLocationExist: locationController.pickPosition.latitude > 0,
                                          ),
                                        );
                                      }
                                    },
                                    onChanged: (value) async {
                                      return await Get.find<LocationController>().searchLocation(
                                        context,
                                        value,
                                        type: LocationType.from,
                                      );
                                    },
                                    onTap: () {
                                      if (rideController.rideDetails != null) {
                                        showCustomSnackBar(
                                          'your_ride_is_ongoing_complete'.tr,
                                          isError: true,
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  if (locationController.extraOneRoute) ...[
                                    _ExtraRouteField(
                                      controller: locationController.extraRouteOneController,
                                      hint: 'extra_route_one'.tr,
                                      onChanged: (value) async {
                                        return await Get.find<LocationController>().searchLocation(
                                          context,
                                          value,
                                          type: LocationType.extraOne,
                                        );
                                      },
                                      onLocationTap: () {
                                        if (rideController.rideDetails != null) {
                                          showCustomSnackBar(
                                            'your_ride_is_ongoing_complete'.tr,
                                            isError: true,
                                          );
                                        } else {
                                          RouteHelper.goPageAndHideTextField(
                                            context,
                                            PickMapScreen(
                                              type: LocationType.extraOne,
                                              oldLocationExist: locationController.pickPosition.latitude > 0,
                                            ),
                                          );
                                        }
                                      },
                                      onRemove: () => locationController.setExtraRoute(remove: true),
                                      readOnly: rideController.rideDetails != null,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  if (locationController.extraTwoRoute) ...[
                                    _ExtraRouteField(
                                      controller: locationController.extraRouteTwoController,
                                      hint: 'extra_route_two'.tr,
                                      onChanged: (value) async {
                                        return await Get.find<LocationController>().searchLocation(
                                          context,
                                          value,
                                          type: LocationType.extraTwo,
                                        );
                                      },
                                      onLocationTap: () {
                                        if (rideController.rideDetails != null) {
                                          showCustomSnackBar(
                                            'your_ride_is_ongoing_complete'.tr,
                                            isError: true,
                                          );
                                        } else {
                                          RouteHelper.goPageAndHideTextField(
                                            context,
                                            PickMapScreen(
                                              type: LocationType.extraTwo,
                                              oldLocationExist: locationController.pickPosition.latitude > 0,
                                            ),
                                          );
                                        }
                                      },
                                      onRemove: () => locationController.setExtraRoute(remove: true),
                                      readOnly: rideController.rideDetails != null,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  Text(
                                    widget.isOutstation ? 'Drop city' : 'Drop-off location',
                                    style: textBold.copyWith(
                                      color: textDark,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _LocationCard(
                                          label: 'Enter destination',
                                          title: widget.isOutstation ? 'Where are you going?' : 'Where are you going?',
                                          icon: locationController.selecting ? null : Icons.near_me_rounded,
                                          trailingIcon: Icons.map_outlined,
                                          showLoader: locationController.selecting,
                                          focusNode: destinationLocationFocus,
                                          controller: locationController.destinationLocationController,
                                          hint: 'destination'.tr,
                                          isReadOnly: rideController.rideDetails != null,
                                          onIconTap: () {
                                            if (rideController.rideDetails != null) {
                                              showCustomSnackBar(
                                                'your_ride_is_ongoing_complete'.tr,
                                                isError: true,
                                              );
                                            } else {
                                              RouteHelper.goPageAndHideTextField(
                                                context,
                                                PickMapScreen(
                                                  type: LocationType.to,
                                                  oldLocationExist: locationController.pickPosition.latitude > 0,
                                                ),
                                              );
                                            }
                                          },
                                          onChanged: (value) async {
                                            return await Get.find<LocationController>().searchLocation(
                                              context,
                                              value.trim(),
                                              type: LocationType.to,
                                            );
                                          },
                                          onTap: () {
                                            if (rideController.rideDetails != null) {
                                              showCustomSnackBar(
                                                'your_ride_is_ongoing_complete'.tr,
                                                isError: true,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      if (Get.find<ConfigController>().config!.addIntermediatePoint! &&
                                          !locationController.extraTwoRoute) ...[
                                        const SizedBox(width: 10),
                                        InkWell(
                                          onTap: () => locationController.setExtraRoute(),
                                          borderRadius: BorderRadius.circular(18),
                                          child: Container(
                                            height: 56,
                                            width: 56,
                                            decoration: BoxDecoration(
                                              color: brandYellow,
                                              borderRadius: BorderRadius.circular(18),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color.fromRGBO(250, 173, 2, 0.25),
                                                  blurRadius: 14,
                                                  offset: Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(Icons.add_rounded, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (rideController.isRentalRide) ...[
                                    const SizedBox(height: 18),
                                    _AddStopsCard(
                                      count: locationController.entranceControllers.length,
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: locationController.entranceControllers.length,
                                          itemBuilder: (context, index) {
                                            return _RentalStopField(
                                              index: index,
                                              controller: locationController.entranceControllers[index],
                                              focusNode: locationController.entranceNodes[index],
                                              onRemove: () {
                                                locationController.removeMoreEntrance(index);
                                              },
                                            );
                                          },
                                        ),
                                        _AddStopButton(
                                          onTap: () {
                                            if (locationController.entranceControllers.isNotEmpty &&
                                                locationController.entranceControllers.last.text.trim().isEmpty) {
                                              showCustomSnackBar(
                                                'Please complete Stop ${locationController.entranceControllers.length} or remove it before adding another stop.',
                                              );
                                              return;
                                            }
                                            locationController.addMoreEntrance();
                                          },
                                        ),
                                      ],
                                    ),
                                  ],

                                  if (widget.isOutstation) ...[
                                    const SizedBox(height: 18),
                                    const _OutstationInfoCard(),
                                  ],
                                  if (locationController.toAddress != null &&
                                      (locationController.toAddress?.address?.isNotEmpty ?? false) &&
                                      locationController.destinationLocationController.text.trim().isNotEmpty) ...[
                                    const SizedBox(height: 18),
                                    _TripDistanceCard(
                                      distanceText: _distanceText(locationController),
                                      timeText: _durationText(locationController),
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              10,
                              horizontalPadding,
                              MediaQuery.of(context).padding.bottom + 14,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF7F8FB),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(18, 26, 44, 0.06),
                                  blurRadius: 14,
                                  offset: Offset(0, -4),
                                ),
                              ],
                            ),
                            child: rideController.loading
                                ? const Center(
                              child: SpinKitCircle(
                                color: brandYellow,
                                size: 40,
                              ),
                            )
                                : SizedBox(
                              height: 54,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _handleDone(
                                  context,
                                  locationController,
                                  rideController,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: brandYellow,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.route_rounded, color: Colors.white, size: 26),
                                    const SizedBox(width: 12),
                                    Text(
                                      'done'.tr,
                                      style: textBold.copyWith(
                                        color: Colors.white,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (locationController.resultShow)
                Positioned(
                  top: topPadding + 230 + locationController.topPosition,
                  left: 18,
                  right: 18,
                  child: InkWell(
                    onTap: () => locationController.setSearchResultShowHide(show: false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.08)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.10),
                            blurRadius: 14,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: locationController.predictionList.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Get.find<LocationController>().setLocation(
                                fromSearch: true,
                                locationController.predictionList[index].placeId!,
                                locationController.predictionList[index].description!,
                                null,
                                type: locationController.locationType,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeDefault,
                                horizontal: Dimensions.paddingSizeSmall,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, color: brandYellow),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      locationController.predictionList[index].description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                        color: Theme.of(context).textTheme.bodyLarge!.color,
                                        fontSize: Dimensions.fontSizeDefault,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          );
        });
      }),
    );
  }


  int _selectedRentalHour(RideController rideController) {
    if (rideController.rentalHour > 0) {
      return rideController.rentalHour;
    }
    if (rideController.rentalPackages.isNotEmpty) {
      final value = rideController.rentalPackages.first['free_hours'];
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }
    return 0;
  }

  int _selectedRentalKm(RideController rideController) {
    final int hour = _selectedRentalHour(rideController);
    if (hour <= 0 || rideController.rentalPackages.isEmpty) return 0;

    final package = rideController.rentalPackages.firstWhere(
          (e) => e['free_hours'].toString() == hour.toString(),
      orElse: () => rideController.rentalPackages.first,
    );

    final value = package['free_km'] ?? package['free_distance'] ?? package['distance'] ?? 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  String _distanceText(LocationController locationController) {
    final double? fromLat = _toDouble(locationController.fromAddress?.latitude);
    final double? fromLng = _toDouble(locationController.fromAddress?.longitude);
    final double? toLat = _toDouble(locationController.toAddress?.latitude);
    final double? toLng = _toDouble(locationController.toAddress?.longitude);

    if (fromLat == null || fromLng == null || toLat == null || toLng == null) {
      return '-- km';
    }

    final double distance = _calculateDistanceInKm(fromLat, fromLng, toLat, toLng);
    return '${distance.toStringAsFixed(distance < 10 ? 1 : 0)} km';
  }

  String _durationText(LocationController locationController) {
    final double? fromLat = _toDouble(locationController.fromAddress?.latitude);
    final double? fromLng = _toDouble(locationController.fromAddress?.longitude);
    final double? toLat = _toDouble(locationController.toAddress?.latitude);
    final double? toLng = _toDouble(locationController.toAddress?.longitude);

    if (fromLat == null || fromLng == null || toLat == null || toLng == null) {
      return 'Select drop';
    }

    final double distance = _calculateDistanceInKm(fromLat, fromLng, toLat, toLng);
    final int minutes = math.max(1, (distance / 25 * 60).round());
    return '$minutes min';
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  double _calculateDistanceInKm(double fromLat, double fromLng, double toLat, double toLng) {
    const double earthRadius = 6371;
    final double dLat = _degreeToRadian(toLat - fromLat);
    final double dLng = _degreeToRadian(toLng - fromLng);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreeToRadian(fromLat)) *
            math.cos(_degreeToRadian(toLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreeToRadian(double degree) => degree * math.pi / 180;

  void _handleDone(
      BuildContext context,
      LocationController locationController,
      RideController rideController,
      ) {
    if (Get.find<ConfigController>().config!.maintenanceMode != null &&
        Get.find<ConfigController>()
            .config!
            .maintenanceMode!
            .maintenanceStatus ==
            1 &&
        Get.find<ConfigController>()
            .config!
            .maintenanceMode!
            .selectedMaintenanceSystem!
            .userApp ==
            1) {
      showCustomSnackBar('maintenance_mode_on_for_ride'.tr, isError: true);
    } else {
      if (locationController.fromAddress == null ||
          locationController.fromAddress!.address == null ||
          locationController.fromAddress!.address!.isEmpty) {
        showCustomSnackBar('pickup_location_is_required'.tr);
        FocusScope.of(context).requestFocus(pickLocationFocus);
      } else if (locationController.pickupLocationController.text.isEmpty) {
        showCustomSnackBar('pickup_location_is_required'.tr);
        FocusScope.of(context).requestFocus(pickLocationFocus);
      } else if (locationController.toAddress == null ||
          locationController.toAddress!.address == null ||
          locationController.toAddress!.address!.isEmpty) {
        showCustomSnackBar('destination_location_is_required'.tr);
        FocusScope.of(context).requestFocus(destinationLocationFocus);
      } else if (locationController
          .destinationLocationController.text.isEmpty) {
        showCustomSnackBar('destination_location_is_required'.tr);
        FocusScope.of(context).requestFocus(destinationLocationFocus);
      } else {
        if (rideController.isRentalRide) {
          for (int i = 0;
          i < locationController.entranceControllers.length;
          i++) {
            if (locationController.entranceControllers[i].text.trim().isEmpty) {
              showCustomSnackBar(
                'Please enter Stop ${i + 1} or remove it.',
                isError: true,
              );
              return;
            }
          }
        }
        rideController.getEstimatedFare(false).then((value) {
          if (value.statusCode == 200) {
            debugPrint(
              'Entrance => ${Get.find<LocationController>().entranceController.text}',
            );

            Get.to(
                  () => const MapScreen(
                fromScreen: MapScreenType.ride,
                isShowCurrentPosition: false,
              ),
            );

            Get.find<RideController>()
                .updateRideCurrentState(RideState.initial);
          }
        });
      }
    }
  }
}


class _SelectedRentalPackageCard extends StatelessWidget {
  final int hour;
  final int km;

  const _SelectedRentalPackageCard({
    required this.hour,
    required this.km,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE0A8)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(18, 26, 44, 0.055),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: _SetDestinationScreenState.lightYellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: _SetDestinationScreenState.brandYellow,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected rental package',
                  style: textMedium.copyWith(
                    color: _SetDestinationScreenState.textGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hour > 0 ? '$hour hr${km > 0 ? ' • $km km' : ''}' : 'Rental package selected',
                  style: textBold.copyWith(
                    color: _SetDestinationScreenState.textDark,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: _SetDestinationScreenState.brandYellow,
            size: 28,
          ),
        ],
      ),
    );
  }
}

class _TripDistanceCard extends StatelessWidget {
  final String distanceText;
  final String timeText;

  const _TripDistanceCard({
    required this.distanceText,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EBF0)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(18, 26, 44, 0.055),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: _SetDestinationScreenState.lightYellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.route_rounded,
              color: _SetDestinationScreenState.brandYellow,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickup to drop distance',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textMedium.copyWith(
                    color: _SetDestinationScreenState.textGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  distanceText,
                  style: textBold.copyWith(
                    color: _SetDestinationScreenState.textDark,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              timeText,
              style: textBold.copyWith(
                color: _SetDestinationScreenState.brandYellow,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIllustration extends StatelessWidget {
  const _HeaderIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 130,
      child: Stack(
        children: [
          Positioned(
            right: 18,
            top: 6,
            child: Icon(
              Icons.location_on_rounded,
              color: Colors.white.withValues(alpha: 0.28),
              size: 86,
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Icon(
              Icons.route_rounded,
              color: Colors.white.withValues(alpha: 0.34),
              size: 96,
            ),
          ),
          Positioned(
            left: 4,
            bottom: 6,
            child: Icon(
              Icons.apartment_rounded,
              color: Colors.black.withValues(alpha: 0.08),
              size: 92,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String label;
  final String title;
  final IconData? icon;
  final IconData trailingIcon;
  final bool showLoader;
  final bool isHighlighted;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool isReadOnly;
  final VoidCallback onIconTap;
  final Future<dynamic> Function(String value) onChanged;
  final VoidCallback onTap;

  const _LocationCard({
    required this.label,
    required this.title,
    required this.icon,
    required this.trailingIcon,
    this.showLoader = false,
    this.isHighlighted = false,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.isReadOnly,
    required this.onIconTap,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 78),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isHighlighted
                    ? const Color(0xFFFFE0A8)
                    : const Color(0xFFE4E7EC),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(18, 26, 44, 0.07),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: onIconTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: _SetDestinationScreenState.lightYellow,
                      shape: BoxShape.circle,
                    ),
                    child: showLoader
                        ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _SetDestinationScreenState.brandYellow,
                      ),
                    )
                        : Icon(
                      icon,
                      color: _SetDestinationScreenState.brandYellow,
                      size: 29,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    readOnly: isReadOnly,
                    focusNode: focusNode,
                    controller: controller,
                    maxLines: 1,
                    onChanged: (value) => onChanged(value),
                    onTap: onTap,
                    cursorColor: _SetDestinationScreenState.brandYellow,
                    style: textBold.copyWith(
                      color: _SetDestinationScreenState.textDark,
                      fontSize: 17,
                    ),
                    decoration: InputDecoration(
                      hintText: title,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: textBold.copyWith(
                        color: const Color(0xFF5F6675),
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: onIconTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      trailingIcon,
                      color: const Color(0xFF9AA0AA),
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            top: -9,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                label,
                style: textMedium.copyWith(
                  color: _SetDestinationScreenState.brandYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentPlaceTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  const _RecentPlaceTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(18, 26, 44, 0.045),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textBold.copyWith(color: _SetDestinationScreenState.textDark, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: textMedium.copyWith(color: _SetDestinationScreenState.textGrey, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF6F7787), size: 18),
        ],
      ),
    );
  }
}

class _OutstationInfoCard extends StatelessWidget {
  const _OutstationInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.all(18),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(22),
      //   boxShadow: const [
      //     BoxShadow(
      //       color: Color.fromRGBO(18, 26, 44, 0.06),
      //       blurRadius: 22,
      //       offset: Offset(0, 10),
      //     ),
      //   ],
      // ),
      // child: Row(
      //   children: [
      //     Container(
      //       width: 64,
      //       height: 64,
      //       decoration: const BoxDecoration(
      //         color: Color(0xFFFFECEE),
      //         shape: BoxShape.circle,
      //       ),
      //       child: const Icon(Icons.route_rounded, color: _SetDestinationScreenState.brandRed, size: 34),
      //     ),
      //     const SizedBox(width: 16),
      //     Expanded(
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Text('Outstation rides', style: textBold.copyWith(color: _SetDestinationScreenState.textDark, fontSize: 18)),
      //           const SizedBox(height: 6),
      //           Text(
      //             'Choose destination city and get accurate fare based on distance.',
      //             style: textMedium.copyWith(color: _SetDestinationScreenState.textGrey, fontSize: 14, height: 1.35),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}

class _ExtraRouteField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Future<dynamic> Function(String value) onChanged;
  final VoidCallback onLocationTap;
  final VoidCallback onRemove;
  final bool readOnly;

  const _ExtraRouteField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onLocationTap,
    required this.onRemove,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onLocationTap,
            child: const Icon(
              Icons.place_outlined,
              color: _SetDestinationScreenState.brandYellow,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomSearchField(
              isReadOnly: readOnly,
              controller: controller,
              hint: hint,
              onChanged: onChanged,
              onTap: () {},
            ),
          ),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.clear_rounded,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddStopsCard extends StatelessWidget {
  final int count;
  final List<Widget> children;
  const _AddStopsCard({
    required this.count,
    required this.children,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: _SetDestinationScreenState.lightYellow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE2A1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: const BoxDecoration(
                  color: _SetDestinationScreenState.softYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.alt_route_rounded,
                  color: _SetDestinationScreenState.brandYellow,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Stops',
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: _SetDestinationScreenState.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add multiple stops during your trip',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: _SetDestinationScreenState.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1C7),
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                child: Text(
                  '$count',
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: _SetDestinationScreenState.brandYellow,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          ...children,
        ],
      ),
    );
  }
}

class _RentalStopField extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onRemove;

  const _RentalStopField({
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _SetDestinationScreenState.brandYellow,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: textBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 54),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE3E3E3)),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.045),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.drag_indicator_rounded,
                    color: Colors.grey.shade500,
                    size: 14,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      cursorColor: _SetDestinationScreenState.brandYellow,
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: _SetDestinationScreenState.textDark,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Stop ${index + 1}',
                        hintStyle: textMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: const Color(0xFF9E9E9E),
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 17),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onRemove,
                    splashRadius: 22,
                    icon: Container(
                      height: 32,
                      width: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFEEEE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: _SetDestinationScreenState.brandRed,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddStopButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddStopButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
            _SetDestinationScreenState.brandYellow.withValues(alpha: 0.7),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 28,
              width: 28,
              decoration: const BoxDecoration(
                color: _SetDestinationScreenState.softYellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: _SetDestinationScreenState.brandYellow,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Add Stop',
              style: textBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: _SetDestinationScreenState.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
