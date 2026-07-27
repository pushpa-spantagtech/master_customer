import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'dart:math' as math;

class MapController extends GetxController implements GetxService {
  Set<Marker>? nearestDeliveryManMarkers = <Marker>{};
  bool _isLoading = false;
  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> markers = HashSet<Marker>();
  GoogleMapController? mapController;
  Uint8List? _cachedCarIcon;
  Uint8List? _cachedBikeIcon;
  List<LatLng> _polylineCoordinateList = [];

  // Prevent the same pickup-to-destination route from being rebuilt and
  // rebound every 5 seconds when ride status polling returns unchanged data.
  String _lastMainRoutePolyline = '';

  bool isTrafficEnable = false;

  bool get isLoading => _isLoading;

  @override
  void onInit() {
    initializeData();
    super.onInit();
  }

  void initializeData() {
    markers = {};
    polylines = {};
    _lastMainRoutePolyline = '';
    _isLoading = false;
  }

  void notifyMapController() {
    update();
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> fitRouteToScreen(List<LatLng> points) async {
    if (mapController == null || points.isEmpty) return;

    try {
      final LatLngBounds bounds = boundWithMaximumLatLngPoint(points);

      await mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 120),
      );

      await Future.delayed(const Duration(milliseconds: 300));

      await mapController!.animateCamera(
        CameraUpdate.scrollBy(0, 180),
      );
    } catch (e) {
      // ignore
    }
  }

  Future<void> getPolyline() async {
    final String encoded = Get.find<RideController>().encodedPolyLine.trim();

    if (encoded.isEmpty) return;

    // ride-resume-status is called every 5 seconds. Do not rebuild the same
    // route, clear markers, or refit the camera when nothing changed.
    if (_lastMainRoutePolyline == encoded && polylines.isNotEmpty) {
      return;
    }

    final List<LatLng> result = decodeEncodedPolyline(encoded);
    if (result.isEmpty) return;

    final List<LatLng> polylineCoordinates =
        result.map((point) => LatLng(point.latitude, point.longitude)).toList();

    _lastMainRoutePolyline = encoded;
    _polylineCoordinateList = polylineCoordinates;
    _addPolyLine(polylineCoordinates);

    await setFromToMarker(
      polylineCoordinates.first,
      polylineCoordinates.last,
      latLongList: polylineCoordinates,
    );
  }

  List<LatLng> decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  void _addPolyLine(List<LatLng> coordinates) {
    if (coordinates.length < 2) {
      polylines = {};
      return;
    }

    // Same three-color route format used in the driver app.
    final List<Color> routeColors = [
      const Color(0xFFE71921),
      const Color(0xFFFF9800),
      const Color(0xFFFFC107),
    ];

    final Map<PolylineId, Polyline> updatedPolylines = {};
    final int sectionSize =
        math.max(2, (coordinates.length / routeColors.length).ceil());

    for (int index = 0; index < routeColors.length; index++) {
      final int startIndex = index * sectionSize;

      if (startIndex >= coordinates.length - 1) {
        break;
      }

      final int endIndex = math.min(
        startIndex + sectionSize,
        coordinates.length - 1,
      );

      final List<LatLng> sectionPoints = coordinates.sublist(
        startIndex,
        endIndex + 1,
      );

      final PolylineId id = PolylineId('route_section_$index');

      updatedPolylines[id] = Polyline(
        polylineId: id,
        points: sectionPoints,
        width: 5,
        color: routeColors[index],
        geodesic: true,
        startCap: index == 0 ? Cap.roundCap : Cap.buttCap,
        endCap: index == routeColors.length - 1 ? Cap.roundCap : Cap.buttCap,
        jointType: JointType.round,
        zIndex: 20,
      );
    }

    // Assign once so GoogleMap receives one clean polyline update.
    polylines = updatedPolylines;
  }

  Future<void> searchDeliveryMen() async {
    final Uint8List carMarkerIcon =
        await convertAssetToUnit8List(Images.carTop, width: 40);
    final Uint8List bikeMarkerIcon =
        await convertAssetToUnit8List(Images.bikeTop, width: 40);
    nearestDeliveryManMarkers = {};
    for (int i = 0;
        i < Get.find<RideController>().nearestDriverList.length;
        i++) {
      MarkerId markerId = MarkerId('rider_$i');
      nearestDeliveryManMarkers!.add(Marker(
        markerId: markerId,
        visible: true,
        draggable: false,
        zIndexInt: 2,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        position: LatLng(
            double.parse(
                Get.find<RideController>().nearestDriverList[i].latitude!),
            double.parse(
                Get.find<RideController>().nearestDriverList[i].longitude!)),
        icon: BitmapDescriptor.fromBytes(
            Get.find<RideController>().nearestDriverList[i].category ==
                    'motor_bike'
                ? bikeMarkerIcon
                : carMarkerIcon),
      ));
    }
    update();
  }

  double sheetHeight = 0;

  void setContainerHeight(double height, bool notify) {
    sheetHeight = height;
    if (notify) {
      update();
    }
  }

  Future<void> setFromToMarker(
    LatLng from,
    LatLng to, {
    bool isBound = true,
    required List<LatLng> latLongList,
  }) async {
    markers = HashSet();

    Uint8List fromMarker =
        await convertAssetToUnit8List(Images.mapIcon, width: 50);
    Uint8List toMarker =
        await convertAssetToUnit8List(Images.mapLocationIcon, width: 50);

    markers.add(Marker(
      markerId: const MarkerId('from'),
      position: from,
      anchor: const Offset(0.5, 0.5),
      infoWindow: InfoWindow(
        title: Get.find<RideController>().tripDetails?.pickupAddress ?? '',
        snippet: 'pick_up_location'.tr,
      ),
      icon: BitmapDescriptor.fromBytes(fromMarker),
    ));

    markers.add(Marker(
      markerId: const MarkerId('to'),
      position: to,
      anchor: const Offset(0.5, 0.5),
      infoWindow: InfoWindow(
        title: Get.find<RideController>().tripDetails?.destinationAddress ?? '',
        snippet: 'destination'.tr,
      ),
      icon: BitmapDescriptor.fromBytes(toMarker),
    ));

    update();

    if (isBound) {
      await fitRouteToScreen(latLongList);
    }
  }

  void updateMarkerAndCircle({LatLng? latLng}) async {
    markers.removeWhere((marker) => marker.markerId.value == "my_location");

    Uint8List car = await convertAssetToUnit8List(
      Get.find<RideController>().tripDetails!.vehicleCategory!.type == 'car'
          ? Images.carTop
          : Images.bike,
      width: 55,
    );
    if (Get.find<RideController>().tripDetails != null &&
        _polylineCoordinateList.isNotEmpty) {
      markers.add(Marker(
        markerId: const MarkerId('my_location'),
        position: latLng ?? _polylineCoordinateList.first,
        rotation: _calculateBearing(
          _polylineCoordinateList.first,
          _polylineCoordinateList.length > 1
              ? _polylineCoordinateList[1]
              : _polylineCoordinateList.last,
        ),
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(car),
      ));

      // markers.add(Marker(
      //   markerId: const MarkerId('my_location'),
      //   position: latLng ?? _polylineCoordinateList.first,
      //   rotation: 0,
      //   draggable: false,
      //   zIndex: 2,
      //   flat: false,
      //   anchor: const Offset(0.5, 1),
      //   icon: BitmapDescriptor.fromBytes(car),
      // ));
      update();
    }
  }

  double _calculateBearing(LatLng startPoint, LatLng endPoint) {
    final double startLat = _toRadians(startPoint.latitude);
    final double startLng = _toRadians(startPoint.longitude);
    final double endLat = _toRadians(endPoint.latitude);
    final double endLng = _toRadians(endPoint.longitude);

    final double deltaLng = endLng - startLng;

    final double y = math.sin(deltaLng) * math.cos(endLat);
    final double x = math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(deltaLng);

    final double bearing = math.atan2(y, x);

    return (_toDegrees(bearing) + 360) % 360;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180.0);

  double _toDegrees(double radians) => radians * (180.0 / math.pi);

  Future<Uint8List> convertAssetToUnit8List(String imagePath,
      {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds,
      LatLng centerBounds, double bearing,
      {double padding = 0.5}) async {
    bool keepZoomingOut = true;
    while (keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if (fits(bounds!, screenBounds)) {
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
          bearing: bearing,
        )));
        break;
      } else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck =
        screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck =
        screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck =
        screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck =
        screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck &&
        northEastLongitudeCheck &&
        southWestLatitudeCheck &&
        southWestLongitudeCheck;
  }

  void setOwnCurrentLocation() async {
    markers.removeWhere(
      (marker) => marker.markerId.value == "my_location",
    );

    update();
  }

  // void setOwnCurrentLocation() async {
  //   markers.removeWhere((marker) => marker.markerId.value == "my_location");
  //
  //   Uint8List myIcon =
  //   await convertAssetToUnit8List(Images.mapLocationIcon, width: 70);
  //
  //   LatLng? latlng = await Get.find<LocationController>().getCurrentPosition();
  //
  //   if (latlng != null) {
  //     markers.add(Marker(
  //         markerId: const MarkerId("my_location"),
  //         position: latlng,
  //         draggable: false,
  //         zIndexInt: 2,
  //         flat: true,
  //         anchor: const Offset(0.5, 0.5),
  //         icon: BitmapDescriptor.bytes(myIcon)));
  //
  //     if (mapController != null) {
  //       mapController!.animateCamera(CameraUpdate.newCameraPosition(
  //           CameraPosition(
  //               bearing: 192.8334901395799,
  //               target: latlng,
  //               tilt: 0,
  //               zoom: 16)));
  //     }
  //   }
  //   update();
  // }

  Future<void> getDriverToPickupOrDestinationPolyline(
    String lines, {
    bool mapBound = false,
  }) async {
    if (lines.isEmpty) return;

    final List<LatLng> result = decodeEncodedPolyline(lines);
    if (result.isEmpty) return;

    final List<LatLng> polylineCoordinates =
        result.map((point) => LatLng(point.latitude, point.longitude)).toList();

    final RideController rideController = Get.find<RideController>();

    isInsideCircle(
      result.first.latitude,
      result.first.longitude,
      result.last.latitude,
      result.last.longitude,
      Get.find<ConfigController>().config!.completionRadius!,
    );

    _polylineCoordinateList = polylineCoordinates;
    _addPolyLine(polylineCoordinates);

    if (rideController.currentRideState == RideState.ongoingRide) {
      markers.removeWhere(
        (marker) =>
            marker.markerId.value == 'from' ||
            marker.markerId.value == 'my_location',
      );
    }

    await updateDriverMarker(polylineCoordinates);

    // Rebuild map only once after polyline and marker are ready.
    update();

    if (mapBound) {
      await boundMapScreen(result.first, result.last);
    }
  }

  Future<void> updateDriverMarker(List<LatLng> latLngList) async {
    final RideController rideController = Get.find<RideController>();

    if (rideController.tripDetails == null || latLngList.isEmpty) {
      return;
    }

    LatLng driverPosition = latLngList.first;
    final liveLocation = rideController.tripDetails?.driverLastLocation;

    if (liveLocation?.latitude != null && liveLocation?.longitude != null) {
      final double? latitude =
          double.tryParse(liveLocation!.latitude.toString());
      final double? longitude =
          double.tryParse(liveLocation.longitude.toString());

      if (latitude != null && longitude != null) {
        driverPosition = LatLng(latitude, longitude);
      }
    }

    final bool isCar =
        rideController.tripDetails?.vehicleCategory?.type == 'car';

    if (isCar) {
      _cachedCarIcon ??=
          await convertAssetToUnit8List(Images.carTop, width: 55);
    } else {
      _cachedBikeIcon ??= await convertAssetToUnit8List(Images.bike, width: 55);
    }

    final BitmapDescriptor icon = BitmapDescriptor.fromBytes(
      isCar ? _cachedCarIcon! : _cachedBikeIcon!,
    );

    markers.removeWhere(
      (marker) => marker.markerId.value == 'driverPosition',
    );

    final LatLng bearingTarget =
        latLngList.length > 1 ? latLngList[1] : driverPosition;

    markers.add(
      Marker(
        markerId: const MarkerId('driverPosition'),
        position: driverPosition,
        rotation: _calculateBearing(driverPosition, bearingTarget),
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        icon: icon,
      ),
    );

    print(
      'LIVE DRIVER = '
      '${driverPosition.latitude}, ${driverPosition.longitude}',
    );
    print('MARKER UPDATED');
  }

  bool _isInside = false;

  bool get isInside => _isInside;

  double distanceBetween(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    double distance = Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
    return distance; // Distance in meters
  }

  void isInsideCircle(double lat, double lng, double latCenter,
      double lngCenter, double radius) {
    // Calculate the distance between two points using Haversine formula
    double distance = distanceBetween(lat, lng, latCenter, lngCenter);
    // Check if the distance is less than or equal to the radius
    _isInside = (distance <= radius) ? true : false;
  }

  void setMarkersInitialPosition() {
    if (Get.find<RideController>().encodedPolyLine.isEmpty) return;

    final List<LatLng> routePoints =
        decodeEncodedPolyline(Get.find<RideController>().encodedPolyLine);

    if (routePoints.isEmpty) return;

    if (Get.find<RideController>().currentRideState == RideState.ongoingRide) {
      _setOngoingDestinationMarker(routePoints.last);
      return;
    }

    setFromToMarker(
      routePoints.first,
      routePoints.last,
      isBound: false,
      latLongList: routePoints,
    );
  }

  Future<void> _setOngoingDestinationMarker(LatLng destination) async {
    markers.removeWhere(
      (marker) =>
          marker.markerId.value == 'from' ||
          marker.markerId.value == 'to' ||
          marker.markerId.value == 'my_location',
    );

    final Uint8List toMarker =
        await convertAssetToUnit8List(Images.mapLocationIcon, width: 50);

    markers.add(
      Marker(
        markerId: const MarkerId('to'),
        position: destination,
        anchor: const Offset(0.5, 0.5),
        infoWindow: InfoWindow(
          title:
              Get.find<RideController>().tripDetails?.destinationAddress ?? '',
          snippet: 'destination'.tr,
        ),
        icon: BitmapDescriptor.fromBytes(toMarker),
      ),
    );

    update();
  }

  Future<void> boundMapScreen(
    LatLng startingPoint,
    LatLng endingPoint,
  ) async {
    await fitRouteToScreen([startingPoint, endingPoint]);
  }

  LatLngBounds boundWithMaximumLatLngPoint(List<LatLng> list) {
    assert(list.isNotEmpty);
    var firstLatLng = list.first;
    var s = firstLatLng.latitude,
        n = firstLatLng.latitude,
        w = firstLatLng.longitude,
        e = firstLatLng.longitude;
    for (var i = 1; i < list.length; i++) {
      var latlng = list[i];
      s = min(s, latlng.latitude);
      n = max(n, latlng.latitude);
      w = min(w, latlng.longitude);
      e = max(e, latlng.longitude);
    }
    return LatLngBounds(southwest: LatLng(s, w), northeast: LatLng(n, e));
  }

  void toggleTrafficView() {
    isTrafficEnable = !isTrafficEnable;
    update();
  }
}
