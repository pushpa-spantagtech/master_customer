import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/util/images.dart';

class OtpCarBikeAnimatedWidget extends StatefulWidget {
  const OtpCarBikeAnimatedWidget({super.key});

  @override
  State<OtpCarBikeAnimatedWidget> createState() =>
      _OtpCarBikeAnimatedWidgetState();
}

class _OtpCarBikeAnimatedWidgetState extends State<OtpCarBikeAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<Offset> leftSlideAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    leftSlideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.ease,
      ),
    );
  }

  @override
  void dispose() {
    animationController.stop();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rideController = Get.find<RideController>();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.6),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.ease,
      builder: (context, value, child) {
        return Center(
          child: SlideTransition(
            position: leftSlideAnimation,
            child: SvgPicture.asset(
              (rideController.tripDetails?.vehicleCategory?.type ?? 'car') ==
                      'car'
                  ? Images.animatedCar
                  : Images.animatedBike,
              height: Get.height * 0.12,
              width: Get.width * 0.10,
            ),
          ),
        );
      },
    );
  }
}
