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

  static const Color brandRed = Color(0xFFFF0000);
  static const Color brandYellow = Color(0xFFFAAD02);
  static const Color lightYellow = Color(0xFFFFFCF4);
  static const Color softYellow = Color(0xFFFFF1C7);
  static const Color cardBorder = Color(0xFFE9E9E9);
  static const Color textDark = Color(0xFF222222);
  static const Color textGrey = Color(0xFF6E6E6E);

  @override
  void initState() {
    super.initState();

    Get.find<LocationController>().initAddLocationData();
    Get.find<LocationController>().initTextControllers();
    Get.find<RideController>().clearExtraRoute();
    Get.find<MapController>().initializeData();
    Get.find<RideController>().initData();
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
      Get.find<RideController>().setLocalRide(widget.isLocal);
      Get.find<RideController>().setRentalRide(widget.isRental);
      Get.find<RideController>().setOutstationRide(widget.isOutstation);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = screenSize.width < 380 ? 16 : 22;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: brandRed,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          'Select Location',
          style: textMedium.copyWith(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          iconSize: 20,
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offAll(() => const DashboardScreen());
            }
          },
        ),
      ),
      body: Stack(
        children: [
          Container(height: 28, color: brandRed),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child:
                GetBuilder<LocationController>(builder: (locationController) {
              return GetBuilder<RideController>(builder: (rideController) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        22,
                        horizontalPadding,
                        MediaQuery.of(context).padding.bottom + 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _LocationCard(
                            label: 'Pickup',
                            icon: Icons.location_on_rounded,
                            focusNode: pickLocationFocus,
                            controller:
                                locationController.pickupLocationController,
                            hint: 'pick_location'.tr,
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
                                    oldLocationExist: locationController
                                            .pickPosition.latitude >
                                        0,
                                  ),
                                );
                              }
                            },
                            onChanged: (value) async {
                              return await Get.find<LocationController>()
                                  .searchLocation(
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
                          const SizedBox(height: 16),
                          if (locationController.extraOneRoute)
                            _ExtraRouteField(
                              controller:
                                  locationController.extraRouteOneController,
                              hint: 'extra_route_one'.tr,
                              onChanged: (value) async {
                                return await Get.find<LocationController>()
                                    .searchLocation(
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
                                      oldLocationExist: locationController
                                              .pickPosition.latitude >
                                          0,
                                    ),
                                  );
                                }
                              },
                              onRemove: () => locationController.setExtraRoute(
                                remove: true,
                              ),
                              readOnly: rideController.rideDetails != null,
                            ),
                          if (locationController.extraOneRoute)
                            const SizedBox(height: 16),
                          if (locationController.extraTwoRoute)
                            _ExtraRouteField(
                              controller:
                                  locationController.extraRouteTwoController,
                              hint: 'extra_route_two'.tr,
                              onChanged: (value) async {
                                return await Get.find<LocationController>()
                                    .searchLocation(
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
                                      oldLocationExist: locationController
                                              .pickPosition.latitude >
                                          0,
                                    ),
                                  );
                                }
                              },
                              onRemove: () => locationController.setExtraRoute(
                                remove: true,
                              ),
                              readOnly: rideController.rideDetails != null,
                            ),
                          if (locationController.extraTwoRoute)
                            const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _LocationCard(
                                  label: 'Destination',
                                  icon: locationController.selecting
                                      ? null
                                      : Icons.near_me_rounded,
                                  showLoader: locationController.selecting,
                                  focusNode: destinationLocationFocus,
                                  controller: locationController
                                      .destinationLocationController,
                                  hint: 'destination'.tr,
                                  isReadOnly:
                                      rideController.rideDetails != null,
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
                                          oldLocationExist: locationController
                                                  .pickPosition.latitude >
                                              0,
                                        ),
                                      );
                                    }
                                  },
                                  onChanged: (value) async {
                                    return await Get.find<LocationController>()
                                        .searchLocation(
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
                              if (Get.find<ConfigController>()
                                      .config!
                                      .addIntermediatePoint! &&
                                  !locationController.extraTwoRoute) ...[
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: () =>
                                      locationController.setExtraRoute(),
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    height: 52,
                                    width: 52,
                                    decoration: BoxDecoration(
                                      color: brandYellow,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: const [
                                        BoxShadow(
                                          color:
                                              Color.fromRGBO(250, 173, 2, 0.25),
                                          blurRadius: 14,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (rideController.isRentalRide) ...[
                            const SizedBox(height: 24),
                            _AddStopsCard(
                              count:
                                  locationController.entranceControllers.length,
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: locationController
                                      .entranceControllers.length,
                                  itemBuilder: (context, index) {
                                    return _RentalStopField(
                                      index: index,
                                      controller: locationController
                                          .entranceControllers[index],
                                      focusNode: locationController
                                          .entranceNodes[index],
                                      onRemove: () {
                                        locationController
                                            .removeMoreEntrance(index);
                                      },
                                    );
                                  },
                                ),
                                _AddStopButton(
                                  onTap: () {
                                    if (locationController
                                            .entranceControllers.isNotEmpty &&
                                        locationController
                                            .entranceControllers.last.text
                                            .trim()
                                            .isEmpty) {
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
                          const SizedBox(height: 26),
                          rideController.loading
                              ? const Center(
                                  child: SpinKitCircle(
                                    color: brandYellow,
                                    size: 40,
                                  ),
                                )
                              : SizedBox(
                                  height: 56,
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
                                    child: Text(
                                      'done'.tr,
                                      style: textBold.copyWith(
                                        color: Colors.white,
                                        fontSize: Dimensions.fontSizeDefault,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    if (locationController.resultShow)
                      Positioned(
                        top: 18,
                        left: 18,
                        right: 18,
                        child: InkWell(
                          onTap: () => locationController
                              .setSearchResultShowHide(show: false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Get.isDarkMode
                                  ? Theme.of(context).canvasColor
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color.fromRGBO(0, 0, 0, 0.08),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.10),
                                  blurRadius: 18,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            margin: EdgeInsets.only(
                              top: locationController.topPosition,
                            ),
                            child: ListView.builder(
                              itemCount:
                                  locationController.predictionList.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    Get.find<LocationController>().setLocation(
                                      fromSearch: true,
                                      locationController
                                          .predictionList[index].placeId!,
                                      locationController
                                          .predictionList[index].description!,
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
                                        const Icon(
                                          Icons.location_on_rounded,
                                          color: brandYellow,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            locationController
                                                .predictionList[index]
                                                .description!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .color,
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
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
          ),
        ],
      ),
    );
  }

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

class _LocationCard extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool showLoader;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool isReadOnly;
  final VoidCallback onIconTap;
  final Future<dynamic> Function(String value) onChanged;
  final VoidCallback onTap;

  const _LocationCard({
    required this.label,
    required this.icon,
    this.showLoader = false,
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
    return Material(
      color: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onIconTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEDEDED)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 18,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: _SetDestinationScreenState.softYellow,
                  shape: BoxShape.circle,
                ),
                child: showLoader
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _SetDestinationScreenState.brandYellow,
                        ),
                      )
                    : Icon(
                        icon,
                        color: _SetDestinationScreenState.brandYellow,
                        size: 22,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: CustomSearchField(
                  isReadOnly: isReadOnly,
                  focusNode: focusNode,
                  controller: controller,
                  hint: hint,
                  onChanged: onChanged,
                  onTap: onTap,
                ),
              ),
            ],
          ),
        ),
      ),
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
        borderRadius: BorderRadius.circular(18),
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
      padding: const EdgeInsets.all(18),
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
                      'You can add multiple stops during your trip',
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: _SetDestinationScreenState.textGrey,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
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
          const SizedBox(height: 20),
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
      padding: const EdgeInsets.only(bottom: 15),
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
              constraints: const BoxConstraints(minHeight: 64),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
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
                    size: 22,
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
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
