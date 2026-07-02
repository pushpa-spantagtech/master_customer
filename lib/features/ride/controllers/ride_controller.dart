import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/domain/models/parcel_estimated_fare_model.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/bidding_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/estimated_fare_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/final_fare_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/nearest_driver_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/remaining_distance_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/services/ride_service_interface.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/payment/controllers/payment_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/outstation_tariff_model.dart';

enum RideState {
  initial,
  riseFare,
  findingRider,
  acceptingRider,
  afterAcceptRider,
  otpSent,
  ongoingRide,
  completeRide
}

enum RideType { car, bike, parcel, luxury }

class RideController extends GetxController implements GetxService {
  final RideServiceInterface rideServiceInterface;

  RideController({required this.rideServiceInterface});

  RideState currentRideState = RideState.initial;
  RideType selectedCategory = RideType.car;
  TripDetails? tripDetails;
  TripDetails? rideDetails;
  double currentFarePrice = 0;
  int rideCategoryIndex = 0;
  bool isLoading = false;
  String estimatedDistance = '0';
  String estimatedDuration = '0';
  double estimatedFare = 0;
  double actualFare = 0;
  List<FareModel> fareList = [];
  ParcelEstimatedFare? parcelEstimatedFare;
  String parcelFare = '0';
  String encodedPolyLine = '';
  bool loading = false;
  bool isEstimate = false;
  bool isSubmit = false;
  List<Nearest> nearestDriverList = [];
  FinalFare? finalFare;
  List<Bidding> biddingList = [];
  List<RemainingDistanceModel>? remainingDistanceModel = [];
  bool isCouponApplicable = false;
  double discountFare = 0;
  double discountAmount = 0;
  String rentalVehicle = '';
  int rentalHour = 0;
  double rentalPackageFare = 0;

  bool isLocalRide = false;
  bool isRentalRide = false;
  double? selectedIdleFee;
  List<dynamic> localTariffs = [];

  String localVehicle = '';
  String localVehicleCategoryId = '';
  double localFare = 0;
  bool isOutstationRide = false;
  String outstationVehicle = '';

  TripDetails? get currentTripDetails => tripDetails;

  TextEditingController inputFarePriceController =
      TextEditingController(text: '0.00');
  TextEditingController noteController = TextEditingController();

  void initData() {
    currentRideState = RideState.initial;
    isLoading = false;
    loading = false;
    encodedPolyLine = '';
  }

  void updateRideCurrentState(RideState newState) {
    currentRideState = newState;
    update();
  }

  void updateSelectedRideType(RideType newType) {
    selectedCategory = newType;
    update();
  }

  Future<void> setBidingAmount(String balance) async {
    if (balance.isNotEmpty) {
      actualFare = double.parse(balance);
      parcelFare = balance;
    }
    update();
  }

  String categoryName = '';
  String selectedCategoryId = '';
  FareModel? selectedType;

  String _resolveVehicleCategoryIdForBooking({
    required bool parcel,
    required String parcelCategoryId,
  }) {
    if (parcel) {
      return parcelCategoryId.trim();
    }

    String finalVehicleCategoryId = '';

    if (isLocalRide) {
      // 1) Prefer ID already saved by local vehicle selection, if available.
      if (localVehicleCategoryId.trim().isNotEmpty) {
        finalVehicleCategoryId = localVehicleCategoryId.trim();
      }

      // 2) If only local vehicle name is saved (EECO / OMNI / Sedan),
      // map it dynamically from CategoryController categoryList.
      // This avoids hardcoding category IDs, so future new cars will work
      // as long as their name exists in vehicle category API response.
      if (finalVehicleCategoryId.isEmpty && localVehicle.trim().isNotEmpty) {
        final localVehicleName = localVehicle.trim().toLowerCase();
        final categories = Get.find<CategoryController>().categoryList;

        if (categories != null && categories.isNotEmpty) {
          for (final category in categories) {
            final categoryName = (category.name ?? '').trim().toLowerCase();
            final categoryId = (category.id ?? '').trim();

            if (categoryName == localVehicleName && categoryId.isNotEmpty) {
              finalVehicleCategoryId = categoryId;
              break;
            }
          }
        }
      }

      // 3) Fallback for normal category selected earlier.
      if (finalVehicleCategoryId.isEmpty &&
          selectedCategoryId.trim().isNotEmpty) {
        finalVehicleCategoryId = selectedCategoryId.trim();
      }
    } else {
      finalVehicleCategoryId = selectedCategoryId.trim();
    }

    debugPrint('===== FINAL VEHICLE CATEGORY RESOLVE =====');
    debugPrint('isLocalRide => $isLocalRide');
    debugPrint('localVehicle => $localVehicle');
    debugPrint('localVehicleCategoryId => $localVehicleCategoryId');
    debugPrint('selectedCategoryId => $selectedCategoryId');
    debugPrint('finalVehicleCategoryId => $finalVehicleCategoryId');

    return finalVehicleCategoryId;
  }

  FareModel? _getFareByCategoryId(String vehicleCategoryId) {
    if (vehicleCategoryId.trim().isEmpty || fareList.isEmpty) {
      return selectedType;
    }

    for (final fare in fareList) {
      if ((fare.vehicleCategoryId ?? '').trim() == vehicleCategoryId.trim()) {
        return fare;
      }
    }

    return selectedType;
  }

  void setRideCategoryIndex(int newIndex) {
    rideCategoryIndex = newIndex;
    categoryName =
        Get.find<CategoryController>().categoryList![rideCategoryIndex].id!;

    if (fareList.isNotEmpty) {
      for (int i = 0; i < fareList.length; i++) {
        if (fareList[i].vehicleCategoryId == categoryName) {
          selectedType = fareList[i];
          break;
        }
      }

      estimatedDistance = selectedType!.estimatedDistance!;
      estimatedDuration = selectedType!.estimatedDuration!;
      selectedCategoryId = selectedType!.vehicleCategoryId!;
      estimatedFare = selectedType!.estimatedFare!;

      if (!isLocalRide) {
        selectedIdleFee = selectedType?.idleFeePerMin ?? 0;
      }

      currentFarePrice = estimatedFare;
      actualFare = estimatedFare;
      isCouponApplicable = selectedType!.couponApplicable!;
      discountFare = selectedType!.discountFare!;
      discountAmount = selectedType!.discountAmount!;
    }

    update();
  }

  void resetControllerValue() {
    currentRideState = RideState.initial;
    selectedCategory = RideType.car;
    rideCategoryIndex = 0;
    update();
  }

  void clearRideDetails() {
    tripDetails = null;
    rideDetails = null;
    update();
  }

  @override
  onInit() {
    if (tripDetails != null &&
        Get.find<AuthController>().getUserToken() != '') {
      startLocationRecord();
    } else {
      stopLocationRecord();
    }
    super.onInit();
  }

  Future<Response> getEstimatedFare(bool parcel) async {
    loading = true;
    isEstimate = true;
    update();
    parcelEstimatedFare = null;
    LocationController locController = Get.find<LocationController>();
    ParcelController parcelController = Get.find<ParcelController>();
    Address fromPosition = parcel
        ? locController.parcelSenderAddress!
        : locController.fromAddress!;
    Address toPosition = parcel
        ? locController.parcelReceiverAddress!
        : locController.toAddress!;

    Response? response = await rideServiceInterface.getEstimatedFare(
      pickupLatLng: LatLng(fromPosition.latitude!, fromPosition.longitude!),
      destinationLatLng: LatLng(toPosition.latitude!, toPosition.longitude!),
      currentLatLng: LatLng(locController.initialPosition.latitude,
          locController.initialPosition.longitude),
      type: parcel ? 'parcel' : 'ride_request',
      pickupAddress: parcel
          ? parcelController.senderAddressController.text
          : locController.fromAddress!.address.toString(),
      destinationAddress: parcel
          ? parcelController.receiverAddressController.text
          : locController.toAddress!.address!,
      extraOne: locController.extraOneRoute,
      extraTwo: locController.extraTwoRoute,
      extraOneLatLng: locController.extraRouteAddress != null
          ? LatLng(
              locController.extraRouteAddress!.latitude!,
              locController.extraRouteAddress!.longitude!,
            )
          : null,
      extraTwoLatLng: locController.extraRouteTwoAddress != null
          ? LatLng(
              locController.extraRouteTwoAddress!.latitude!,
              locController.extraRouteTwoAddress!.longitude!,
            )
          : null,
      parcelWeight: Get.find<ParcelController>().parcelWeightController.text,
      parcelCategoryId: parcel
          ? parcelController
              .parcelCategoryList![parcelController.selectedParcelCategory].id
          : '',
    );

    if (response!.statusCode == 200) {
      loading = false;
      isEstimate = false;
      /*locController.pickupLocationController.clear();
      locController.destinationLocationController.clear();
      locController.extraRouteOneController.clear();
      locController.extraRouteTwoController.clear();*/

      if (parcel) {
        parcelEstimatedFare = ParcelEstimatedFare.fromJson(response.body);
        encodedPolyLine =
            ParcelEstimatedFare.fromJson(response.body).data!.encodedPolyline!;
        parcelFare = ParcelEstimatedFare.fromJson(response.body)
            .data!
            .estimatedFare!
            .toString();
      } else {
        fareList = [];
        fareList.addAll(EstimatedFareModel.fromJson(response.body).data!);
        setRideCategoryIndex(rideCategoryIndex != 0 ? rideCategoryIndex : 0);
        setRideCategoryIndex(rideCategoryIndex != 0 ? rideCategoryIndex : 0);
        encodedPolyLine = fareList[rideCategoryIndex].polyline!;
        if (encodedPolyLine != '' && encodedPolyLine.isNotEmpty) {
          //   Get.find<MapController>().getPolyline();
        }
      }
    } else {
      loading = false;
      isEstimate = false;
      ApiChecker.checkApi(response);
      if (response.statusCode == 403 && !parcel) {
        getCurrentRideStatus(navigateToMap: false);
      }
    }

    update();
    return response;
  }

  Future<Response> submitRideRequest(String note, bool parcel,
      {String categoryId = ''}) async {
    if (!isLocalRide) {
      selectedIdleFee = selectedType?.idleFeePerMin ?? 0;
    }

    final String finalVehicleCategoryId = _resolveVehicleCategoryIdForBooking(
      parcel: parcel,
      parcelCategoryId: categoryId,
    );

    if (isOutstationRide) {
      Response fareResponse =
          await rideServiceInterface.calculateOutstationFare(
        vehicleType: outstationVehicle,
        distanceKm: double.tryParse(estimatedDistance) ?? 0,
      );

      if (fareResponse.statusCode == 200 &&
          fareResponse.body['status'] == true) {
        outstationFare = double.parse(
          fareResponse.body['total_fare'].toString(),
        );
      }
    }
    initCountingTimeStates();
    isSubmit = true;
    update();

    LocationController locController = Get.find<LocationController>();
    Address pickUpPosition = parcel
        ? locController.parcelSenderAddress!
        : tripDetails == null
            ? locController.fromAddress!
            : Address();
    Address destinationPosition = parcel
        ? locController.parcelReceiverAddress!
        : tripDetails == null
            ? locController.toAddress!
            : Address();

    if (!parcel && finalVehicleCategoryId.isEmpty) {
      showCustomSnackBar('Please select a vehicle category', isError: true);
      isSubmit = false;
      update();
      return const Response(
          statusCode: 400, statusText: 'Vehicle category is required');
    }

    final FareModel? finalSelectedType =
        _getFareByCategoryId(finalVehicleCategoryId);

    debugPrint('CREATE RIDE vehicle_category_id => $finalVehicleCategoryId');
    if (isLocalRide) {
      Response fareResponse = await rideServiceInterface.calculateLocalFare(
        vehicleCategoryId: finalVehicleCategoryId,
        distanceKm: double.tryParse(estimatedDistance) ?? 0,
        waitingMinutes: 0,
        tripTime: DateTime.now().toString(),
      );
      if (fareResponse.statusCode == 200 &&
          fareResponse.body['status'] == true) {
        localFare = double.parse(
          fareResponse.body['total_fare'].toString(),
        );
      }
    }

    debugPrint(
        "ENTRANCE => ${locController.entranceControllers.map((e) => e.text).toList()}");

    debugPrint(
        "ENTRANCE STRING => ${locController.entranceControllers.map((e) => e.text.trim()).where((e) => e.isNotEmpty).join(", ")}");

    final entranceText = locController.entranceControllers
        .map((e) => e.text.trim())
        .where((e) => e.isNotEmpty)
        .join(", ");

    debugPrint("ENTRANCE STRING => $entranceText");

    Response response = await rideServiceInterface.submitRideRequest(
        vehicleCategoryId: parcel ? categoryId : finalVehicleCategoryId,
        pickupLat: pickUpPosition.latitude.toString(),
        pickupLng: pickUpPosition.longitude.toString(),
        destinationLat: destinationPosition.latitude.toString(),
        destinationLng: destinationPosition.longitude.toString(),
        customerCurrentLat: locController.initialPosition.latitude.toString(),
        customerCurrentLng: locController.initialPosition.longitude.toString(),
        type: parcel ? 'parcel' : 'ride_request',
        pickupAddress: parcel
            ? Get.find<ParcelController>().senderAddressController.text
            : tripDetails == null
                ? locController.fromAddress!.address.toString()
                : tripDetails!.pickupAddress!,
        destinationAddress: parcel
            ? Get.find<ParcelController>().receiverAddressController.text
            : locController.toAddress?.address ??
                tripDetails!.destinationAddress!,
        // vehicleCategoryId: parcel ? categoryId : selectedCategoryId,
        estimatedDistance: parcel
            ? parcelEstimatedFare!.data!.estimatedDistance!.toString()
            : estimatedDistance,
        estimatedTime: parcel
            ? parcelEstimatedFare!.data!.estimatedDuration!
                .replaceFirst('min', '')
            : estimatedDuration,
        estimatedFare: parcel
            ? parcelFare
            : isLocalRide
                ? localFare.toString()
                : isOutstationRide
                    ? outstationFare.toString()
                    : isRentalRide
                        ? rentalPackageFare.toString()
                        : estimatedFare.toString(),
        actualFare: parcel
            ? parcelFare
            : isLocalRide
                ? localFare.toString()
                : isOutstationRide
                    ? outstationFare.toString()
                    : isRentalRide
                        ? rentalPackageFare.toString()
                        : estimatedFare != actualFare
                            ? actualFare.toString()
                            : estimatedFare.toString(),
        bid: parcel ? false : estimatedFare != actualFare,
        note: note,
        paymentMethod: Get.find<PaymentController>()
            .paymentTypeList[Get.find<PaymentController>().paymentTypeIndex],
        encodedPolyline: parcel
            ? encodedPolyLine
            : finalSelectedType?.polyline ??
                (fareList.isNotEmpty
                    ? fareList[rideCategoryIndex].polyline!
                    : ''),
        middleAddress: [
          locController.extraRouteAddress?.address ?? '',
          locController.extraRouteTwoAddress?.address ?? ''
        ],
        // entrance: entranceText,
        entrance: locController.entranceController.text,
        extraOne: locController.extraOneRoute,
        extraTwo: locController.extraTwoRoute,
        extraLatOne: locController.extraRouteAddress != null
            ? locController.extraRouteAddress!.latitude.toString()
            : '',
        extraLngOne: locController.extraRouteAddress != null
            ? locController.extraRouteAddress!.longitude.toString()
            : '',
        extraLatTwo: locController.extraRouteTwoAddress != null
            ? locController.extraRouteTwoAddress!.latitude.toString()
            : '',
        extraLngTwo: locController.extraRouteTwoAddress != null
            ? locController.extraRouteTwoAddress!.longitude.toString()
            : '',
        areaId: parcel
            ? ''
            : finalSelectedType?.areaId ??
                (fareList.isNotEmpty
                    ? fareList[rideCategoryIndex].areaId ?? ''
                    : ''),
        senderName: Get.find<ParcelController>().senderNameController.text,
        senderPhone: Get.find<ParcelController>().senderContactController.text,
        senderAddress:
            Get.find<ParcelController>().senderAddressController.text,
        receiverName: Get.find<ParcelController>().receiverNameController.text,
        receiverPhone:
            Get.find<ParcelController>().receiverContactController.text,
        receiverAddress:
            Get.find<ParcelController>().receiverAddressController.text,
        parcelCategoryId: parcel
            ? Get.find<ParcelController>()
                .parcelCategoryList![
                    Get.find<ParcelController>().selectedParcelCategory]
                .id
            : '',
        payer: Get.find<ParcelController>().payReceiver ? 'receiver' : "sender",
        weight: Get.find<ParcelController>().parcelWeightController.text,
        tripRequestId: parcel ? null : tripDetails?.id);

    if (response.statusCode == 200 && response.body['data'] != null) {
      biddingList = [];
      tripDetails = TripDetailsModel.fromJson(response.body).data!;
      tripDetails!.id = response.body['data']['id'];
      encodedPolyLine = tripDetails!.encodedPolyline!;
      if (encodedPolyLine != '' && encodedPolyLine.isNotEmpty) {
        //  Get.find<MapController>().getPolyline();
      }
      Get.find<ParcelController>().receiverNameController.clear();
      Get.find<ParcelController>().receiverContactController.clear();
      Get.find<ParcelController>().receiverAddressController.clear();
      Get.find<ParcelController>().parcelWeightController.clear();
      PusherHelper().pusherDriverStatus(response.body['data']['id']);
      startLocationRecord();
      isSubmit = false;
      noteController.clear();
    } else {
      isSubmit = false;
      ApiChecker.checkApi(response);
      if (response.statusCode == 403) {
        getCurrentRideStatus(navigateToMap: false);
      }
    }
    actualFare = 0;
    isLoading = false;
    update();

    return response;
  }

  void clearExtraRoute() {
    Get.find<LocationController>().extraOneRoute = false;
    Get.find<LocationController>().extraTwoRoute = false;
    Get.find<LocationController>().extraRouteAddress = null;
    Get.find<LocationController>().extraRouteTwoAddress = null;
  }

  Future<Response> getRideDetails(String tripId) async {
    isLoading = true;
    tripDetails = null;
    update();
    Response response = await rideServiceInterface.getRideDetails(tripId);

    if (response.statusCode == 200) {
      Get.find<MapController>().notifyMapController();

      tripDetails = TripDetailsModel.fromJson(response.body).data!;
      print("TRIP ENTRANCE => ${tripDetails?.entrance}");

      estimatedDistance = tripDetails!.estimatedDistance!.toString();
      isLoading = false;
      encodedPolyLine = tripDetails!.encodedPolyline!;
    } else {
      print("❌ GET RIDE DETAILS FAILED");
      print(response.statusCode);
      print(response.body);
      isLoading = false;
    }

    update();
    return response;
  }

  // Future<Response> getRideDetails(String tripId) async {
  //   isLoading = true;
  //   tripDetails = null;
  //
  //   update();
  //   Response response = await rideServiceInterface.getRideDetails(tripId);
  //   if (response.statusCode == 200) {
  //     Get.find<MapController>().notifyMapController();
  //     tripDetails = TripDetailsModel.fromJson(response.body).data!;
  //     estimatedDistance = tripDetails!.estimatedDistance!.toString();
  //     isLoading = false;
  //     encodedPolyLine = tripDetails!.encodedPolyline!;
  //   }
  //   update();
  //   return response;
  // }

  bool runningTrip = false;

  Future<Response> getCurrentRideStatus(
      {bool fromRefresh = false, bool navigateToMap = true}) async {
    runningTrip = true;

    Response response = await rideServiceInterface.currentRideStatus();

    if (response.statusCode == 200 && response.body['data'] != null) {
      runningTrip = false;
      print("========== DATA KEYS ==========");
      print(response.body['data'].keys.toList());
      print("===============================");

      /// ===================== API RESPONSE =====================
      print("========== FULL CURRENT RIDE API ==========");
      print(response.body);
      print("===========================================");

      tripDetails = TripDetailsModel.fromJson(response.body).data!;

      /// ===================== DRIVER JSON =====================
      print("========== DRIVER JSON FROM API ==========");
      print(response.body['data']['driver']);

      if (response.body['data']['driver'] != null) {
        print("Driver ID      : ${response.body['data']['driver']['id']}");
        print(
            "First Name     : ${response.body['data']['driver']['first_name']}");
        print(
            "Last Name      : ${response.body['data']['driver']['last_name']}");
        print("Phone          : ${response.body['data']['driver']['phone']}");
        print(
            "Profile Image  : ${response.body['data']['driver']['profile_image']}");
      } else {
        print("❌ DRIVER OBJECT IS NULL FROM API");
      }

      /// ===================== MODEL DATA =====================
      print("========== DRIVER MODEL ==========");
      print("Driver Model   : ${tripDetails?.driver}");
      print("Driver ID      : ${tripDetails?.driver?.id}");
      print("First Name     : ${tripDetails?.driver?.firstName}");
      print("Last Name      : ${tripDetails?.driver?.lastName}");
      print("Phone          : ${tripDetails?.driver?.phone}");
      print("Profile Image  : ${tripDetails?.driver?.profileImage}");
      print("==================================");

      /// ===================== TRIP DATA =====================
      print("========== CUSTOMER RIDE STATUS ==========");
      print("Trip ID        : ${tripDetails?.id}");
      print("Status         : ${tripDetails?.currentStatus}");
      print("OTP            : ${tripDetails?.otp}");
      print(
          "Driver Live    : ${response.body['data']['driver_last_location']}");
      print("Vehicle        : ${tripDetails?.vehicle?.model?.name}");
      print("Vehicle No     : ${tripDetails?.vehicle?.licencePlateNumber}");
      print("==========================================");

      estimatedDistance = tripDetails!.estimatedDistance!.toString();
      String currentRideStatus = tripDetails!.currentStatus!;
      encodedPolyLine = tripDetails!.encodedPolyline ?? '';

      if (encodedPolyLine.isNotEmpty) {
        // Get.find<MapController>().getPolyline();
      }

      if (currentRideStatus == AppConstants.accepted ||
          currentRideStatus == AppConstants.ongoing) {
        updateRideCurrentState(
          currentRideStatus == AppConstants.accepted
              ? RideState.acceptingRider
              : RideState.ongoingRide,
        );

        if (_timer == null || !_timer!.isActive) {
          startLocationRecord();
        }

        Get.find<MapController>().notifyMapController();

        if (navigateToMap) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.to(() => const MapScreen(fromScreen: MapScreenType.splash));
          });
        }
      } else if (currentRideStatus == AppConstants.pending) {
        Get.find<RideController>()
            .updateRideCurrentState(RideState.findingRider);

        Get.find<RideController>().getBiddingList(tripDetails!.id!, 1);

        Get.find<MapController>().notifyMapController();

        if (navigateToMap) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.to(() => const MapScreen(fromScreen: MapScreenType.splash));
          });
        }
      } else if (currentRideStatus == AppConstants.completed ||
          currentRideStatus == AppConstants.cancelled) {
        await getFinalFare(tripDetails!.id!);

        Get.off(() => const PaymentScreen());
      } else {
        if (Get.find<LocationController>().getUserAddress() != null) {
          if (!fromRefresh) {
            Get.offAll(() => const DashboardScreen());
          }
        } else {
          Get.offAll(() => const AccessLocationScreen());
        }
      }
    } else {
      print("❌ CURRENT RIDE API FAILED");
      print(response.statusCode);
      print(response.body);

      runningTrip = false;
      tripDetails = null;
      rideDetails = null;

      if (Get.find<LocationController>().getUserAddress() != null) {
        if (!fromRefresh) {
          Get.offAll(() => const DashboardScreen());
        }
      } else {
        Get.to(() => const AccessLocationScreen());
      }
    }

    update();
    return response;
  }

  Future<Response> getCurrentRide(
      {bool fromRefresh = false, bool navigateToMap = true}) async {
    Response response = await rideServiceInterface.currentRideStatus();
    if (response.statusCode == 200 && response.body['data'] != null) {
      tripDetails =
          rideDetails = TripDetailsModel.fromJson(response.body).data!;
      estimatedDistance = rideDetails!.estimatedDistance!.toString();
      encodedPolyLine = rideDetails!.encodedPolyline ?? '';
    } else if (response.statusCode == 403) {
      rideDetails = null;
    }
    update();
    return response;
  }

  Future<Response> remainingDistance(String requestID,
      {bool mapBound = false}) async {
    isLoading = true;
    Response response = await rideServiceInterface.remainDistance(requestID);
    print("========== CUSTOMER REMAIN DISTANCE ==========");
    print(response.body);
    print("=============================================");
    if (response.statusCode == 200) {
      Get.find<MapController>().getDriverToPickupOrDestinationPolyline(
          response.body[0]["encoded_polyline"],
          mapBound: mapBound);
      remainingDistanceModel = [];
      for (var distance in response.body) {
        remainingDistanceModel!.add(RemainingDistanceModel.fromJson(distance));
      }

      if (Get.find<MapController>().isInside &&
          tripDetails != null &&
          currentRideState == RideState.acceptingRider) {
        currentRideState = RideState.otpSent;
      }
      if (Get.find<MapController>().isInside &&
          Get.find<ParcelController>().currentParcelState ==
              ParcelDeliveryState.acceptRider) {
        Get.find<ParcelController>()
            .updateParcelState(ParcelDeliveryState.otpSent);
      }
      arrivalPickupPoint(tripDetails!.id!);
      isLoading = false;
    } else {
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Future<Response> getBiddingList(String tripId, int offset) async {
    isLoading = true;

    Response response = await rideServiceInterface.biddingList(tripId, offset);
    if (response.statusCode == 200) {
      biddingList = [];
      biddingList.addAll(BiddingModel.fromJson(response.body).data!);
      isLoading = false;
    } else {
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Future<Response> ignoreBidding(String bidId, String tripId) async {
    isLoading = true;
    update();
    Response response = await rideServiceInterface.ignoreBidding(bidId);
    if (response.statusCode == 200) {
      getBiddingList(tripId, 1).then((value) {
        if (biddingList.isEmpty) {
          Get.back();
        }
      });
      isLoading = false;
    } else {
      getBiddingList(tripId, 1).then((value) {
        if (biddingList.isEmpty) {
          Get.back();
          Future.delayed(const Duration(milliseconds: 300)).then((value) {
            ApiChecker.checkApi(response);
          });
        }
      });
      isLoading = false;
    }
    update();
    return response;
  }

  Future<Response> getNearestDriverList(String lat, String lng) async {
    Response response = await rideServiceInterface.nearestDriverList(lat, lng);
    if (response.statusCode == 200) {
      nearestDriverList = [];
      nearestDriverList
          .addAll(NearestDriverModel.fromJson(response.body).data!);
      Get.find<MapController>().searchDeliveryMen();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Timer? _timer;

  void startLocationRecord() {
    _timer?.cancel();

    // First refresh immediately, but do not navigate/rebuild the whole screen.
    Future.microtask(() async {
      if (Get.find<AuthController>().getUserToken() != '') {
        await getCurrentRideStatus(
          navigateToMap: false,
          fromRefresh: true,
        );

        if (tripDetails != null &&
            (tripDetails?.currentStatus == 'accepted' ||
                tripDetails?.currentStatus == 'ongoing')) {
          await remainingDistance(tripDetails!.id!, mapBound: true);
        }
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (Get.find<AuthController>().getUserToken() == '') {
        timer.cancel();
        return;
      }

      // Refresh trip status without navigating. This helps customer app move
      // from pending -> accepted -> ongoing without full page refresh.
      await getCurrentRideStatus(
        navigateToMap: false,
        fromRefresh: true,
      );

      if (tripDetails != null &&
          (tripDetails?.currentStatus == 'accepted' ||
              tripDetails?.currentStatus == 'ongoing')) {
        await remainingDistance(tripDetails!.id!);
      } else if (tripDetails == null ||
          tripDetails?.currentStatus == 'completed' ||
          tripDetails?.currentStatus == 'cancelled') {
        timer.cancel();
      }
    });
  }

  void stopLocationRecord() {
    _timer?.cancel();
  }

  Future<Response> tripAcceptOrRejected(
      String tripId, String type, String driverId) async {
    isLoading = true;
    update();
    Response response =
        await rideServiceInterface.tripAcceptOrReject(tripId, type, driverId);
    if (response.statusCode == 200) {
      biddingList = [];
      showCustomSnackBar('trip_is_accepted'.tr, isError: false);
      Get.back();
      getRideDetails(tripId).then((value) {
        if (value.statusCode == 200) {
          remainingDistance(tripDetails!.id!, mapBound: true);
          updateRideCurrentState(RideState.otpSent);
          Get.find<MapController>().notifyMapController();
          Get.offAll(() => const MapScreen(fromScreen: MapScreenType.ride));
        }
      });
      isLoading = false;
    } else {
      getBiddingList(tripId, 1).then((value) {
        if (biddingList.isEmpty) {
          Get.back();
          Future.delayed(const Duration(milliseconds: 300)).then((value) {
            ApiChecker.checkApi(response);
          });
        }
      });
      isLoading = false;
    }
    update();
    return response;
  }

  void clearBiddingList() {
    biddingList = [];
    update();
  }

  Future<Response> tripStatusUpdate(
      String tripId, String status, String message, String cancellationCause,
      {bool afterAccept = false}) async {
    isLoading = true;
    update();
    Response response = await rideServiceInterface.tripStatusUpdate(
        tripId, status, cancellationCause);
    if (response.statusCode == 200) {
      if (status == "cancelled" && !afterAccept) {
        tripDetails = null;
      }
      showCustomSnackBar(message.tr, isError: false);
      isLoading = false;
    } else {
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Future<Response> getFinalFare(String tripId) async {
    isLoading = true;
    update();

    Response response = await rideServiceInterface.getFinalFare(tripId);

    if (response.statusCode == 200) {
      if (response.body['data'] != null) {
        finalFare = FinalFareModel.fromJson(response.body).data!;

        print('FINAL FARE LOADED');
        print('actualFare = ${finalFare?.actualFare}');
        print('paidFare = ${finalFare?.paidFare}');
        print('vatTax = ${finalFare?.vatTax}');
        print('actualDistance = ${finalFare?.actualDistance}');
      }
    } else {
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    update();
    return response;
  }

  Future<Response> arrivalPickupPoint(String tripId) async {
    isLoading = true;
    Response response = await rideServiceInterface.arrivalPickupPoint(tripId);
    if (response.statusCode == 200) {
    } else {
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    update();
    return response;
  }

  String driverLat = '0';
  String driverLng = '0';

  Future<void> detDriverLocation(String tripId) async {
    Response response = await rideServiceInterface.arrivalPickupPoint(tripId);
    if (response.statusCode == 200) {
      driverLat = response.body['data']['latitude'];
      driverLng = response.body['data']['longitude'];
    }
    update();
  }

  double? firstCount = 0;
  double? secondCount = 0;
  double? thirdCount = 0;
  int stateCount = 0;
  Timer? _findingStateAnimation;

  void countingTimeStates() async {
    _findingStateAnimation?.cancel();
    if (stateCount == 0) {
      await Future.delayed(const Duration(seconds: 1)).then((value) {
        firstCount = null;
        secondCount = 0;
        thirdCount = 0;
        update();
      });

      _findingStateAnimation =
          Timer.periodic(const Duration(minutes: 1), (time) {
        firstCount = 1;
        stateCount = 1;
        countingTimeStates();
      });
    }

    if (stateCount == 1) {
      await Future.delayed(const Duration(milliseconds: 100)).then((value) {
        firstCount = 1;
        secondCount = null;
        thirdCount = 0;
        update();
      });

      _findingStateAnimation =
          Timer.periodic(const Duration(minutes: 1), (time) {
        secondCount = 1;
        stateCount = 2;
        countingTimeStates();
      });
    }

    if (stateCount == 2) {
      await Future.delayed(const Duration(milliseconds: 100)).then((value) {
        firstCount = 1;
        secondCount = 1;
        thirdCount = null;
        update();
      });

      _findingStateAnimation =
          Timer.periodic(const Duration(minutes: 3), (time) {
        thirdCount = 1;
        stateCount = 3;
        update();
        _findingStateAnimation?.cancel();
      });
    }

    if (stateCount == 3) {
      update();
    }
  }

  void initCountingTimeStates({bool isRestart = false}) {
    if (isRestart) {
      if (stateCount == 3) {
        firstCount = 0;
        secondCount = 0;
        thirdCount = 0;
        stateCount = 0;
      }
      countingTimeStates();
    } else {
      firstCount = 0;
      secondCount = 0;
      thirdCount = 0;
      stateCount = 0;
    }
  }

  void resumeCountingTimeState(int duration) {
    if (duration < 60) {
      secondCount = 0;
      thirdCount = 0;
      stateCount = 0;
    } else if (duration > 60 && duration < 120) {
      firstCount = 1;
      thirdCount = 0;
      stateCount = 1;
    } else if (duration > 120 && duration < 300) {
      firstCount = 1;
      secondCount = 1;
      stateCount = 2;
    } else {
      firstCount = 1;
      secondCount = 1;
      thirdCount = 1;
      stateCount = 3;
    }
    countingTimeStates();
  }

  void setLocalRide(bool value) {
    isLocalRide = value;
    if (value) {
      isRentalRide = false;
      isOutstationRide = false;

      rentalHour = 0;
      rentalPackageFare = 0;
      rentalVehicle = '';
    }
    update();
  }

  void setRentalRide(bool value) {
    isRentalRide = value;
    if (value) {
      isLocalRide = false;
      isOutstationRide = false;
    }
    update();
  }

  void setOutstationRide(bool value) {
    isOutstationRide = value;
    if (value) {
      isLocalRide = false;
      isRentalRide = false;

      rentalHour = 0;
      rentalPackageFare = 0;
      rentalVehicle = '';
    }
    update();
  }

  double outstationFare = 0;
  List<OutstationTariff> outstationTariffs = [];
  Future<void> getOutstationTariffs() async {
    Response response = await rideServiceInterface.getOutstationTariffs();

    if (response.statusCode == 200) {
      outstationTariffs =
          OutstationTariffModel.fromJson(response.body).data ?? [];

      final double distanceKm = double.tryParse(estimatedDistance) ?? 0;

      for (final tariff in outstationTariffs) {
        final double baseKm =
            double.tryParse(tariff.baseKm?.toString() ?? '0') ?? 0;
        final double baseFare =
            double.tryParse(tariff.baseFare?.toString() ?? '0') ?? 0;
        final double extraPerKm =
            double.tryParse(tariff.extraPerKm?.toString() ?? '0') ?? 0;

        final double extraKm = distanceKm > baseKm ? distanceKm - baseKm : 0;
        final double totalFare = baseFare + (extraKm * extraPerKm);

        // tariff.baseFare = totalFare.toStringAsFixed(2);
      }

      print('Outstation Tariffs Loaded: ${outstationTariffs.length}');
      print('Outstation Distance KM: $distanceKm');
    } else {
      ApiChecker.checkApi(response);
    }

    update();
  }

  double calculateOutstationFare(
    OutstationTariff tariff,
    double distance,
  ) {
    final baseKm = tariff.baseKm ?? 0;
    final baseFare = double.tryParse(tariff.baseFare ?? '0') ?? 0;
    final extraPerKm = double.tryParse(tariff.extraPerKm ?? '0') ?? 0;

    if (distance <= baseKm) {
      return baseFare;
    }

    return baseFare + ((distance - baseKm) * extraPerKm);
  }

  Future<void> getLocalTariffs() async {
    Response response = await rideServiceInterface.getLocalTariffs();
    if (response.statusCode == 200) {
      final currentZoneId = Get.find<LocationController>().zoneID;
      localTariffs = (response.body['data'] as List)
          .where((e) => e['zone_id'] == currentZoneId)
          .toList();
      for (var item in localTariffs) {
        print("ZONE => ${item['zone']['name']}");
      }
      update();
    }
  }

  List<dynamic> hourlyTariffs = [];
  List<dynamic> rentalPackages = [];

  Future<void> getHourlyTariffs() async {
    Response response = await rideServiceInterface.getHourlyTariffs();

    if (response.statusCode == 200) {
      hourlyTariffs = response.body['data'];
      rentalPackages = [];
      for (var item in hourlyTariffs) {
        if (!rentalPackages.any(
          (e) => e['free_hours'] == item['free_hours'],
        )) {
          rentalPackages.add(item);
        }
      }
    }

    update();
  }
}
