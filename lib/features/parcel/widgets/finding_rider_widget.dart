import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/common_widgets/swipable_button_widget/slider_button_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/tolltip_widget.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

enum FindingRide { ride, parcel }

class FindingRiderWidget extends StatefulWidget {
  final FindingRide fromPage;
  final GlobalKey<ExpandableBottomSheetState> expandableKey;

  const FindingRiderWidget(
      {super.key, required this.fromPage, required this.expandableKey});

  @override
  State<FindingRiderWidget> createState() => _FindingRiderWidgetState();
}

class _FindingRiderWidgetState extends State<FindingRiderWidget> {
  bool isSearching = true;

  @override
  void initState() {
    Get.find<RideController>().countingTimeStates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      return GetBuilder<ParcelController>(builder: (parcelController) {
        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault),
          child: isSearching
              ? Column(children: [
                  TollTipWidget(
                    showInsight: false,
                    title: rideController.selectedCategory == RideType.parcel
                        ? 'deliveryman'
                        : 'rider_finding',
                  ),
                  const SizedBox(height: Dimensions.paddingSize),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.27,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.grey.withValues(alpha: .50),
                            color: const Color.fromRGBO(250, 173, 2, 1),
                            value: rideController.firstCount,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.27,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.grey.withValues(alpha: .50),
                            color: const Color.fromRGBO(250, 173, 2, 1),
                            value: rideController.secondCount,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.27,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.grey.withValues(alpha: .50),
                            color: const Color.fromRGBO(250, 173, 2, 1),
                            value: rideController.thirdCount,
                          ),
                        ),
                      ]),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault),
                    child: Image.asset(
                      rideController.stateCount == 3
                          ? Images.searchingCarIcon
                          : Images.locationIcon,
                      width: 60,
                      height: 60,
                    ),
                  ),
                  Text(
                    widget.fromPage == FindingRide.parcel
                        ? 'finding_deliveryman'.tr
                        : rideController.stateCount == 0
                            ? 'searching_for_rider'.tr
                            : rideController.stateCount == 1
                                ? 'please_wait_just_for_a_moment'.tr
                                : rideController.stateCount == 2
                                    ? 'looks_like_riders_around_you_are_busy_now'
                                        .tr
                                    : 'looks_like_riders_around_you_are_not_interested'
                                        .tr,
                    style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault),
                    textAlign: TextAlign.center,
                  ),
                  (rideController.stateCount == 2 ||
                          widget.fromPage == FindingRide.parcel)
                      ? Text(
                          'please_hold_on_a_little_more'.tr,
                          style: textMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault),
                        )
                      : const SizedBox(),
                  if (rideController.stateCount != 3 &&
                      widget.fromPage == FindingRide.ride)
                    const SizedBox(height: Dimensions.paddingSizeLarge * 2),
                  if (rideController.stateCount == 3 &&
                      widget.fromPage == FindingRide.ride) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault,
                        horizontal: Dimensions.paddingSizeExtraOverLarge,
                      ),
                      child: ButtonWidget(
                        buttonText: 'keep_searching'.tr,
                        onPressed: () {
                          widget.expandableKey.currentState?.contract();
                          rideController.initCountingTimeStates(
                              isRestart: true);
                        },
                        radius: 10,
                        textColor: const Color.fromRGBO(250, 173, 2, 1),
                        borderColor: const Color.fromRGBO(0, 0, 0, 0.1),
                        backgroundColor: const Color.fromRGBO(255, 239, 203, 1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeExtraOverLarge,
                        right: Dimensions.paddingSizeExtraOverLarge,
                        bottom: Dimensions.paddingSizeDefault,
                      ),
                      child: ButtonWidget(
                        buttonText: 'rise_fare'.tr,
                        textColor: const Color.fromRGBO(255, 255, 255, 1),
                        borderColor: const Color.fromRGBO(255, 128, 128, 0.2),
                        backgroundColor: const Color.fromRGBO(250, 173, 2, 1),
                        onPressed: () {
                          rideController
                              .updateRideCurrentState(RideState.riseFare);
                        },
                        radius: 10,
                      ),
                    ),
                  ],
                  if (widget.fromPage == FindingRide.parcel)
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  !(rideController.stateCount == 3 &&
                          widget.fromPage == FindingRide.ride)
                      ? SliderButton(
                          action: () {
                            isSearching = false;
                            widget.expandableKey.currentState?.expand();
                            setState(() {});
                          },
                          label: Text(
                            'cancel_searching'.tr,
                            style: textSemiBold.copyWith(
                                color: const Color.fromRGBO(250, 173, 2, 1)),
                          ),
                          dismissThresholds: 0.2,
                          dismissible: false,
                          shimmer: false,
                          width: 1170,
                          height: 40,
                          buttonSize: 40,
                          radius: 20,
                          icon: Container(
                            width: 38,
                            height: 38,
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
                            )),
                          ),
                          isLtr: Get.find<LocalizationController>().isLtr,
                          boxShadow: const BoxShadow(blurRadius: 0),
                          buttonColor: Colors.transparent,
                          backgroundColor:
                              const Color.fromRGBO(255, 239, 203, 1),
                          baseColor: Theme.of(context).primaryColor,
                        )
                      : const SizedBox(),
                ])
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault),
                    child: Image.asset(Images.cancelRideIcon, width: 70),
                  ),
                  Text('are_you_sure'.tr,
                      style: textMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge)),
                  Text('you_want_to_cancel_searching'.tr,
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).hintColor,
                      )),
                  rideController.isLoading
                      ? const Padding(
                          padding:
                              EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: CircularProgressIndicator(
                            color: Color.fromRGBO(250, 173, 2, 1),
                          ),
                        )
                      : Column(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeDefault,
                              horizontal: Dimensions.paddingSizeExtraOverLarge,
                            ),
                            child: ButtonWidget(
                              buttonText: 'keep_searching'.tr,
                              onPressed: () {
                                widget.expandableKey.currentState?.contract();
                                isSearching = true;
                                setState(() {});
                                rideController.initCountingTimeStates(
                                    isRestart: true);
                              },
                              radius: 10,
                              borderColor: const Color.fromRGBO(0, 0, 0, 0.1),
                              backgroundColor:
                                  const Color.fromRGBO(255, 239, 203, 1),
                              textColor: Get.isDarkMode
                                  ? Colors.white
                                  : const Color.fromRGBO(250, 173, 2, 1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: Dimensions.paddingSizeExtraOverLarge,
                              right: Dimensions.paddingSizeExtraOverLarge,
                              bottom: Dimensions.paddingSizeDefault,
                            ),
                            child: ButtonWidget(
                              buttonText: 'cancel_searching'.tr,
                              textColor: const Color.fromRGBO(255, 255, 255, 1),
                              borderColor:
                                  const Color.fromRGBO(255, 128, 128, 0.2),
                              backgroundColor:
                                  const Color.fromRGBO(250, 173, 2, 1),
                              onPressed: () {
                                widget.expandableKey.currentState?.contract();
                                rideController
                                    .tripStatusUpdate(
                                  rideController.tripDetails!.id!,
                                  'cancelled',
                                  'ride_request_cancelled_successfully',
                                  '',
                                )
                                    .then((value) {
                                  if (value.statusCode == 200) {
                                    rideController.updateRideCurrentState(
                                        RideState.initial);
                                    Get.find<MapController>()
                                        .notifyMapController();
                                    Get.find<RideController>()
                                        .clearRideDetails();
                                    Get.find<BottomMenuController>()
                                        .navigateToDashboard();
                                  }
                                });
                              },
                              radius: 10,
                            ),
                          ),
                        ]),
                  if (rideController.isLoading)
                    const SizedBox(height: Dimensions.paddingSizeSignUp),
                ]),
        );
      });
    });
  }
}
