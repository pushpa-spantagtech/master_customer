import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/payment/widget/payment_item_info_widget.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/trip_route_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripDetailWidget extends StatelessWidget {
  final TripDetails tripDetails;

  const TripDetailWidget({super.key, required this.tripDetails});

  @override
  Widget build(BuildContext context) {
    String firstRoute = '';
    String secondRoute = '';
    List<dynamic> extraRoute = [];
    if (tripDetails.intermediateAddresses != null &&
        tripDetails.intermediateAddresses != '[[, ]]') {
      extraRoute = jsonDecode(tripDetails.intermediateAddresses!);

      if (extraRoute.isNotEmpty) {
        firstRoute = extraRoute[0];
      }
      if (extraRoute.isNotEmpty && extraRoute.length > 1) {
        secondRoute = extraRoute[1];
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'trip_details'.tr,
                style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: const Color.fromRGBO(20, 20, 20, 1)),
              ),
              const SizedBox(
                height: Dimensions.paddingSizeSmall,
              ),
              TripRouteWidget(
                pickupAddress: tripDetails.pickupAddress!,
                destinationAddress: tripDetails.destinationAddress!,
                extraOne: firstRoute,
                extraTwo: secondRoute,
                entrance: tripDetails.entrance,
              ),
              const SizedBox(
                height: Dimensions.paddingSize,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Image.asset(
                    Images.profileMyWallet,
                    height: 15,
                    width: 15,
                    color: const Color.fromRGBO(250, 173, 2, 1),
                  ),
                  const SizedBox(
                    width: Dimensions.paddingSizeSmall,
                  ),
                  Text(
                    'total_distance'.tr,
                    style: textMedium.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .color!
                          .withValues(alpha: 0.8),
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ]),
                Text(
                  '${tripDetails.actualDistance!}km',
                  style: textSemiBold.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .color!
                        .withValues(alpha: 0.8),
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                )
              ])
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.2))),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            children: [
              PaymentItemInfoWidget(
                  icon: Images.farePrice,
                  title: 'fare_price'.tr,
                  amount: tripDetails.distanceWiseFare ?? 0),
              PaymentItemInfoWidget(
                  icon: Images.idleHourIcon,
                  title: 'idle_price'.tr,
                  amount: tripDetails.idleFee ?? 0),
              PaymentItemInfoWidget(
                  icon: Images.waitingPrice,
                  title: 'delay_price'.tr,
                  amount: tripDetails.delayFee ?? 0),
              PaymentItemInfoWidget(
                  icon: Images.idleHourIcon,
                  title: 'cancellation_price'.tr,
                  amount: tripDetails.cancellationFee ?? 0),
              PaymentItemInfoWidget(
                icon: Images.coupon,
                title: 'coupon'.tr,
                amount: tripDetails.couponAmount ?? 0,
                discount: true,
              ),
              PaymentItemInfoWidget(
                icon: Images.coupon,
                title: 'discount'.tr,
                amount: tripDetails.discountAmount ?? 0,
                discount: true,
              ),
              PaymentItemInfoWidget(
                  icon: Images.farePrice,
                  title: 'tips'.tr,
                  amount: tripDetails.tips ?? 0),
              PaymentItemInfoWidget(
                  icon: Images.farePrice,
                  title: 'vat_tax'.tr,
                  amount: tripDetails.vatTax ?? 0),
              PaymentItemInfoWidget(
                title: 'sub_total'.tr,
                amount: tripDetails.paidFare ?? 0,
                isSubTotal: true,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Image.asset(
                    Images.profileMyWallet,
                    color: const Color.fromRGBO(250, 173, 2, 1),
                    height: 15,
                    width: 15,
                  ),
                  const SizedBox(
                    width: Dimensions.paddingSizeSmall,
                  ),
                  Text(
                    'payment'.tr,
                    style: textSemiBold.copyWith(
                        color: const Color.fromRGBO(20, 20, 20, 1),
                        fontSize: Dimensions.fontSizeSmall),
                  )
                ]),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      tripDetails.paymentMethod!.tr,
                      style: textSemiBold.copyWith(
                          color: const Color.fromRGBO(20, 20, 20, 1),
                          fontSize: Dimensions.fontSizeSmall),
                    ))
              ])
            ],
          ),
        )
      ],
    );
  }
}
