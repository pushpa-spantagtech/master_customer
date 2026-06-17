import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/common_widgets/swipable_button_widget/slider_button_widget.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/banner_shimmer.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/widget/cancelation_radio_button.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/otp_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/route_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/tolltip_widget.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/estimated_fare_and_distance.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/rider_details.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class AcceptingAndOngoingBottomSheet extends StatefulWidget {
  final String firstRoute;
  final String secondRoute;
  final GlobalKey<ExpandableBottomSheetState> expandableKey;

  const AcceptingAndOngoingBottomSheet(
      {super.key,
      required this.firstRoute,
      required this.secondRoute,
      required this.expandableKey});

  @override
  State<AcceptingAndOngoingBottomSheet> createState() =>
      _AcceptingAndOngoingBottomSheetState();
}

class _AcceptingAndOngoingBottomSheetState
    extends State<AcceptingAndOngoingBottomSheet> {
  int currentState = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        return currentState == 0
            ? rideController.tripDetails != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        rideController.currentRideState ==
                                RideState.acceptingRider
                            ? Column(
                                children: [
                                  TollTipWidget(
                                    title: 'rider_is_coming'.tr,
                                    showInsight: false,
                                  ),
                                  const OtpWidget(fromPage: false),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: TollTipWidget(
                                    showInsight: false,
                                    title:
                                        '${'drop_off'.tr} ${DateConverter.dateToTimeOnly(DateTime.now().add(Duration(seconds: rideController.remainingDistanceModel![0].durationSec!)))}'),
                              ),
                        const EstimatedFareAndDistance(),
                        const SizedBox(
                          height: Dimensions.paddingSizeDefault,
                        ),
                        const ActivityScreenRiderDetails(),
                        const SizedBox(
                          height: Dimensions.paddingSizeDefault,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault),
                          child: Text(
                            'trip_details'.tr,
                            style: textBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: const Color.fromRGBO(20, 20, 20, 1)),
                          ),
                        ),
                        if (rideController.tripDetails != null)
                          RouteWidget(
                              totalDistance: rideController.estimatedDistance,
                              fromAddress:
                                  rideController.tripDetails?.pickupAddress ??
                                      '',
                              toAddress: rideController
                                      .tripDetails?.destinationAddress ??
                                  '',
                              extraOneAddress: widget.firstRoute,
                              extraTwoAddress: widget.secondRoute,
                              entrance:
                                  rideController.tripDetails?.entrance ?? ''),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromRGBO(0, 0, 0, 0.1)),
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusLarge),
                              color: const Color.fromRGBO(255, 255, 255, 1)),
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault),
                          child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      Image.asset(
                                        Images.farePrice,
                                        height: 15,
                                        width: 15,
                                        color: const Color.fromRGBO(
                                            250, 173, 2, 1),
                                      ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeSmall,
                                      ),
                                      Text('fare_price'.tr,
                                          style: textRegular.copyWith(
                                              color: const Color.fromRGBO(
                                                  20, 20, 20, 1),
                                              fontSize:
                                                  Dimensions.fontSizeDefault)),
                                    ]),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromRGBO(
                                                  250, 173, 2, 1)),
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          color: const Color.fromRGBO(
                                              255, 255, 255, 1)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeSmall,
                                          vertical:
                                              Dimensions.paddingSizeExtraSmall),
                                      child: Text(
                                        // PriceConverter.convertPrice(
                                        //     ((rideController.tripDetails
                                        //                     ?.discountAmount ??
                                        //                 0) >
                                        //             0)
                                        //         ? rideController.tripDetails
                                        //                 ?.discountActualFare ??
                                        //             0
                                        //         : rideController.tripDetails
                                        //                 ?.actualFare ??
                                        //             0),
                                        PriceConverter.convertPrice(
                                          rideController
                                                  .tripDetails?.actualFare ??
                                              0,
                                        ),
                                        style: textBold.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: const Color.fromRGBO(
                                                20, 20, 20, 1)),
                                      ),
                                    )
                                  ]),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Row(children: [
                                      Image.asset(
                                        Images.paymentTypeIcon,
                                        height: 15,
                                        width: 15,
                                        color: const Color.fromRGBO(
                                            250, 173, 2, 1),
                                      ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeSmall,
                                      ),
                                      Text(
                                        'payment'.tr,
                                        style: textRegular.copyWith(
                                            color: const Color.fromRGBO(
                                                20, 20, 20, 1),
                                            fontSize:
                                                Dimensions.fontSizeDefault),
                                      ),
                                    ])),
                                    Text(
                                      rideController.tripDetails?.paymentMethod
                                              ?.replaceAll(
                                                  RegExp('[\\W_]+'), ' ')
                                              .capitalize ??
                                          'cash'.tr,
                                      style: const TextStyle(
                                          color: Color.fromRGBO(20, 20, 20, 1)),
                                    )
                                  ]),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        if (rideController.tripDetails != null &&
                            rideController.tripDetails!.type ==
                                'ride_request' &&
                            !rideController.tripDetails!.isPaused!)
                          Center(
                            child: SliderButton(
                              action: () async {
                                await Get.find<TripController>()
                                    .getOngoingAndAcceptedCancellationCauseList();
                                currentState = 1;
                                widget.expandableKey.currentState?.expand();
                                setState(() {});
                              },
                              label: Text(
                                'cancel_ride'.tr,
                                style: textMedium.copyWith(
                                    color:
                                        const Color.fromRGBO(250, 173, 2, 1)),
                              ),
                              dismissThresholds: 0.5,
                              dismissible: false,
                              shimmer: false,
                              width: 1170,
                              height: 40,
                              buttonSize: 40,
                              radius: 20,
                              icon: Center(
                                  child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromRGBO(255, 255, 255, 1)),
                                child: Center(
                                  child: Icon(
                                    Get.find<LocalizationController>().isLtr
                                        ? Icons.arrow_forward_ios_rounded
                                        : Icons.keyboard_arrow_left,
                                    color: Colors.grey,
                                    size: 15.0,
                                  ),
                                ),
                              )),
                              isLtr: Get.find<LocalizationController>().isLtr,
                              boxShadow: const BoxShadow(blurRadius: 0),
                              buttonColor: Colors.transparent,
                              backgroundColor:
                                  const Color.fromRGBO(255, 239, 203, 1),
                              baseColor: Theme.of(context).primaryColor,
                            ),
                          )
                      ])
                : const Column(children: [
                    BannerShimmer(),
                    BannerShimmer(),
                    BannerShimmer()
                  ])
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: Dimensions.paddingSizeSmall,
                  ),
                  Text(
                    rideController.currentRideState == RideState.acceptingRider
                        ? 'cancel_ride'.tr
                        : 'trip_is_ongoing'.tr,
                    style: textSemiBold.copyWith(
                        color: const Color.fromRGBO(20, 20, 20, 1),
                        fontSize: Dimensions.fontSizeExtraLarge),
                  ),
                  const SizedBox(
                    height: Dimensions.paddingSizeSmall,
                  ),
                  CancellationRadioButton(
                      isOngoing: rideController.currentRideState ==
                              RideState.acceptingRider
                          ? false
                          : true),
                  Row(
                    children: [
                      Expanded(
                          child: ButtonWidget(
                              buttonText: 'no_continue_trip'.tr,
                              fontSize: Dimensions.fontSizeDefault + 1,
                              textColor: const Color.fromRGBO(255, 255, 255, 1),
                              borderColor:
                                  const Color.fromRGBO(255, 128, 128, 0.2),
                              backgroundColor:
                                  const Color.fromRGBO(250, 173, 2, 1),
                              showBorder: true,
                              transparent: true,
                              radius: Dimensions.paddingSizeSmall,
                              onPressed: () {
                                currentState = 0;
                                setState(() {});
                              })),
                      const SizedBox(
                        width: Dimensions.paddingSizeSmall,
                      ),
                      Expanded(
                          child: ButtonWidget(
                              buttonText: 'submit'.tr,
                              showBorder: true,
                              transparent: true,
                              fontSize: Dimensions.fontSizeDefault + 1,
                              textColor: Get.isDarkMode
                                  ? Colors.white
                                  : const Color.fromRGBO(20, 20, 20, 1),
                              borderColor: Theme.of(context).hintColor,
                              radius: Dimensions.paddingSizeSmall,
                              onPressed: () {
                                if (rideController.currentRideState ==
                                    RideState.acceptingRider) {
                                  Get.find<RideController>()
                                      .stopLocationRecord();
                                  rideController
                                      .tripStatusUpdate(
                                          rideController.tripDetails!.id!,
                                          'cancelled',
                                          'ride_request_cancelled_successfully',
                                          Get.find<TripController>()
                                              .tripCancellationCauseList!
                                              .data!
                                              .acceptedRide![Get.find<
                                                  TripController>()
                                              .tripCancellationCauseCurrentIndex])
                                      .then((value) {
                                    if (value.statusCode == 200) {
                                      Get.find<MapController>()
                                          .notifyMapController();
                                      Get.find<BottomMenuController>()
                                          .navigateToDashboard();
                                    }
                                  });
                                } else {
                                  Get.find<TripController>()
                                      .tripCancellationCauseList!
                                      .data!
                                      .ongoingRide = [
                                    "Trip taking too long",
                                    "Customer requested cancel"
                                  ];
                                  rideController
                                      .tripStatusUpdate(
                                          rideController.tripDetails!.id!,
                                          'cancelled',
                                          'ride_request_cancelled_successfully',
                                          Get.find<TripController>()
                                              .tripCancellationCauseList!
                                              .data!
                                              .ongoingRide![Get.find<
                                                  TripController>()
                                              .tripCancellationCauseCurrentIndex],
                                          afterAccept: true)
                                      .then((value) async {
                                    if (value.statusCode == 200) {
                                      Get.find<RideController>()
                                          .updateRideCurrentState(
                                              RideState.completeRide);
                                      Get.find<MapController>()
                                          .notifyMapController();
                                      await Get.find<RideController>()
                                          .getFinalFare(
                                              rideController.tripDetails!.id!);
                                      Get.offAll(() => const PaymentScreen());
                                    }
                                  });
                                }
                              })),
                    ],
                  )
                ],
              );
      });
    });
  }
}
