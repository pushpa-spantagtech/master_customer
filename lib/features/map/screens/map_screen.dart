import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/features/map/widget/custom_icon_card.dart';
import 'package:ride_sharing_user_app/features/map/widget/discount_coupon_bottomsheet.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/parcel_expendable_bottom_sheet.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/ride_expendable_bottom_sheet.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

enum MapScreenType { ride, splash, parcel, location }

class MapScreen extends StatefulWidget {
  final MapScreenType fromScreen;
  final bool isShowCurrentPosition;
  const MapScreen(
      {super.key, required this.fromScreen, this.isShowCurrentPosition = true});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  GlobalKey<ExpandableBottomSheetState> key =
      GlobalKey<ExpandableBottomSheetState>();

  @override
  void initState() {
    super.initState();
    Get.find<MapController>().setContainerHeight(
        (widget.fromScreen == MapScreenType.parcel) ? 200 : 260, false);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    Get.find<MapController>().mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (value) {
        if (Navigator.canPop(context)) {
          Future.delayed(const Duration(milliseconds: 500)).then((onValue) {
            if (Get.find<RideController>().currentRideState.name ==
                    'findingRider' ||
                Get.find<ParcelController>().currentParcelState.name ==
                    'findingRider') {
              Get.offAll(() => const DashboardScreen());
            }
          });
        } else {
          Get.offAll(() => const DashboardScreen());
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
          elevation: 0,
          centerTitle: true,
          titleSpacing: 0,
          title: Row(
            children: [
              const SizedBox(width: 4),
              Text(
                'the_deliveryman_need_you'.tr,
                style: textMedium.copyWith(
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  fontSize: 16,
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
                if (Get.find<RideController>().currentRideState.name ==
                        'findingRider' ||
                    Get.find<ParcelController>().currentParcelState.name ==
                        'findingRider') {
                  Get.offAll(() => const DashboardScreen());
                } else {
                  Get.back();
                }
              } else {
                Get.offAll(() => const DashboardScreen());
              }
            },
          ),
        ),
        body: Column(children: [
          GetBuilder<MapController>(builder: (mapController) {
            return Flexible(
              child: ExpandableBottomSheet(
                key: key,
                background:
                    GetBuilder<RideController>(builder: (rideController) {
                  return Stack(children: [
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: mapController.sheetHeight - 20),
                      child: GoogleMap(
                          style: Get.isDarkMode
                              ? Get.find<ThemeController>().darkMap
                              : Get.find<ThemeController>().lightMap,
                          initialCameraPosition: CameraPosition(
                            target:
                                rideController.tripDetails?.pickupCoordinates !=
                                        null
                                    ? LatLng(
                                        rideController.tripDetails!
                                            .pickupCoordinates!.coordinates![1],
                                        rideController.tripDetails!
                                            .pickupCoordinates!.coordinates![0],
                                      )
                                    : Get.find<LocationController>()
                                        .initialPosition,
                            zoom: 16,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            mapController.mapController = controller;
                            if (Get.find<RideController>()
                                        .currentRideState
                                        .name ==
                                    'findingRider' ||
                                Get.find<RideController>()
                                        .currentRideState
                                        .name ==
                                    'riseFare') {
                              Get.find<MapController>().initializeData();
                              Get.find<MapController>().setOwnCurrentLocation();
                            } else if (Get.find<RideController>()
                                    .currentRideState
                                    .name ==
                                'initial') {
                              mapController.getPolyline();
                            } else if (Get.find<RideController>()
                                    .currentRideState
                                    .name ==
                                'completeRide') {
                              Get.find<MapController>().initializeData();
                            } else {
                              Get.find<MapController>().initializeData();
                              Get.find<MapController>()
                                  .setMarkersInitialPosition();
                              Get.find<RideController>().startLocationRecord();
                            }
                            _mapController = controller;
                          },
                          minMaxZoomPreference: const MinMaxZoomPreference(
                              0, AppConstants.mapZoom),
                          markers: Set<Marker>.of(mapController.markers),
                          polylines:
                              Set<Polyline>.of(mapController.polylines.values),
                          zoomControlsEnabled: false,
                          compassEnabled: false,
                          trafficEnabled: mapController.isTrafficEnable,
                          indoorViewEnabled: true,
                          mapToolbarEnabled: true),
                    ),
                    if (widget.isShowCurrentPosition)
                      Positioned(
                        bottom: Get.height * 0.34,
                        right: 0,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: GetBuilder<LocationController>(
                              builder: (locationController) {
                            return CustomIconCard(
                              index: 5,
                              icon: Images.currentLocation,
                              iconColor: const Color.fromRGBO(250, 173, 2, 1),
                              onTap: () async {
                                await locationController.getCurrentLocation(
                                    mapController: _mapController);
                                await _mapController
                                    ?.moveCamera(CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                      target: Get.find<LocationController>()
                                          .initialPosition,
                                      zoom: 16),
                                ));
                              },
                            );
                          }),
                        ),
                      ),
                    Positioned(
                      bottom: Get.height * 0.41,
                      right: 0,
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: CustomIconCard(
                            icon: mapController.isTrafficEnable
                                ? Images.trafficOnlineIcon
                                : Images.trafficOfflineIcon,
                            iconColor: mapController.isTrafficEnable
                                ? Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                : Theme.of(context).hintColor,
                            index: 2,
                            onTap: () => mapController.toggleTrafficView(),
                          )),
                    ),
                    Positioned(
                        bottom: Get.height * 0.48,
                        right: 0,
                        child: Align(
                            alignment: Alignment.bottomRight,
                            child: CustomIconCard(
                              icon: Images.offerMapIcon,
                              index: 2,
                              onTap: () {
                                Get.bottomSheet(
                                  const DiscountAndCouponBottomSheet(),
                                  backgroundColor: Theme.of(context).cardColor,
                                  isDismissible: false,
                                );
                              },
                            ))),
                  ]);
                }),
                persistentContentHeight: mapController.sheetHeight,
                expandableContent:
                    Column(mainAxisSize: MainAxisSize.min, children: [
                  widget.fromScreen == MapScreenType.parcel
                      ? GetBuilder<RideController>(builder: (parcelController) {
                          return ParcelExpendableBottomSheet(
                              expandableKey: key);
                        })
                      : (widget.fromScreen == MapScreenType.ride ||
                              widget.fromScreen == MapScreenType.splash)
                          ? GetBuilder<RideController>(
                              builder: (rideController) {
                              return RideExpendableBottomSheet(
                                  expandableKey: key);
                            })
                          : const SizedBox(),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ]),
              ),
            );
          }),
          widget.fromScreen == MapScreenType.location
              ? Positioned(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                        height: 70,
                        child: Padding(
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault),
                          child: ButtonWidget(
                              buttonText: 'set_location'.tr,
                              onPressed: () => Get.back()),
                        )),
                  ),
                )
              : const SizedBox(),
        ]),
      ),
    );
  }
}
