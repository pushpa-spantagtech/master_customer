import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class OtpWidget extends StatefulWidget {
  final bool fromPage;

  const OtpWidget({super.key, required this.fromPage});

  @override
  State<OtpWidget> createState() => _OtpWidgetState();
}

class _OtpWidgetState extends State<OtpWidget> {
  bool _requestedRideData = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RideController rideController = Get.find<RideController>();
      final String otp = (rideController.tripDetails?.otp ?? '').trim();

      if (otp.length < 4 && !_requestedRideData) {
        _requestedRideData = true;
        rideController.getCurrentRideStatus(
          navigateToMap: false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(
      builder: (rideController) {
        final String otp = (rideController.tripDetails?.otp ?? '').trim();

        // Never interpolate a nullable indexed value. Doing that displays
        // the word "null" (clipped as "nu") while ride data is loading.
        final List<String> otpDigits = List<String>.generate(
          4,
          (index) => otp.length > index ? otp[index] : '',
        );

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeExtraLarge,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeDefault,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (index) => Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(250, 173, 2, 1),
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          Dimensions.paddingSizeSix,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        otpDigits[index],
                        style: textBold.copyWith(
                          fontSize: 28,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .color!
                        .withValues(alpha: 0.8),
                  ),
                  children: [
                    TextSpan(
                      text: 'please'.tr,
                      style: textMedium.copyWith(
                        color: const Color.fromRGBO(20, 20, 20, 0.7),
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    TextSpan(
                      text: 'share_the_pin'.tr,
                      style: textSemiBold.copyWith(
                        color: const Color.fromRGBO(250, 173, 2, 1),
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    TextSpan(
                      text: 'with_the_driver'.tr,
                      style: textMedium.copyWith(
                        color: const Color.fromRGBO(20, 20, 20, 0.7),
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeSixteen),
            ],
          ),
        );
      },
    );
  }
}
