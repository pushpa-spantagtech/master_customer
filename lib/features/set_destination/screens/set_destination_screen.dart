import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_search_field.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/set_destination/widget/input_field_for_set_route.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/divider_widget.dart';
import 'dart:math' as math;

class SetDestinationScreen extends StatefulWidget {
  final Address? address;
  final String? searchText;

  const SetDestinationScreen({super.key, this.address, this.searchText});

  @override
  State<SetDestinationScreen> createState() => _SetDestinationScreenState();
}

class _SetDestinationScreenState extends State<SetDestinationScreen> {
  FocusNode pickLocationFocus = FocusNode();
  FocusNode destinationLocationFocus = FocusNode();

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
            context, widget.searchText ?? '',
            type: LocationType.to);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 4),
            Text(
              'Select Location',
              style: textMedium.copyWith(
                color: const Color.fromRGBO(255, 255, 255, 1),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        leading: IconButton(
          iconSize: 20,
          icon: const Icon(Icons.arrow_back_ios_outlined,
              color: Color.fromRGBO(255, 255, 255, 1)),
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
          Container(
            height: 20,
            color: const Color.fromRGBO(255, 0, 0, 1),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child:
                GetBuilder<LocationController>(builder: (locationController) {
              return GetBuilder<RideController>(builder: (rideController) {
                return Stack(clipBehavior: Clip.none, children: [
                  SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Get.isDarkMode
                            ? Theme.of(context).primaryColorDark
                            : const Color.fromRGBO(255, 255, 255, 1),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeSmall),
                                          decoration: BoxDecoration(
                                            color: Get.isDarkMode
                                                ? Theme.of(context).cardColor
                                                : const Color.fromRGBO(
                                                    255, 255, 255, 1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: const Color.fromRGBO(
                                                  0, 0, 0, 0.1),
                                            ),
                                          ),
                                          child: Row(children: [
                                            InkWell(
                                                onTap: () {
                                                  if (rideController
                                                          .rideDetails !=
                                                      null) {
                                                    showCustomSnackBar(
                                                        'your_ride_is_ongoing_complete'
                                                            .tr,
                                                        isError: true);
                                                  } else {
                                                    RouteHelper
                                                        .goPageAndHideTextField(
                                                            context,
                                                            PickMapScreen(
                                                              type: LocationType
                                                                  .from,
                                                              oldLocationExist:
                                                                  locationController
                                                                              .pickPosition
                                                                              .latitude >
                                                                          0
                                                                      ? true
                                                                      : false,
                                                            ));
                                                  }
                                                },
                                                child: Image.asset(
                                                  Images.boxIconsLocation,
                                                  height: 20,
                                                  width: 20,
                                                )),
                                            const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeEight,
                                            ),
                                            Expanded(
                                                child: CustomSearchField(
                                                    isReadOnly: rideController
                                                                .rideDetails ==
                                                            null
                                                        ? false
                                                        : true,
                                                    focusNode:
                                                        pickLocationFocus,
                                                    controller: locationController
                                                        .pickupLocationController,
                                                    hint: 'pick_location'.tr,
                                                    onChanged: (value) async {
                                                      return await Get.find<
                                                              LocationController>()
                                                          .searchLocation(
                                                        context,
                                                        value,
                                                        type: LocationType.from,
                                                      );
                                                    },
                                                    onTap: () {
                                                      if (rideController
                                                              .rideDetails !=
                                                          null) {
                                                        showCustomSnackBar(
                                                            'your_ride_is_ongoing_complete'
                                                                .tr,
                                                            isError: true);
                                                      }
                                                    })),
                                          ]),
                                        ),
                                        if (locationController.extraOneRoute)
                                          Container(
                                            height: 50,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeSmall),
                                            decoration: BoxDecoration(
                                              color: Get.isDarkMode
                                                  ? Theme.of(context).cardColor
                                                  : Theme.of(context)
                                                      .primaryColorDark
                                                      .withValues(alpha: .25),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusSmall),
                                            ),
                                            child: Row(children: [
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall),
                                              Expanded(
                                                  child: CustomSearchField(
                                                      isReadOnly: rideController
                                                                  .rideDetails ==
                                                              null
                                                          ? false
                                                          : true,
                                                      controller: locationController
                                                          .extraRouteOneController,
                                                      hint:
                                                          'extra_route_one'.tr,
                                                      onChanged: (value) async {
                                                        return await Get.find<
                                                                LocationController>()
                                                            .searchLocation(
                                                          context,
                                                          value,
                                                          type: LocationType
                                                              .extraOne,
                                                        );
                                                      },
                                                      onTap: () {
                                                        if (rideController
                                                                .rideDetails !=
                                                            null) {
                                                          showCustomSnackBar(
                                                              'your_ride_is_ongoing_complete'
                                                                  .tr,
                                                              isError: true);
                                                        }
                                                      })),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall),
                                              InkWell(
                                                onTap: () {
                                                  if (rideController
                                                          .rideDetails !=
                                                      null) {
                                                    showCustomSnackBar(
                                                        'your_ride_is_ongoing_complete'
                                                            .tr,
                                                        isError: true);
                                                  } else {
                                                    RouteHelper
                                                        .goPageAndHideTextField(
                                                            context,
                                                            PickMapScreen(
                                                              type: LocationType
                                                                  .extraOne,
                                                              oldLocationExist:
                                                                  locationController
                                                                              .pickPosition
                                                                              .latitude >
                                                                          0
                                                                      ? true
                                                                      : false,
                                                            ));
                                                  }
                                                },
                                                child: Icon(
                                                  Icons.place_outlined,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.7),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () => locationController
                                                    .setExtraRoute(
                                                        remove: true),
                                                child: const Icon(Icons.clear,
                                                    color: Color.fromRGBO(
                                                        20, 20, 20, 0.7)),
                                              ),
                                            ]),
                                          ),
                                        SizedBox(
                                          height: locationController
                                                  .extraOneRoute
                                              ? Dimensions.paddingSizeDefault
                                              : 0,
                                        ),
                                        locationController.extraTwoRoute
                                            ? Container(
                                                height: 50,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: Dimensions
                                                      .paddingSizeSmall,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Get.isDarkMode
                                                      ? Theme.of(context)
                                                          .cardColor
                                                      : Theme.of(context)
                                                          .primaryColorDark
                                                          .withValues(
                                                              alpha: .25),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusSmall),
                                                ),
                                                child: Row(children: [
                                                  const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeExtraSmall),
                                                  Expanded(
                                                      child: CustomSearchField(
                                                          isReadOnly: rideController
                                                                      .rideDetails ==
                                                                  null
                                                              ? false
                                                              : true,
                                                          controller:
                                                              locationController
                                                                  .extraRouteTwoController,
                                                          hint:
                                                              'extra_route_two'
                                                                  .tr,
                                                          onChanged:
                                                              (value) async {
                                                            return await Get.find<
                                                                    LocationController>()
                                                                .searchLocation(
                                                              context,
                                                              value,
                                                              type: LocationType
                                                                  .extraTwo,
                                                            );
                                                          },
                                                          onTap: () {
                                                            if (rideController
                                                                    .rideDetails !=
                                                                null) {
                                                              showCustomSnackBar(
                                                                  'your_ride_is_ongoing_complete'
                                                                      .tr,
                                                                  isError:
                                                                      true);
                                                            }
                                                          })),
                                                  const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeSmall),
                                                  InkWell(
                                                    onTap: () {
                                                      if (rideController
                                                              .rideDetails !=
                                                          null) {
                                                        showCustomSnackBar(
                                                            'your_ride_is_ongoing_complete'
                                                                .tr,
                                                            isError: true);
                                                      } else {
                                                        RouteHelper
                                                            .goPageAndHideTextField(
                                                                context,
                                                                PickMapScreen(
                                                                  type: LocationType
                                                                      .extraTwo,
                                                                  oldLocationExist:
                                                                      locationController.pickPosition.latitude >
                                                                              0
                                                                          ? true
                                                                          : false,
                                                                ));
                                                      }
                                                    },
                                                    child: Icon(
                                                        Icons.place_outlined,
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.7)),
                                                  ),
                                                  InkWell(
                                                    onTap: () =>
                                                        locationController
                                                            .setExtraRoute(
                                                                remove: true),
                                                    child: const Icon(
                                                        Icons.clear,
                                                        color: Color.fromRGBO(
                                                            20, 20, 20, 0.7)),
                                                  ),
                                                ]),
                                              )
                                            : const SizedBox(),
                                        SizedBox(
                                            height: locationController
                                                    .extraTwoRoute
                                                ? Dimensions.paddingSizeDefault
                                                : 0),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeSixteen),
                                        Row(children: [
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeSmall),
                                              decoration: BoxDecoration(
                                                color: Get.isDarkMode
                                                    ? Theme.of(context)
                                                        .cardColor
                                                    : const Color.fromRGBO(
                                                        255, 255, 255, 1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      0, 0, 0, 0.1),
                                                ),
                                              ),
                                              child: Row(children: [
                                                locationController.selecting
                                                    ? const SpinKitCircle(
                                                        color: Color.fromRGBO(
                                                            250, 173, 2, 1),
                                                        size: 40.0)
                                                    : InkWell(
                                                        onTap: () {
                                                          if (rideController
                                                                  .rideDetails !=
                                                              null) {
                                                            showCustomSnackBar(
                                                                'your_ride_is_ongoing_complete'
                                                                    .tr,
                                                                isError: true);
                                                          } else {
                                                            RouteHelper
                                                                .goPageAndHideTextField(
                                                              context,
                                                              PickMapScreen(
                                                                type:
                                                                    LocationType
                                                                        .to,
                                                                oldLocationExist:
                                                                    locationController.pickPosition.latitude >
                                                                            0
                                                                        ? true
                                                                        : false,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        child: Image.asset(
                                                          Images.tablerLocation,
                                                          height: 20,
                                                          width: 20,
                                                        ),
                                                      ),
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeEight),
                                                Expanded(
                                                    child: CustomSearchField(
                                                        isReadOnly: rideController
                                                                    .rideDetails ==
                                                                null
                                                            ? false
                                                            : true,
                                                        focusNode:
                                                            destinationLocationFocus,
                                                        controller:
                                                            locationController
                                                                .destinationLocationController,
                                                        hint: 'destination'.tr,
                                                        onChanged:
                                                            (value) async {
                                                          return await Get.find<
                                                                  LocationController>()
                                                              .searchLocation(
                                                                  context,
                                                                  value.trim(),
                                                                  type:
                                                                      LocationType
                                                                          .to);
                                                        },
                                                        onTap: () {
                                                          if (rideController
                                                                  .rideDetails !=
                                                              null) {
                                                            showCustomSnackBar(
                                                                'your_ride_is_ongoing_complete'
                                                                    .tr,
                                                                isError: true);
                                                          }
                                                        })),
                                              ]),
                                            ),
                                          ),
                                          if (Get.find<ConfigController>()
                                                  .config!
                                                  .addIntermediatePoint! &&
                                              !locationController.extraTwoRoute)
                                            const SizedBox(
                                                width: Dimensions
                                                    .paddingSizeSmall),
                                          (!Get.find<ConfigController>()
                                                      .config!
                                                      .addIntermediatePoint! ||
                                                  locationController
                                                      .extraTwoRoute)
                                              ? const SizedBox()
                                              : InkWell(
                                                  onTap: () =>
                                                      locationController
                                                          .setExtraRoute(),
                                                  child: Container(
                                                    height: 40,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                      color: Get.isDarkMode
                                                          ? Theme.of(context)
                                                              .cardColor
                                                          : Colors.red,
                                                      borderRadius: BorderRadius
                                                          .circular(Dimensions
                                                              .paddingSizeExtraSmall),
                                                    ),
                                                    child: const Icon(Icons.add,
                                                        color: Color.fromRGBO(
                                                            20, 20, 20, 0.7)),
                                                  ),
                                                ),
                                        ]),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeSixteen),
                                        locationController.addEntrance
                                            ? SizedBox(
                                                width: 200,
                                                child: InputField(
                                                  showSuffix: false,
                                                  controller: locationController
                                                      .entranceController,
                                                  node: locationController
                                                      .entranceNode,
                                                  hint: 'enter_entrance'.tr,
                                                ))
                                            : InkWell(
                                                onTap: () => locationController
                                                    .setAddEntrance(),
                                                child: Row(children: [
                                                  Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        const Icon(Icons.add,
                                                            color:
                                                                Color.fromRGBO(
                                                                    20,
                                                                    20,
                                                                    20,
                                                                    0.7)),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          'add_entrance'.tr,
                                                          style: textMedium
                                                              .copyWith(
                                                            color: const Color
                                                                .fromRGBO(20,
                                                                20, 20, 0.8),
                                                            fontSize: Dimensions
                                                                .fontSizeLarge,
                                                          ),
                                                        ),
                                                      ]),
                                                ]),
                                              ),
                                      ])),
                                ]),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 16, bottom: 16),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'you_can_add_multiple_route_to'.tr,
                                      style: textMedium.copyWith(
                                        color: const Color.fromRGBO(
                                            20, 20, 20, 0.8),
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (Get.find<ConfigController>()
                                                    .config!
                                                    .maintenanceMode !=
                                                null &&
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
                                          showCustomSnackBar(
                                              'maintenance_mode_on_for_ride'.tr,
                                              isError: true);
                                        } else {
                                          if (locationController
                                                      .fromAddress ==
                                                  null ||
                                              locationController
                                                      .fromAddress!.address ==
                                                  null ||
                                              locationController.fromAddress!
                                                  .address!.isEmpty) {
                                            showCustomSnackBar(
                                                'pickup_location_is_required'
                                                    .tr);
                                            FocusScope.of(context).requestFocus(
                                                pickLocationFocus);
                                          } else if (locationController
                                              .pickupLocationController
                                              .text
                                              .isEmpty) {
                                            showCustomSnackBar(
                                                'pickup_location_is_required'
                                                    .tr);
                                            FocusScope.of(context).requestFocus(
                                                pickLocationFocus);
                                          } else if (locationController
                                                      .toAddress ==
                                                  null ||
                                              locationController
                                                      .toAddress!.address ==
                                                  null ||
                                              locationController.toAddress!
                                                  .address!.isEmpty) {
                                            showCustomSnackBar(
                                                'destination_location_is_required'
                                                    .tr);
                                            FocusScope.of(context).requestFocus(
                                                destinationLocationFocus);
                                          } else if (locationController
                                              .destinationLocationController
                                              .text
                                              .isEmpty) {
                                            showCustomSnackBar(
                                                'destination_location_is_required'
                                                    .tr);
                                            FocusScope.of(context).requestFocus(
                                                destinationLocationFocus);
                                          } else {
                                            rideController
                                                .getEstimatedFare(false)
                                                .then((value) {
                                              if (value.statusCode == 200) {
                                                Get.find<LocationController>()
                                                    .initAddLocationData();
                                                Get.to(() => const MapScreen(
                                                      fromScreen:
                                                          MapScreenType.ride,
                                                      isShowCurrentPosition:
                                                          false,
                                                    ));
                                                Get.find<RideController>()
                                                    .updateRideCurrentState(
                                                        RideState.initial);
                                              }
                                            });
                                            // Get.find<RideController>().getDirection();
                                          }
                                        }
                                      },
                                      child: rideController.loading
                                          ? const SpinKitCircle(
                                              color: Color.fromRGBO(
                                                  250, 173, 2, 1),
                                              size: 40.0)
                                          : Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 10),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFB300),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'done'.tr,
                                                style: textMedium.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                  color: const Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ]),
                            ),
                          ]),
                    ),
                  ])),
                  locationController.resultShow
                      ? Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () => locationController
                                .setSearchResultShowHide(show: false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                  color: Get.isDarkMode
                                      ? Theme.of(context).canvasColor
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.paddingSize),
                                  border: Border.all(
                                    color: const Color.fromRGBO(0, 0, 0, 0.1),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.1),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ]),
                              margin: EdgeInsets.fromLTRB(
                                  30, locationController.topPosition, 30, 0),
                              child: ListView.builder(
                                itemCount:
                                    locationController.predictionList.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Get.find<LocationController>()
                                          .setLocation(
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
                                      child: Row(children: [
                                        const Icon(Icons.location_on),
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
                                                fontSize:
                                                    Dimensions.fontSizeDefault,
                                              ),
                                        )),
                                      ]),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ]);
              });
            }),
          ),
        ],
      ),
    );
  }
}
