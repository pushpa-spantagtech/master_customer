import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/widget/discount_coupon_bottomsheet.dart';
import 'package:ride_sharing_user_app/features/my_offer/controller/offer_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/parcel_expendable_bottom_sheet.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/ride_expendable_bottom_sheet.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

enum MapScreenType { ride, splash, parcel, location }

class MapScreen extends StatefulWidget {
  final MapScreenType fromScreen;
  final bool isShowCurrentPosition;

  const MapScreen({
    super.key,
    required this.fromScreen,
    this.isShowCurrentPosition = true,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _lastCameraTarget;
  late final RideController _rideController;
  bool _isMovingToCurrentLocation = false;
  final GlobalKey<ExpandableBottomSheetState> key =
      GlobalKey<ExpandableBottomSheetState>();

  static const Color _brandRed = Color(0xFFE71921);
  static const Color _brandGold = Color(0xFFFFB100);
  static const Color _ink = Color(0xFF121A2C);

  @override
  void initState() {
    super.initState();

    _rideController = Get.find<RideController>();

    Get.find<MapController>().setContainerHeight(390.0, false);
  }

  @override
  void dispose() {
    final mapController = Get.find<MapController>();

    if (identical(mapController.mapController, _mapController)) {
      mapController.mapController = null;
    }

    _mapController?.dispose();
    _mapController = null;

    super.dispose();
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      if (Get.find<RideController>().currentRideState.name == 'findingRider' ||
          Get.find<ParcelController>().currentParcelState.name ==
              'findingRider') {
        Get.offAll(() => const DashboardScreen());
      } else {
        Get.back();
      }
    } else {
      Get.offAll(() => const DashboardScreen());
    }
  }

  Future<void> _moveToCurrentLocation() async {
    if (_isMovingToCurrentLocation) return;

    _isMovingToCurrentLocation = true;

    try {
      final GoogleMapController? controller =
          _mapController ?? Get.find<MapController>().mapController;

      if (controller == null) return;

      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return;
      }

      if (permission == LocationPermission.denied) return;

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 18,
            bearing: 0,
            tilt: 0,
          ),
        ),
      );
    } on TimeoutException {
      debugPrint('Current GPS location timed out');
    } catch (error) {
      debugPrint('Move to current location error: $error');
    } finally {
      _isMovingToCurrentLocation = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: PopScope(
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
          backgroundColor: Colors.white,
          body: Column(
            children: [
              GetBuilder<MapController>(builder: (mapController) {
                return Flexible(
                  child: ExpandableBottomSheet(
                    key: key,
                    background: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 0,
                          ),
                          child: GoogleMap(
                            zoomGesturesEnabled: true,
                            scrollGesturesEnabled: true,
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            compassEnabled: false,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            style: Get.isDarkMode
                                ? Get.find<ThemeController>().darkMap
                                : Get.find<ThemeController>().lightMap,
                            initialCameraPosition: CameraPosition(
                              target: _rideController
                                          .tripDetails?.pickupCoordinates !=
                                      null
                                  ? LatLng(
                                      _rideController.tripDetails!
                                          .pickupCoordinates!.coordinates![1],
                                      _rideController.tripDetails!
                                          .pickupCoordinates!.coordinates![0],
                                    )
                                  : Get.find<LocationController>()
                                      .initialPosition,
                              zoom: 16,
                            ),
                            onCameraMove: (CameraPosition position) {
                              _lastCameraTarget = position.target;
                            },
                            onCameraIdle: () async {
                              // IMPORTANT:
                              // Do not update pickup/source location here.
                              // Camera movement should only store the last visible map center.
                              // Pickup must change only from search/current-location/confirm-location actions.
                              if (_lastCameraTarget == null) return;

                              print(
                                  "MAP CAMERA IDLE LAT = ${_lastCameraTarget!.latitude}");
                              print(
                                  "MAP CAMERA IDLE LNG = ${_lastCameraTarget!.longitude}");
                            },
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
                                Get.find<MapController>()
                                    .setOwnCurrentLocation();
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
                              }
                              _mapController = controller;
                            },
                            minMaxZoomPreference: const MinMaxZoomPreference(
                              0,
                              AppConstants.mapZoom,
                            ),
                            markers: Set<Marker>.of(mapController.markers),
                            polylines: Set<Polyline>.of(
                                mapController.polylines.values),
                            zoomControlsEnabled: false,
                            trafficEnabled: mapController.isTrafficEnable,
                            indoorViewEnabled: true,
                            mapToolbarEnabled: true,
                          ),
                        ),

                        // A subtle map shade makes the floating header readable
                        // without hiding the map.
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 150,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.92),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: MediaQuery.of(context).padding.top + 10,
                          left: 16,
                          right: 16,
                          child: _PremiumMapHeader(onBack: _handleBack),
                        ),

                        Positioned(
                          top: MediaQuery.of(context).padding.top + 84,
                          left: 18,
                          child: _LocationPill(
                            text: Get.find<LocationController>()
                                    .fromAddress
                                    ?.address ??
                                'current_location'.tr,
                          ),
                        ),

                        if (widget.isShowCurrentPosition)
                          Positioned(
                            bottom: mapController.sheetHeight + 18,
                            right: 18,
                            child: GetBuilder<LocationController>(
                              builder: (locationController) {
                                return _MapCircleButton(
                                  icon: Icons.my_location_rounded,
                                  color: _brandGold,
                                  onTap: _moveToCurrentLocation,
                                );
                              },
                            ),
                          ),
                        Positioned(
                          bottom: mapController.sheetHeight + 76,
                          right: 18,
                          child: _MapCircleButton(
                            icon: mapController.isTrafficEnable
                                ? Icons.traffic_rounded
                                : Icons.traffic_outlined,
                            color: mapController.isTrafficEnable
                                ? _brandRed
                                : Colors.black54,
                            onTap: () => mapController.toggleTrafficView(),
                          ),
                        ),
                        Positioned(
                          bottom: mapController.sheetHeight + 134,
                          right: 18,
                          child: _MapCouponButton(
                            onTap: () async {
                              await Future.wait([
                                Get.find<CouponController>()
                                    .getCouponList(1, isUpdate: false),
                                Get.find<OfferController>().getOfferList(1),
                              ]);
                              if (!mounted) return;
                              Get.bottomSheet(
                                const DiscountAndCouponBottomSheet(),
                                backgroundColor: Theme.of(context).cardColor,
                                isDismissible: false,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    persistentContentHeight: mapController.sheetHeight,
                    expandableContent: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.fromScreen == MapScreenType.parcel
                            ? GetBuilder<RideController>(
                                builder: (parcelController) {
                                return ParcelExpendableBottomSheet(
                                  expandableKey: key,
                                );
                              })
                            : (widget.fromScreen == MapScreenType.ride ||
                                    widget.fromScreen == MapScreenType.splash)
                                ? GetBuilder<RideController>(
                                    builder: (rideController) {
                                    return RideExpendableBottomSheet(
                                      expandableKey: key,
                                    );
                                  })
                                : const SizedBox(),
                        SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom),
                      ],
                    ),
                  ),
                );
              }),
              widget.fromScreen == MapScreenType.location
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 70,
                        child: Padding(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeDefault,
                          ),
                          child: ButtonWidget(
                            buttonText: 'set_location'.tr,
                            onPressed: () => Get.back(),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumMapHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _PremiumMapHeader({required this.onBack});

  static const Color _ink = Color(0xFF121A2C);
  static const Color _brandRed = Color(0xFFE71921);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _HeaderIconButton(
            icon: Icons.menu_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Center(
              child: Image.asset(
                Images.logoWithName,
                height: 42,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _HeaderIconButton(
                icon: Icons.notifications_none_rounded,
                onTap: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _brandRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: const Color(0xFF121A2C), size: 24),
      ),
    );
  }
}

class _MapCircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MapCircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 23),
        ),
      ),
    );
  }
}

class _MapCouponButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MapCouponButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8EBF0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_offer_outlined,
                color: Color(0xFFE71921),
                size: 21,
              ),
              const SizedBox(width: 7),
              Text(
                'coupons'.tr,
                style: textBold.copyWith(
                  color: const Color(0xFF121A2C),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationPill extends StatelessWidget {
  final String text;

  const _LocationPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: Get.width * 0.74),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textMedium.copyWith(
                color: const Color(0xFF121A2C),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
