import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/fare_widget.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

class EstimatedFareAndDistance extends StatelessWidget {
  final bool fromPickLocation;
  final bool isParcel;

  const EstimatedFareAndDistance(
      {super.key, this.fromPickLocation = false, this.isParcel = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      return rideController.remainingDistanceModel != null &&
              rideController.remainingDistanceModel!.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  border:
                      Border.all(color: const Color.fromRGBO(0, 0, 0, 0.1))),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(
                  mainAxisAlignment: rideController.currentRideState ==
                          RideState.acceptingRider
                      ? MainAxisAlignment.spaceEvenly
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    FareWidget(
                        title: 'distance_away'.tr,
                        value: (rideController.remainingDistanceModel != null &&
                                rideController
                                    .remainingDistanceModel!.isNotEmpty)
                            ? rideController
                                    .remainingDistanceModel![0].distanceText ??
                                '0'
                            : '0'),
                    FareWidget(
                        title: 'fare_price'.tr,
                        value: PriceConverter.convertPrice(fromPickLocation
                                ? rideController.estimatedFare
                                : rideController.tripDetails?.paymentStatus ==
                                        'paid'
                                    ? rideController.tripDetails?.paidFare ?? 0
                                    : rideController.tripDetails?.actualFare ??
                                        0
                            // fromPickLocation
                            //     ? rideController.estimatedFare
                            //     : rideController.tripDetails?.paymentStatus ==
                            //             'paid'
                            //         ? rideController.tripDetails?.paidFare ?? 0
                            //         : ((rideController.tripDetails
                            //                         ?.discountAmount ??
                            //                     0) >
                            //                 0)
                            //             ? rideController.tripDetails
                            //                     ?.discountActualFare ??
                            //                 0
                            //             : rideController
                            //                     .tripDetails?.actualFare ??
                            //                 0,
                            )),
                  ]),
            )
          : const SizedBox();
    });
  }
}
