import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/tolltip_widget.dart';
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
  static const Color _brandRed = Color(0xFFE71921);
  static const Color _brandGold = Color(0xFFFFB100);
  bool _cancelDialogOpen = false;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    Get.find<RideController>().countingTimeStates();
  }

  Future<void> _showCancelSearchDialog(RideController rideController) async {
    if (_cancelDialogOpen || _isCancelling) return;

    final tripId = rideController.tripDetails?.id;
    if (tripId == null || tripId.isEmpty) return;

    _cancelDialogOpen = true;

    try {
      await Get.dialog(
        StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> cancelRide() async {
              if (_isCancelling) return;

              _isCancelling = true;
              if (context.mounted) {
                setDialogState(() {});
              }

              try {
                final response = await rideController
                    .tripStatusUpdate(
                      tripId,
                      'cancelled',
                      'ride_request_cancelled_successfully',
                      '',
                    )
                    .timeout(const Duration(seconds: 20));

                if (response.statusCode != 200) {
                  _isCancelling = false;
                  if (context.mounted) {
                    setDialogState(() {});
                  }
                  return;
                }

                _isCancelling = false;

                if (Get.isDialogOpen ?? false) {
                  Get.back();
                }

                rideController.updateRideCurrentState(RideState.initial);
                Get.find<MapController>().notifyMapController();
                rideController.clearRideDetails();
                Get.find<BottomMenuController>().navigateToDashboard();
              } on TimeoutException {
                _isCancelling = false;
                if (context.mounted) {
                  setDialogState(() {});
                }
              } catch (_) {
                _isCancelling = false;
                if (context.mounted) {
                  setDialogState(() {});
                }
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFECEE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: _brandRed,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'are_you_sure'.tr,
                      textAlign: TextAlign.center,
                      style: textBold.copyWith(
                        fontSize: 22,
                        color: const Color(0xFF121A2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'you_want_to_cancel_searching'.tr,
                      textAlign: TextAlign.center,
                      style: textMedium.copyWith(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isCancelling ? null : () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _isCancelling
                              ? Colors.grey.shade300
                              : const Color(0xFFFFF1C7),
                          foregroundColor:
                              _isCancelling ? Colors.grey.shade600 : _brandGold,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'keep_searching'.tr,
                          style: textBold.copyWith(
                            color: _isCancelling
                                ? Colors.grey.shade600
                                : _brandGold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isCancelling ? null : cancelRide,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _brandRed,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _brandRed,
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isCancelling
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'cancel_searching'.tr,
                                style: textBold.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        barrierDismissible: false,
      );
    } finally {
      _cancelDialogOpen = false;
      _isCancelling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      return GetBuilder<ParcelController>(builder: (parcelController) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Column(
            children: [
              TollTipWidget(
                showInsight: false,
                title: rideController.selectedCategory == RideType.parcel
                    ? 'deliveryman'
                    : 'rider_finding',
              ),
              const SizedBox(height: Dimensions.paddingSize),
              const _SearchingOrangeProgress(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeDefault,
                ),
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
                                ? 'looks_like_riders_around_you_are_busy_now'.tr
                                : 'looks_like_riders_around_you_are_not_interested'
                                    .tr,
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                ),
                textAlign: TextAlign.center,
              ),
              (rideController.stateCount == 2 ||
                      widget.fromPage == FindingRide.parcel)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'please_hold_on_a_little_more'.tr,
                        style: textMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
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
                      rideController.initCountingTimeStates(isRestart: true);
                    },
                    radius: 10,
                    textColor: _brandGold,
                    borderColor: const Color.fromRGBO(0, 0, 0, 0.1),
                    backgroundColor: const Color.fromRGBO(255, 239, 203, 1),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: Dimensions.paddingSizeExtraOverLarge,
                    right: Dimensions.paddingSizeExtraOverLarge,
                    bottom: Dimensions.paddingSizeDefault,
                  ),
                  // child: ButtonWidget(
                  //   buttonText: 'rise_fare'.tr,
                  //   textColor: Colors.white,
                  //   borderColor: const Color.fromRGBO(255, 128, 128, 0.2),
                  //   backgroundColor: _brandGold,
                  //   onPressed: () {
                  //     rideController.updateRideCurrentState(RideState.riseFare);
                  //   },
                  //   radius: 10,
                  // ),
                ),
              ],
              if (widget.fromPage == FindingRide.parcel)
                const SizedBox(height: Dimensions.paddingSizeDefault),
              if (!(rideController.stateCount == 3 &&
                  widget.fromPage == FindingRide.ride))
                Padding(
                  padding: const EdgeInsets.only(
                    top: Dimensions.paddingSizeDefault,
                    bottom: Dimensions.paddingSizeDefault,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => _showCancelSearchDialog(rideController),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: _brandRed,
                        size: 22,
                      ),
                      label: Text(
                        'cancel_searching'.tr,
                        style: textBold.copyWith(
                          color: _brandRed,
                          fontSize: 16,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: _brandRed,
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      });
    });
  }
}

class _SearchingOrangeProgress extends StatefulWidget {
  const _SearchingOrangeProgress({super.key});

  @override
  State<_SearchingOrangeProgress> createState() =>
      _SearchingOrangeProgressState();
}

class _SearchingOrangeProgressState extends State<_SearchingOrangeProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        height: 4,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => LinearProgressIndicator(
            value: _controller.value,
            minHeight: 4,
            backgroundColor: const Color(0xFFE5E5E5),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFB100)),
          ),
        ),
      ),
    );
  }
}
