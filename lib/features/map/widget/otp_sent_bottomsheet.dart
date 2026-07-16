import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/common_widgets/swipable_button_widget/slider_button_widget.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/widget/cancelation_radio_button.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/otp_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/route_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/estimated_fare_and_distance.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/rider_details.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class OtpSentBottomSheet extends StatefulWidget {
  final String firstRoute;
  final String secondRoute;
  final GlobalKey<ExpandableBottomSheetState> expandableKey;

  const OtpSentBottomSheet(
      {super.key,
      required this.firstRoute,
      required this.secondRoute,
      required this.expandableKey});

  @override
  State<OtpSentBottomSheet> createState() => _OtpSentBottomSheetState();
}

class _OtpSentBottomSheetState extends State<OtpSentBottomSheet> {
  int currentState = 0;
  bool _isSubmittingCancellation = false;

  @override
  Widget build(BuildContext context) {
    final double buttonHeight = MediaQuery.of(context).size.height * 0.055;

    return GetBuilder<RideController>(builder: (rideController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        return currentState == 0
            ? Column(children: [
                const OtpWidget(fromPage: true),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                const EstimatedFareAndDistance(),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                const ActivityScreenRiderDetails(),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSize),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'trip_details'.tr,
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: const Color.fromRGBO(20, 20, 20, 1),
                      ),
                    ),
                  ),
                ),
                RouteWidget(
                  totalDistance: rideController.tripDetails?.estimatedDistance
                          .toString() ??
                      '',
                  fromAddress: rideController.tripDetails?.pickupAddress ?? '',
                  toAddress:
                      rideController.tripDetails?.destinationAddress ?? '',
                  extraOneAddress: widget.firstRoute,
                  extraTwoAddress: widget.secondRoute,
                  entrance: rideController.tripDetails?.entrance ?? '',
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8EAF0),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            Images.farePrice,
                            height: 17,
                            width: 17,
                            color: const Color(0xFFFFA800),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'fare_price'.tr,
                              style: textRegular.copyWith(
                                color: const Color(0xFF1C1B1F),
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFAEC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFFB000),
                              ),
                            ),
                            child: Text(
                              PriceConverter.convertPrice(
                                rideController.tripDetails?.actualFare ??
                                    rideController.tripDetails?.estimatedFare ??
                                    0,
                              ),
                              style: textBold.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: const Color(0xFF1C1B1F),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Image.asset(
                            Images.paymentTypeIcon,
                            height: 17,
                            width: 17,
                            color: const Color(0xFFFFA800),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'payment'.tr,
                              style: textRegular.copyWith(
                                color: const Color(0xFF1C1B1F),
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                          ),
                          Text(
                            rideController.tripDetails?.paymentMethod
                                    ?.replaceAll(RegExp('[\\W_]+'), ' ')
                                    .capitalize ??
                                'cash'.tr,
                            style: textMedium.copyWith(
                              color: const Color(0xFF1C1B1F),
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight.clamp(48.0, 50.0),
                  child: FilledButton(
                    onPressed: () {
                      currentState = 1;
                      widget.expandableKey.currentState?.expand();
                      setState(() {});
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE71921),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero, // Remove default padding
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cancel Ride',
                      style: textSemiBold.copyWith(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ])
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 15,
                          color: Color(0xFFFF9F0A),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'rider_arrived'.tr,
                          style: textMedium.copyWith(
                            color: const Color(0xFF6F4E00),
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const CancellationRadioButton(
                    isOngoing: false,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmittingCancellation
                              ? null
                              : () {
                                  currentState = 0;
                                  setState(() {});
                                },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            foregroundColor: const Color(0xFF121A2C),
                            side: const BorderSide(
                              color: Color(0xFFD9DDE7),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Continue Ride',
                            textAlign: TextAlign.center,
                            style: textSemiBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _isSubmittingCancellation
                              ? null
                              : () async {
                                  setState(() {
                                    _isSubmittingCancellation = true;
                                  });

                                  Get.find<RideController>()
                                      .stopLocationRecord();

                                  try {
                                    final value =
                                        await rideController.tripStatusUpdate(
                                      rideController.tripDetails!.id!,
                                      'cancelled',
                                      'ride_request_cancelled_successfully',
                                      Get.find<TripController>()
                                          .tripCancellationCauseList!
                                          .data!
                                          .acceptedRide![Get.find<
                                              TripController>()
                                          .tripCancellationCauseCurrentIndex],
                                    );

                                    if (value.statusCode == 200) {
                                      Get.find<MapController>()
                                          .notifyMapController();
                                      Get.find<BottomMenuController>()
                                          .navigateToDashboard();
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isSubmittingCancellation = false;
                                      });
                                    }
                                  }
                                },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: const Color(0xFFE71921),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFFE71921).withValues(alpha: 0.65),
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSubmittingCancellation
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'submit'.tr,
                                  style: textSemiBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
      });
    });
  }
}
