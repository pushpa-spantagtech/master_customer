import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:ride_sharing_user_app/features/home/controllers/banner_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/banner_shimmer.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/my_offer/controller/offer_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/widget/custom_title.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

class HomeMapView extends StatefulWidget {
  final String? title;
  final bool fullScreen;

  const HomeMapView({super.key, this.title, this.fullScreen = false});

  @override
  HomeMapViewState createState() => HomeMapViewState();
}

class HomeMapViewState extends State<HomeMapView> {
  GoogleMapController? _mapController;
  int isFirstCount = 0;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapController>(builder: (mapController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        final Completer<GoogleMapController> mapCompleter =
            Completer<GoogleMapController>();
        if (mapController.mapController != null && !mapCompleter.isCompleted) {
          mapCompleter.complete(mapController.mapController);
        }

        final double mapHeight = widget.fullScreen
            ? Get.height
            : ((Get.find<BannerController>().bannerList != null &&
                        Get.find<BannerController>().bannerList!.isNotEmpty) ||
                    (Get.find<OfferController>().bestOfferModel != null &&
                        Get.find<OfferController>().bestOfferModel!.data !=
                            null &&
                        Get.find<OfferController>()
                            .bestOfferModel!
                            .data!
                            .isNotEmpty) ||
                    (Get.find<CouponController>().couponModel != null &&
                        Get.find<CouponController>().couponModel!.data !=
                            null &&
                        Get.find<CouponController>()
                            .couponModel!
                            .data!
                            .isNotEmpty)
                ? Get.height * 0.75
                : Get.height * 0.55);

        if (mapController.nearestDeliveryManMarkers == null) {
          return SizedBox(height: mapHeight, child: const BannerShimmer());
        }

        final position = locationController.position;
        final bool hasFreshPosition =
            position.latitude != 0 && position.longitude != 0;

        // Never open the map at the saved address and then jump to GPS.
        // This loader waits only for the first GPS coordinate; all other Home
        // APIs and nearby-car loading continue independently.
        if (!hasFreshPosition) {
          return SizedBox(height: mapHeight, child: const BannerShimmer());
        }

        final LatLng initialTarget = LatLng(
          position.latitude,
          position.longitude,
        );

        Widget map = GoogleMap(
          style: Get.isDarkMode
              ? Get.find<ThemeController>().darkMap
              : Get.find<ThemeController>().lightMap,
          markers: mapController.nearestDeliveryManMarkers!.toSet(),
          initialCameraPosition:
              CameraPosition(target: initialTarget, zoom: 15.5),
          minMaxZoomPreference: const MinMaxZoomPreference(0, 18),
          onMapCreated: (gController) {
            _mapController = gController;
            calculateCenterBound(
                initialTarget.latitude, initialTarget.longitude);
            mapController.setMapController(gController);
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          compassEnabled: false,
        );

        if (widget.fullScreen) {
          return Stack(
            children: [
              Positioned.fill(child: map),
              Positioned(
                right: 18,
                bottom: Get.height * 0.48,
                child: _FloatingMapButton(
                  icon: Icons.my_location_rounded,
                  onTap: () async {
                    await locationController.getCurrentLocation(
                        mapController: _mapController);
                    await _mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                            target:
                                Get.find<LocationController>().initialPosition,
                            zoom: 16),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return Column(children: [
          if (widget.title != null) ...[
            CustomTitle(
              title: widget.title!.tr,
              color: Theme.of(context).textTheme.bodyLarge!.color,
              fontSize: Dimensions.fontSizeDefault,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],
          Container(
            height: mapHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
              border: Border.all(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.35)),
            ),
            child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(Dimensions.paddingSizeSmall),
                child: map),
          ),
        ]);
      });
    });
  }

  LatLng calculateCenterBound(double lat, double lng) {
    double searchRadius =
        (Get.find<ConfigController>().config?.searchRadius ?? 0) / 2;
    List<LatLng> list = [];
    list.add(calculateOffset(LatLng(lat, lng), searchRadius, 270));
    list.add(calculateOffset(LatLng(lat, lng), searchRadius, 90));
    list.add(calculateOffset(LatLng(lat, lng), searchRadius, 180));
    list.add(calculateOffset(LatLng(lat, lng), searchRadius, 360));
    LatLngBounds bounds =
        Get.find<MapController>().boundWithMaximumLatLngPoint(list);
    LatLng centerBounds = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );

    if (isFirstCount == 0) {
      isFirstCount++;
      Get.find<MapController>()
          .zoomToFit(_mapController, bounds, centerBounds, 0);
    }
    return centerBounds;
  }

  LatLng calculateOffset(LatLng center, double distance, double bearing) {
    const double earthRadius = 6371.0;
    double radLat = radians(center.latitude);
    double radLon = radians(center.longitude);
    double radBearing = radians(bearing);
    double newLat = asin(sin(radLat) * cos(distance / earthRadius) +
        cos(radLat) * sin(distance / earthRadius) * cos(radBearing));
    double newLon = radLon +
        atan2(sin(radBearing) * sin(distance / earthRadius) * cos(radLat),
            cos(distance / earthRadius) - sin(radLat) * sin(newLat));
    return LatLng(degrees(newLat), degrees(newLon));
  }

  double radians(double degrees) => degrees * pi / 180;

  double degrees(double radians) => radians * 180 / pi;
}

class _FloatingMapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FloatingMapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 20,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: Icon(icon, color: const Color(0xFFE71921), size: 24),
        ),
      ),
    );
  }
}
