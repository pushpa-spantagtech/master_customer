import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
import 'package:ride_sharing_user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/home/controllers/banner_controller.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/home/screens/ride_bottom_sheet.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_map_view.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/my_offer/controller/offer_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/driver_request_dialog.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/notification/screens/notification_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/helper/home_screen_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import '../../auth/controllers/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOpeningOngoingRide = false;
  DateTime? _lastOngoingRideClosedAt;

  static const Color _brandRed = Color(0xFFE71921);
  static const Color _brandGold = Color(0xFFFFB100);
  static const Color _ink = Color(0xFF121A2C);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  String greetingMessage() {
    final timeNow = DateTime.now().hour;
    if (timeNow <= 12) return 'good_morning'.tr;
    if (timeNow <= 16) return 'good_afternoon'.tr;
    if (timeNow < 20) return 'good_evening'.tr;
    return 'good_night'.tr;
  }

  Future<void> loadData() async {
    final parcelController = Get.find<ParcelController>();
    final bannerController = Get.find<BannerController>();
    final categoryController = Get.find<CategoryController>();
    final addressController = Get.find<AddressController>();
    final couponController = Get.find<CouponController>();
    final offerController = Get.find<OfferController>();
    final profileController = Get.find<ProfileController>();
    final rideController = Get.find<RideController>();

    await Future.wait<void>([
      parcelController.getUnpaidParcelList().then((_) {}),
      bannerController.getBannerList().then((_) {}),
      categoryController.getCategoryList().then((_) {}),
      addressController.getAddressList(1).then((_) {}),
      couponController.getCouponList(1, isUpdate: false).then((_) {}),
      offerController.getOfferList(1).then((_) {}),
      if (profileController.profileModel == null)
        profileController.getProfileInfo().then((_) {}),
    ]);

    await rideController.getCurrentRide();

    final currentTrip = rideController.currentTripDetails;
    if (currentTrip != null) {
      rideController.getBiddingList(currentTrip.id!, 1);
      PusherHelper().pusherDriverStatus(currentTrip.id!);

      final status = currentTrip.currentStatus;
      if (status == 'accepted' || status == 'ongoing') {
        rideController.startLocationRecord();
      }
    } else {
      rideController.clearBiddingList();
    }

    await parcelController.getOngoingParcelList();
    final ongoingParcels = parcelController.parcelListModel?.data;
    if (ongoingParcels?.isNotEmpty ?? false) {
      for (final element in ongoingParcels!) {
        PusherHelper().pusherDriverStatus(element.id!);
      }
    }

    final userAddress = Get.find<LocationController>().getUserAddress();
    if (userAddress?.latitude != null && userAddress?.longitude != null) {
      rideController.getNearestDriverList(
        userAddress!.latitude!.toString(),
        userAddress.longitude!.toString(),
      );
    }

    HomeScreenHelper().checkMaintanceMode();
  }

  Future<void> _openOngoingRideSafely() async {
    if (_isOpeningOngoingRide || !mounted) return;

    _isOpeningOngoingRide = true;

    try {
      // After returning from MapScreen, Flutter may still be finishing the
      // pop animation. Wait only for the remaining cooldown time.
      final closedAt = _lastOngoingRideClosedAt;
      if (closedAt != null) {
        const cooldown = Duration(milliseconds: 450);
        final elapsed = DateTime.now().difference(closedAt);

        if (elapsed < cooldown) {
          await Future<void>.delayed(cooldown - elapsed);
        }
      }

      if (!mounted) return;

      final rideController = Get.find<RideController>();
      final currentRide = rideController.rideDetails;

      if (currentRide == null) return;

      final status = currentRide.currentStatus ?? '';

      if (status != 'pending' &&
          status != 'accepted' &&
          status != 'ongoing') {
        return;
      }

      // Use data already loaded on HomeScreen. Do not call the API here,
      // because polling may be running at the same time.
      rideController.tripDetails ??= currentRide;

      if (status == 'pending') {
        rideController.updateRideCurrentState(RideState.findingRider);
      } else if (status == 'ongoing') {
        rideController.updateRideCurrentState(RideState.ongoingRide);
      } else {
        rideController.updateRideCurrentState(RideState.acceptingRider);
      }

      // Schedule the push after the current frame has completed.
      await WidgetsBinding.instance.endOfFrame;

      if (!mounted) return;

      final navigator = Navigator.of(context, rootNavigator: true);

      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const MapScreen(
            fromScreen: MapScreenType.splash,
          ),
        ),
      );

      _lastOngoingRideClosedAt = DateTime.now();
    } finally {
      _isOpeningOngoingRide = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FB),
        extendBodyBehindAppBar: true,
        body: GetBuilder<RideController>(builder: (rideController) {
          return GetBuilder<ParcelController>(builder: (parcelController) {
            final int parcelCount = 0;
            final int rideCount = (rideController.rideDetails != null &&
                rideController.rideDetails!.type == 'ride_request' &&
                (rideController.rideDetails!.currentStatus == 'pending' ||
                    rideController.rideDetails!.currentStatus ==
                        'accepted' ||
                    rideController.rideDetails!.currentStatus ==
                        'ongoing' ||
                    (rideController.rideDetails!.currentStatus ==
                        'completed' &&
                        rideController.rideDetails!.paymentStatus ==
                            'unpaid') ||
                    (rideController.rideDetails!.currentStatus ==
                        'cancelled' &&
                        rideController.rideDetails!.paymentStatus ==
                            'unpaid')))
                ? 1
                : 0;

            return RefreshIndicator(
              color: _brandGold,
              onRefresh: loadData,
              child: Stack(
                children: [
                  const Positioned.fill(child: HomeMapView(fullScreen: true)),
                  const Positioned.fill(child: _MapTopGradient()),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 16,
                    right: 16,
                    child: _PremiumHomeHeader(
                      greeting: greetingMessage(),
                      onMenuTap: () {
                        Get.find<BottomMenuController>().setTabIndex(3);
                      },
                      onNotificationTap: () =>
                          Get.to(() => const NotificationScreen()),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 88,
                    left: 18,
                    right: 18,
                    child: _PickupLocationPill(),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: MediaQuery.of(context).size.height * 0.52,
                    child: const RideBottomSheet(),
                  ),
                  if ((rideCount + parcelCount) != 0)
                    Positioned(
                      right: -2,
                      top: Get.height * 0.32,
                      child: GestureDetector(
                        onTap: _openOngoingRideSafely,
                        child: _OngoingRideFab(
                          count: rideCount + parcelCount,
                        ),
                      ),
                    ),
                ],
              ),
            );
          });
        }),
        floatingActionButton:
        GetBuilder<RideController>(builder: (rideController) {
          return rideController.biddingList.isNotEmpty
              ? Padding(
            padding: EdgeInsets.only(bottom: Get.height * 0.10),
            child: FloatingActionButton(
              onPressed: () {
                if (!rideController.isLoading) {
                  rideController
                      .getBiddingList(
                      rideController.currentTripDetails!.id!, 1)
                      .then((value) {
                    if (rideController.biddingList.isNotEmpty) {
                      Get.dialog(
                        barrierDismissible: true,
                        barrierColor: Colors.black.withValues(alpha: 0.5),
                        transitionDuration:
                        const Duration(milliseconds: 500),
                        DriverRideRequestDialog(
                          tripId: Get.find<RideController>()
                              .currentTripDetails!
                              .id!,
                        ),
                      );
                    }
                  });
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Image.asset(Images.biddingIcon),
            ),
          )
              : const SizedBox();
        }),
      ),
    );
  }
}

class _MapTopGradient extends StatelessWidget {
  const _MapTopGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.96),
              Colors.white.withValues(alpha: 0.70),
              Colors.white.withValues(alpha: 0.00),
            ],
            stops: const [0.0, 0.12, 0.32],
          ),
        ),
      ),
    );
  }
}

class _PremiumHomeHeader extends StatelessWidget {
  final String greeting;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;

  const _PremiumHomeHeader({
    required this.greeting,
    required this.onMenuTap,
    required this.onNotificationTap,
  });

  static const Color _brandRed = Color(0xFFE71921);
  static const Color _ink = Color(0xFF121A2C);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _HeaderButton(icon: Icons.menu_rounded, onTap: onMenuTap),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Image.asset(
                  Images.logo,
                  height: 38,
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome, ${Get.find<ProfileController>().customerFirstName() ?? ''}',
                  style: textMedium.copyWith(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _HeaderButton(
                  icon: Icons.notifications_none_rounded,
                  onTap: onNotificationTap),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: _brandRed, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FB),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Icon(icon, color: const Color(0xFF121A2C), size: 24),
      ),
    );
  }
}

class _PickupLocationPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(builder: (locationController) {
      final text = locationController.getUserAddress()?.address ??
          locationController.fromAddress?.address ??
          'current_location'.tr;
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: Get.width * 0.78),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Color(0xFF16A34A), shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textMedium.copyWith(
                      color: const Color(0xFF121A2C), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _OngoingRideFab extends StatelessWidget {
  final int count;

  const _OngoingRideFab({required this.count});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'ongoing_ride'.tr,
      child: Semantics(
        button: true,
        label: 'ongoing_ride'.tr,
        child: Container(
          width: 58,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            border: Border.all(
              color: const Color(0xFFFFD4D6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(-2, 5),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 3),
                child: _RoutePinIcon(),
              ),
              Positioned(
                left: -7,
                top: -7,
                child: Container(
                  width: 23,
                  height: 23,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE71921),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: textBold.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutePinIcon extends StatelessWidget {
  const _RoutePinIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 4,
            right: 4,
            bottom: 1,
            child: Container(
              height: 27,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F8),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: const Color(0xFFE3E5EA),
                ),
              ),
              child: const CustomPaint(
                painter: _DashedRoutePainter(),
              ),
            ),
          ),
          const Positioned(
            top: -2,
            child: Icon(
              Icons.location_on_rounded,
              size: 30,
              color: Color(0xFFE71921),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedRoutePainter extends CustomPainter {
  const _DashedRoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE71921)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.70)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.20,
        size.width * 0.62,
        size.height * 1.00,
        size.width * 0.82,
        size.height * 0.38,
      );

    const dashLength = 3.0;
    const gapLength = 2.2;

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(
          metric.extractPath(distance, end),
          paint,
        );
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoutePainter oldDelegate) => false;
}
