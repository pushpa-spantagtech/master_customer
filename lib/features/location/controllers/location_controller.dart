import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/local_ride_bottom_sheet.dart';
import 'package:ride_sharing_user_app/features/location/domain/models/place_details_model.dart';
import 'package:ride_sharing_user_app/features/location/domain/models/prediction_model.dart';
import 'package:ride_sharing_user_app/features/location/domain/models/zone_response.dart';
import 'package:ride_sharing_user_app/features/location/domain/services/location_service_interface.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/confirmation_dialog_widget.dart';

enum LocationType {
  from,
  to,
  extraOne,
  extraTwo,
  location,
  accessLocation,
  senderLocation,
  receiverLocation
}

class LocationController extends GetxController implements GetxService {
  final LocationServiceInterface locationServiceInterface;

  LocationController({required this.locationServiceInterface});

  Position _position = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,
      altitudeAccuracy: 1,
      headingAccuracy: 1);
  Position _pickPosition = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,
      altitudeAccuracy: 1,
      headingAccuracy: 1);
  Address? fromAddress;
  Address? toAddress;
  Address? extraRouteAddress;
  Address? extraRouteTwoAddress;
  Address? parcelSenderAddress;
  Address? parcelReceiverAddress;
  bool _loading = false;
  String _address = '';
  String _pickAddress = '';
  List<AddressModel>? _addressList;
  bool _isLoading = false;
  bool _inZone = false;
  String? _zoneID;
  bool _buttonDisabled = true;
  bool _changeAddress = true;
  GoogleMapController? mapController;
  List<PredictionModel> _predictionList = [];
  bool _updateAddAddressData = true;
  LatLng _initialPosition = const LatLng(23.83721, 90.363715);
  bool addEntrance = false;
  int currentExtraRoute = 0;
  bool extraOneRoute = false;
  bool extraTwoRoute = false;
  bool resultShow = false;
  bool picking = false;
  double topPosition = 120;
  LocationType locationType = LocationType.from;

  List<PredictionModel> get predictionList => _predictionList;

  bool get isLoading => _isLoading;

  bool get loading => _loading;

  Position get position => _position;

  Position get pickPosition => _pickPosition;

  String get address => _address;

  String get pickAddress => _pickAddress;

  List<AddressModel>? get addressList => _addressList;

  bool get inZone => _inZone;

  String? get zoneID => _zoneID;

  bool get buttonDisabled => _buttonDisabled;

  LatLng get initialPosition => _initialPosition;

  final TextEditingController locationController = TextEditingController();
  final TextEditingController entranceController = TextEditingController();
  final TextEditingController pickupLocationController =
      TextEditingController();
  final TextEditingController destinationLocationController =
      TextEditingController();
  final TextEditingController extraRouteOneController = TextEditingController();
  final TextEditingController extraRouteTwoController = TextEditingController();
  final FocusNode entranceNode = FocusNode();

  void initAddLocationData() {
    addEntrance = false;
    extraTwoRoute = false;
    extraOneRoute = false;
    resultShow = false;
    currentExtraRoute = 0;
    _isLoading = false;
    _loading = false;
    _pickPosition = Position(
        longitude: 0,
        latitude: 0,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 1,
        heading: 1,
        speed: 1,
        speedAccuracy: 1,
        altitudeAccuracy: 1,
        headingAccuracy: 1);

    for (final controller in entranceControllers) {
      controller.dispose();
    }
    for (final node in entranceNodes) {
      node.dispose();
    }

    entranceControllers.clear();
    entranceNodes.clear();
  }

  void initTextControllers() {
    locationController.clear();
    _pickAddress = '';

    pickupLocationController.clear();
    destinationLocationController.clear();
    extraRouteOneController.clear();
    extraRouteTwoController.clear();

    entranceController.clear();

    for (final controller in entranceControllers) {
      controller.clear();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      update();
    });
  }

  void initParcelData() {
    parcelSenderAddress = null;
    parcelReceiverAddress = null;
  }

  void setAddEntrance() {
    addEntrance = !addEntrance;
    update();
  }

  void setPickUp(Address? address) {
    pickupLocationController.text = address?.address ?? '';
    fromAddress = address;
  }

  void setDestination(Address? address) {
    destinationLocationController.text = address?.address ?? '';
    toAddress = address;
  }

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  void setExtraRoute({bool remove = false}) {
    if (remove) {
      currentExtraRoute = currentExtraRoute - 1;
      if (currentExtraRoute == 1) {
        extraTwoRoute = false;
      } else {
        extraOneRoute = false;
      }
    } else {
      if (currentExtraRoute < 2) {
        currentExtraRoute = currentExtraRoute + 1;

        if (currentExtraRoute == 1) {
          extraOneRoute = true;
        }
        if (currentExtraRoute == 2) {
          extraTwoRoute = true;
        }
      }
    }
    if (kDebugMode) {
      print('=======extra===>$currentExtraRoute');
    }
    update();
  }

  StreamSubscription? _locationSubscription;

  Future<Address?> getCurrentLocation({
    bool isAnimate = true,
    GoogleMapController? mapController,
    LocationType type = LocationType.from,
  }) async {
    final bool permissionGranted = await checkPermission(() {});

    if (!permissionGranted) {
      debugPrint('GET CURRENT LOCATION: Permission not granted');
      return null;
    }

    try {
      await _locationSubscription?.cancel();
      _locationSubscription = null;

      final Position newLocalData = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _position = newLocalData;
      _initialPosition = LatLng(
        newLocalData.latitude,
        newLocalData.longitude,
      );

      // Rebuild location-dependent UI immediately after the GPS fix. Do not
      // wait for zone lookup, reverse geocoding, or live-location storage.
      update();

      if (isAnimate && mapController != null) {
        await mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _initialPosition,
              zoom: 15,
            ),
          ),
        );
      }

      if (type != LocationType.from) {
        update();
        return null;
      }

      _pickPosition = Position(
        latitude: newLocalData.latitude,
        longitude: newLocalData.longitude,
        timestamp: DateTime.now(),
        heading: newLocalData.heading,
        accuracy: newLocalData.accuracy,
        altitude: newLocalData.altitude,
        speedAccuracy: newLocalData.speedAccuracy,
        speed: newLocalData.speed,
        altitudeAccuracy: newLocalData.altitudeAccuracy,
        headingAccuracy: newLocalData.headingAccuracy,
      );

      final ZoneResponseModel zoneResponse = await getZone(
        newLocalData.latitude.toString(),
        newLocalData.longitude.toString(),
        false,
      );

      debugPrint('CURRENT LOCATION ZONE SUCCESS: ${zoneResponse.isSuccess}');
      debugPrint('CURRENT LOCATION ZONE ID: ${zoneResponse.zoneId}');

      if (!zoneResponse.isSuccess ||
          zoneResponse.zoneId == null ||
          zoneResponse.zoneId!.isEmpty) {
        debugPrint('GET CURRENT LOCATION: Zone not available');
        return null;
      }

      String currentAddress = '';

      try {
        currentAddress = await initAddressAddressFromGeocode(_initialPosition);
      } catch (e, stackTrace) {
        debugPrint('GEOCODE ERROR: $e');
        debugPrintStack(stackTrace: stackTrace);
      }

      // Do not return null when the zone is valid but geocoding fails.
      if (currentAddress.trim().isEmpty) {
        currentAddress = '${newLocalData.latitude}, ${newLocalData.longitude}';
      }

      final Address addressModel = Address(
        latitude: newLocalData.latitude,
        longitude: newLocalData.longitude,
        addressLabel: 'others',
        address: currentAddress,
        zoneId: zoneResponse.zoneId,
      );

      fromAddress = addressModel;
      pickupLocationController.text = currentAddress;

      await locationServiceInterface.storeLiveLocation(
        newLocalData.latitude.toString(),
        newLocalData.longitude.toString(),
      );

      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position livePosition) async {
        _position = livePosition;
        _initialPosition = LatLng(
          livePosition.latitude,
          livePosition.longitude,
        );

        if (mapController != null && Get.isRegistered<MapController>()) {
          Get.find<MapController>().updateMarkerAndCircle(
            latLng: LatLng(
              livePosition.latitude,
              livePosition.longitude,
            ),
          );
        }

        await locationServiceInterface.storeLiveLocation(
          livePosition.latitude.toString(),
          livePosition.longitude.toString(),
        );
      });

      update();
      return addressModel;
    } catch (e, stackTrace) {
      debugPrint('GET CURRENT LOCATION ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      update();
      return null;
    }
  }

  Future<LatLng?> getCurrentPosition(
      {GoogleMapController? mapController}) async {
    bool isSuccess = await checkPermission(() {});
    LatLng? latLng;
    if (isSuccess) {
      try {
        Position newLocalData = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        latLng = LatLng(newLocalData.latitude, newLocalData.longitude);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      if (mapController != null && latLng != null) {
        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(latLng.latitude, latLng.longitude), zoom: 16),
        ));
      }

      update();
    }
    return latLng;
  }

  bool selectLocation = false;

  Future<ZoneResponseModel> getZone(
      String lat, String long, bool markerLoad) async {
    _isLoading = true;
    update();
    ZoneResponseModel responseModel;
    Response response = await locationServiceInterface.getZone(lat, long);
    debugPrint('========== GET ZONE ==========');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');
    debugPrint('==============================');
    String? zoneId;
    if (response.statusCode == 200 && response.body != null) {
      final body = response.body;
      if (body['data'] is Map && body['data']['id'] != null) {
        zoneId = body['data']['id'].toString();
      } else if (body['data'] is String) {
        zoneId = body['data'].toString();
      } else if (body['zone_id'] != null) {
        zoneId = body['zone_id'].toString();
      }
    }
    if (zoneId != null && zoneId.isNotEmpty) {
      _zoneID = zoneId;
      _inZone = true;
      debugPrint('ZONE ID: $_zoneID');
      debugPrint('IN ZONE: $_inZone');
      responseModel = ZoneResponseModel(true, '', _zoneID);
    } else {
      _inZone = false;
      responseModel = ZoneResponseModel(
        false,
        response.body?['message']?.toString() ??
            response.statusText ??
            'Zone not found',
        null,
      );
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> saveUserAddress(Address? address) async {
    locationServiceInterface.saveUserAddress(address);
  }

  Address? getUserAddress() {
    Address? address;
    if (locationServiceInterface.getUserAddress() != null) {
      address = Address.fromJson(
          jsonDecode(locationServiceInterface.getUserAddress()!));
    }
    return address;
  }

  Future<String> initAddressAddressFromGeocode(LatLng latLng) async {
    try {
      final Response response =
          await locationServiceInterface.getAddressFromGeocode(latLng);

      debugPrint('GEOCODE STATUS: ${response.statusCode}');
      debugPrint('GEOCODE BODY: ${response.body}');

      if (response.statusCode == 200 &&
          response.body is Map &&
          response.body['data'] is Map &&
          response.body['data']['results'] is List &&
          (response.body['data']['results'] as List).isNotEmpty) {
        final dynamic firstResult = response.body['data']['results'][0];

        if (firstResult is Map && firstResult['formatted_address'] != null) {
          _address = firstResult['formatted_address'].toString();
        }
      }

      if (_address.trim().isNotEmpty) {
        pickupLocationController.text = _address;

        fromAddress = Address(
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          addressLabel: 'others',
          address: _address,
          zoneId: _zoneID,
        );
      }

      update();
      return _address;
    } catch (e, stackTrace) {
      debugPrint('INIT GEOCODE ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      return '';
    }
  }

  Future<String> getAddressFromGeocode(LatLng latLng) async {
    Response response =
        await locationServiceInterface.getAddressFromGeocode(latLng);
    if (response.statusCode == 200) {
      _address =
          response.body['data']['results'][0]['formatted_address'].toString();
    } else {
      showCustomSnackBar(
          response.body['errors'][0]['message'] ?? response.bodyString);
    }
    update();
    return _address;
  }

  Future<List<PredictionModel>> searchLocation(
      BuildContext context, String text,
      {LocationType type = LocationType.from, bool fromMap = false}) async {
    locationType = type;
    if (!fromMap) {
      positionSetForDialog();
      update();
    }

    if (text.isNotEmpty) {
      if (!fromMap) {
        setSearchResultShowHide(show: true);
      }

      Response response = await locationServiceInterface.searchLocation(text);
      if (response.statusCode == 200) {
        _predictionList = [];
        response.body['data']['predictions'].forEach((prediction) =>
            _predictionList.add(PredictionModel.fromJson(prediction)));
        update();
      } else {
        //customSnackBar(response.body['message'] ?? response.bodyString,isError:false);
      }
    } else {
      if (!fromMap) {
        setSearchResultShowHide(show: false);
      }
    }
    return _predictionList;
  }

  void positionSetForDialog() {
    if (locationType == LocationType.from) {
      topPosition = 85;
    } else if (locationType == LocationType.extraOne) {
      topPosition = 165;
    } else if (locationType == LocationType.extraTwo) {
      topPosition = 245;
    } else if (locationType == LocationType.to &&
        extraOneRoute &&
        extraTwoRoute) {
      topPosition = 325;
    } else if (locationType == LocationType.to && extraOneRoute) {
      topPosition = 245;
    } else if (locationType == LocationType.to) {
      topPosition = 165;
    }
  }

  void updatePosition(LatLng? positionLatLng, bool fromAddressScreen,
      LocationType? type) async {
    if (_updateAddAddressData && positionLatLng != null) {
      _loading = true;
      update();
      try {
        final Position newPosition = Position(
          latitude: positionLatLng.latitude,
          longitude: positionLatLng.longitude,
          timestamp: DateTime.now(),
          heading: 1,
          accuracy: 1,
          altitude: 1,
          speedAccuracy: 1,
          speed: 1,
          altitudeAccuracy: 1,
          headingAccuracy: 1,
        );

        if (fromAddressScreen) {
          if (type == LocationType.location || type == null) {
            _position = newPosition;
          }
        } else {
          // This is only the temporary map-picked position used by PickMapScreen.
          // Do not directly update fromAddress/toAddress here. The final assignment
          // must happen only when the user taps Pick Location.
          _pickPosition = newPosition;
        }

        ZoneResponseModel responseModel = await getZone(
          positionLatLng.latitude.toString(),
          positionLatLng.longitude.toString(),
          true,
        );

        if (Get.find<RideController>().isOutstationRide) {
          _buttonDisabled = false;
        } else if (responseModel.isSuccess) {
          _buttonDisabled = false;
        } else {
          _buttonDisabled = true;
        }

        if (_changeAddress) {
          String addressFromGeocode = await getAddressFromGeocode(
            LatLng(positionLatLng.latitude, positionLatLng.longitude),
          );

          if (fromAddressScreen) {
            _address = addressFromGeocode;

            if (type == LocationType.from) {
              fromAddress = Address(
                latitude: positionLatLng.latitude,
                longitude: positionLatLng.longitude,
                address: addressFromGeocode,
                zoneId: _zoneID,
              );
              pickupLocationController.text = addressFromGeocode;
            } else if (type == LocationType.to) {
              toAddress = Address(
                latitude: positionLatLng.latitude,
                longitude: positionLatLng.longitude,
                address: addressFromGeocode,
                zoneId: _zoneID,
              );
              destinationLocationController.text = addressFromGeocode;
            } else if (type == LocationType.extraOne) {
              extraRouteAddress = Address(
                latitude: positionLatLng.latitude,
                longitude: positionLatLng.longitude,
                address: addressFromGeocode,
                zoneId: _zoneID,
              );
              extraRouteOneController.text = addressFromGeocode;
            } else if (type == LocationType.extraTwo) {
              extraRouteTwoAddress = Address(
                latitude: positionLatLng.latitude,
                longitude: positionLatLng.longitude,
                address: addressFromGeocode,
                zoneId: _zoneID,
              );
              extraRouteTwoController.text = addressFromGeocode;
            } else {
              locationController.text = addressFromGeocode;
            }
          } else {
            // PickMapScreen preview address only. This text is shown in the map
            // search pill. It must not overwrite pickup/destination fields yet.
            _pickAddress = addressFromGeocode;
          }
        } else {
          _changeAddress = true;
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      _updateAddAddressData = true;
    }
    _loading = false;
    update();
  }

  Future<void> saveAddressAndNavigate(
      Address address, LocationType type) async {
    picking = true;
    update();

    setSearchResultShowHide(show: false);
    if (type == LocationType.accessLocation) {
      await saveUserAddress(address);
      Get.find<CategoryController>().getCategoryList();
      Get.find<BottomMenuController>().navigateToDashboard();
    } else {
      Get.back();
      if (type == LocationType.from) {
        pickupLocationController.text = address.address!;
        fromAddress = address;
      } else if (type == LocationType.to) {
        destinationLocationController.text = address.address!;
        toAddress = address;
      } else if (type == LocationType.extraOne) {
        extraRouteOneController.text = address.address!;
        extraRouteAddress = address;
      } else if (type == LocationType.extraTwo) {
        extraRouteTwoController.text = address.address!;
        extraRouteTwoAddress = address;
      } else if (type == LocationType.senderLocation) {
        Get.find<ParcelController>().senderAddressController.text =
            address.address!;
        parcelSenderAddress = address;
      } else if (type == LocationType.receiverLocation) {
        Get.find<ParcelController>().receiverAddressController.text =
            address.address!;
        parcelReceiverAddress = address;
      } else {
        _pickAddress = address.address!;
        _pickPosition = Position(
            latitude: address.latitude!,
            longitude: address.longitude!,
            timestamp: DateTime.now(),
            accuracy: 1,
            altitude: 1,
            heading: 1,
            speed: 1,
            speedAccuracy: 1,
            altitudeAccuracy: 1,
            headingAccuracy: 1);
      }
    }
    picking = false;
    update();
  }

  void setSenderAddress(Address? address) {
    Get.find<ParcelController>().senderAddressController.text =
        address?.address ?? '';
    parcelSenderAddress = address;
    update();
  }

  void setReceiverAddress(Address? address) {
    Get.find<ParcelController>().receiverAddressController.text =
        address?.address ?? '';
    parcelReceiverAddress = address;
    update();
  }

  void setSearchResultShowHide({bool show = false}) {
    resultShow = show;
    update();
  }

  bool selecting = false;

  Future<Address?> setLocation(
      String placeID, String address, GoogleMapController? mapController,
      {LocationType type = LocationType.from, bool fromSearch = false}) async {
    _loading = true;
    resultShow = false;
    selecting = true;
    update();
    LatLng latLng = const LatLng(0, 0);
    Address? selectedAddress;
    Response response = await locationServiceInterface.getPlaceDetails(placeID);
    if (response.statusCode == 200 && response.body['data']['status'] == 'OK') {
      PlaceDetailsModel placeDetails =
          PlaceDetailsModel.fromJson(response.body);
      latLng = LatLng(placeDetails.data!.result!.geometry!.location!.lat!,
          placeDetails.data!.result!.geometry!.location!.lng!);
// pushpa
      ZoneResponseModel zoneResponse = await getZone(
          latLng.latitude.toString(), latLng.longitude.toString(), false);
      if (zoneResponse.zoneId != null) {
        _predictionList = [];
        if (fromSearch) {
          if (type == LocationType.from) {
            fromAddress = Address(
              latitude: latLng.latitude,
              longitude: latLng.longitude,
              address: address,
              zoneId: _zoneID,
            );
            pickupLocationController.text = address;

            _pickPosition = Position(
              latitude: latLng.latitude,
              longitude: latLng.longitude,
              timestamp: DateTime.now(),
              accuracy: 1,
              altitude: 1,
              heading: 1,
              speed: 1,
              speedAccuracy: 1,
              altitudeAccuracy: 1,
              headingAccuracy: 1,
            );
            _pickAddress = address;
          } else if (type == LocationType.to) {
            if (Get.find<RideController>().isOutstationRide) {
              selecting = false;
              _loading = false;
              update();
              LocalRideBottomSheet.show();
              return null;
            }
            toAddress = Address(
              latitude: latLng.latitude,
              longitude: latLng.longitude,
              address: address,
              zoneId: _zoneID,
            );
            destinationLocationController.text = address;
          } else if (type == LocationType.extraOne) {
            extraRouteAddress = Address(
                latitude: latLng.latitude,
                longitude: latLng.longitude,
                address: address);
            extraRouteOneController.text = address;
          } else if (type == LocationType.extraTwo) {
            extraRouteTwoAddress = Address(
                latitude: latLng.latitude,
                longitude: latLng.longitude,
                address: address);
            extraRouteTwoController.text = address;
          }
        }

        if (!fromSearch) {
          _pickPosition = Position(
            latitude: latLng.latitude,
            longitude: latLng.longitude,
            timestamp: DateTime.now(),
            accuracy: 1,
            altitude: 1,
            heading: 1,
            speed: 1,
            speedAccuracy: 1,
            altitudeAccuracy: 1,
            headingAccuracy: 1,
          );
          _pickAddress = address;
        }

        _changeAddress = false;
        if (mapController != null) {
          mapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: latLng, zoom: 16)));
        }
        selecting = false;
        _loading = false;
        update();
        selectedAddress = Address(
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          addressLabel: 'others',
          address: address,
          zoneId: _zoneID,
        );
      } else {
        if (Get.find<RideController>().isOutstationRide) {
          toAddress = Address(
            latitude: latLng.latitude,
            longitude: latLng.longitude,
            address: address,
          );

          destinationLocationController.text = address;

          _pickPosition = Position(
            latitude: latLng.latitude,
            longitude: latLng.longitude,
            timestamp: DateTime.now(),
            accuracy: 1,
            altitude: 1,
            heading: 1,
            speed: 1,
            speedAccuracy: 1,
            altitudeAccuracy: 1,
            headingAccuracy: 1,
          );

          _pickAddress = address;
          _changeAddress = false;

          if (mapController != null) {
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: latLng,
                  zoom: 16,
                ),
              ),
            );
          }

          selecting = false;
          _loading = false;
          update();

          return toAddress;
        }
        selecting = false;
        showCustomSnackBar('service_not_available_in_this_area'.tr);
      }
    }
    selecting = false;
    return selectedAddress;
  }

  void disableButton() {
    _buttonDisabled = true;
    _inZone = true;
    update();
  }

  void setAddAddressData(LocationType type) {
    if (type == LocationType.from) {
      _position = _pickPosition;
      _address = _pickAddress;
      _updateAddAddressData = false;
    }

    update();
  }

  void setPickData(LocationType type) {
    if (type == LocationType.from) {
      _pickPosition = _position;
      _pickAddress = _address;
    }
  }

  Future<bool> checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    } else if (permission == LocationPermission.deniedForever) {
      Get.dialog(
          ConfirmationDialogWidget(
              description: 'you_denied_location_permission'.tr,
              onYesPressed: () async {
                Get.back();
                await Geolocator.openAppSettings();
              },
              icon: Images.logo),
          barrierDismissible: false);
    } else {
      onTap();
      return true;
    }
    return false;
  }

  List<TextEditingController> entranceControllers = [];
  List<FocusNode> entranceNodes = [];

  void addMoreEntrance({bool notify = true}) {
    final controller = TextEditingController();

    controller.addListener(() {
      entranceController.text = entranceControllers
          .map((e) => e.text.trim())
          .where((e) => e.isNotEmpty)
          .join(", ");
    });

    entranceControllers.add(controller);
    entranceNodes.add(FocusNode());

    if (notify) {
      update();
    }
  }

  void removeMoreEntrance(int index) {
    entranceControllers[index].dispose();
    entranceNodes[index].dispose();

    entranceControllers.removeAt(index);
    entranceNodes.removeAt(index);

    update();
  }
}
