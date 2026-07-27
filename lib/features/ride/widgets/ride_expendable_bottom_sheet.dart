import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/widget/accepting_ongoing_bottomsheet.dart';
import 'package:ride_sharing_user_app/features/map/widget/initial_widget.dart';
import 'package:ride_sharing_user_app/features/map/widget/otp_sent_bottomsheet.dart';
import 'package:ride_sharing_user_app/features/map/widget/risefare_bottomsheet.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/finding_rider_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/rider_details.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RideExpendableBottomSheet extends StatefulWidget {
  final GlobalKey<ExpandableBottomSheetState> expandableKey;

  const RideExpendableBottomSheet({super.key, required this.expandableKey});

  @override
  State<RideExpendableBottomSheet> createState() =>
      _RideExpendableBottomSheetState();
}

class _RideExpendableBottomSheetState extends State<RideExpendableBottomSheet> {
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (carRideController) {
      return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.paddingSizeDefault),
            topRight: Radius.circular(Dimensions.paddingSizeDefault),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).hintColor,
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeDefault),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  height: 7,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor,
                    borderRadius:
                        BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  )),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault,
                  0,
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeDefault,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween),
              ),
              GetBuilder<RideController>(builder: (rideController) {
                return GetBuilder<LocationController>(
                    builder: (locationController) {
                  String firstRoute = '';
                  String secondRoute = '';
                  List<dynamic> extraRoute = [];
                  if (rideController.tripDetails?.intermediateAddresses !=
                          null &&
                      rideController.tripDetails?.intermediateAddresses !=
                          '["",""]') {
                    extraRoute = jsonDecode(
                        rideController.tripDetails!.intermediateAddresses!);
                    if (extraRoute.isNotEmpty) {
                      firstRoute = extraRoute[0].toString();
                    }
                    if (extraRoute.isNotEmpty && extraRoute.length > 1) {
                      secondRoute = extraRoute[1].toString();
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      (rideController.currentRideState == RideState.initial)
                          ? InitialWidget(expandableKey: widget.expandableKey)
                          : (rideController.currentRideState ==
                                  RideState.riseFare)
                              ? RaiseFareBottomSheet(
                                  expandableKey: widget.expandableKey)
                              : (rideController.currentRideState ==
                                      RideState.findingRider)
                                  ? FindingRiderWidget(
                                      expandableKey: widget.expandableKey,
                                      fromPage: FindingRide.ride)
                                  : (rideController.currentRideState ==
                                          RideState.acceptingRider)
                                      ? AcceptingAndOngoingBottomSheet(
                                          firstRoute: firstRoute,
                                          secondRoute: secondRoute,
                                          expandableKey: widget.expandableKey,
                                        )
                                      : (rideController.currentRideState ==
                                              RideState.otpSent)
                                          ? OtpSentBottomSheet(
                                              firstRoute: firstRoute,
                                              secondRoute: secondRoute,
                                              expandableKey:
                                                  widget.expandableKey,
                                            )
                                          : (rideController.currentRideState ==
                                                  RideState.ongoingRide)
                                              ? Column(children: [
                                                  Chip(
                                                    avatar: const Icon(
                                                      Icons
                                                          .directions_car_filled_rounded,
                                                      size: 18,
                                                      color: Color(0xFFE71921),
                                                    ),
                                                    label: Text(
                                                      'trip_is_ongoing'.tr,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Color(0xFFE71921),
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        const Color(0xFFFFF5F5),
                                                    side: const BorderSide(
                                                      color: Color(0xFFFFCDD2),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: Dimensions
                                                            .paddingSize),
                                                    child: Text.rich(TextSpan(
                                                      style: textRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeLarge,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .color!
                                                                  .withValues(
                                                                      alpha:
                                                                          0.8)),
                                                      children: [
                                                        TextSpan(
                                                            text:
                                                                'you_are_on_the_way_to_destination'
                                                                    .tr)
                                                      ],
                                                    )),
                                                  ),
                                                  const ActivityScreenRiderDetails(),
                                                  const SizedBox(
                                                      height: Dimensions
                                                          .paddingSize),
                                                ])
                                              : const SizedBox(),
                    ]),
                  );
                });
              }),
            ])),
      );
    });
  }
}
