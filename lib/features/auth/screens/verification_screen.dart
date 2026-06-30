import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class VerificationScreen extends StatefulWidget {
  final String number;
  final bool fromOtpLogin;
  final bool fromForgotPassword;

  const VerificationScreen({
    super.key,
    required this.number,
    this.fromOtpLogin = false,
    this.fromForgotPassword = false,
  });

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  Timer? _timer;
  int? _seconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _seconds = Get.find<ConfigController>().config!.otpResendTime;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds! - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: GetBuilder<AuthController>(builder: (authController) {
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Image.asset(
                  Images.waveClipperTwo,
                  fit: BoxFit.fitWidth,
                ),
              ),
              const SizedBox(
                height:
                    Dimensions.paddingSizeSignUp + Dimensions.paddingSizeTwo,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: Dimensions.paddingSizeSixteen,
                    right: Dimensions.paddingSizeSixteen),
                child: Column(
                  children: [
                    Text(
                      'otp_verification'.tr,
                      style: textBold.copyWith(
                        color: const Color.fromRGBO(255, 0, 0, 0.7),
                        fontSize: Dimensions.paddingSizeThirty,
                      ),
                    ),
                    Text('six_digit_code'.tr,
                        style: textMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall)),
                    (Get.find<ConfigController>().config?.isDemo ?? true)
                        ? Padding(
                            padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall)
                                .copyWith(
                              bottom: Dimensions.paddingSizeOverLarge,
                            ),
                            child: Text('for_demo_purpose_use'.tr,
                                style: textMedium.copyWith(
                                  color: Theme.of(context).disabledColor,
                                )),
                          )
                        : const SizedBox(
                            height: Dimensions.paddingSizeExtraLarge,
                          ),
                    PinCodeTextField(
                      length: 6,
                      appContext: context,
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.slide,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        fieldHeight: 50,
                        fieldWidth: 50,
                        borderWidth: 1,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        selectedColor: const Color.fromRGBO(250, 173, 2, 1),
                        activeColor: const Color.fromRGBO(250, 173, 2, 1),
                        selectedFillColor: Get.isDarkMode
                            ? Colors.grey.withValues(alpha: 0.6)
                            : Colors.white,
                        inactiveFillColor: Colors.white,
                        inactiveColor: Colors.grey,
                        activeFillColor: Colors.white,
                      ),
                      animationDuration: const Duration(milliseconds: 300),
                      backgroundColor: Colors.transparent,
                      enableActiveFill: true,
                      onChanged: authController.updateVerificationCode,
                      beforeTextPaste: (text) => true,
                      textStyle: textSemiBold.copyWith(),
                      pastedTextStyle: textRegular.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium!.color),
                    ),
                    _seconds! <= 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'did_not_receive_the_code_?'.tr,
                                style: textMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color:
                                        const Color.fromRGBO(20, 20, 20, 0.7)),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  overlayColor: Colors.transparent,
                                ),
                                onPressed: () {
                                  authController
                                      .sendOtp(widget.number)
                                      .then((value) {
                                    if (value.statusCode == 200) {
                                      _startTimer();
                                    }
                                  });
                                },
                                child: Text('resend_otp'.tr,
                                    style: textMedium.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: const Color.fromRGBO(
                                            255, 0, 0, 0.7)),
                                    textAlign: TextAlign.end),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    _seconds! > 0
                        ? Text(
                            '${'resend_it'.tr} ${'after'.tr} ${_seconds! > 0 ? '($_seconds)' : ''} ${'sec'.tr}',
                          )
                        : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeSix),
                    authController.verificationCode.length == 6
                        ? (!authController.otpVerifying &&
                                !authController.isLoading)
                            ? ButtonWidget(
                                buttonText: widget.fromOtpLogin
                                    ? 'log_in'.tr
                                    : 'verify'.tr,
                                textColor:
                                    const Color.fromRGBO(255, 255, 255, 1),
                                borderColor:
                                    const Color.fromRGBO(255, 128, 128, 0.2),
                                backgroundColor:
                                    const Color.fromRGBO(250, 173, 2, 1),
                                fontSize: 18.0,
                                onPressed: () {
                                  if (widget.fromForgotPassword) {
                                    authController.otpVerification(
                                      widget.number,
                                      authController.verificationCode,
                                      accountVerification: false,
                                    );
                                  } else if (widget.fromOtpLogin) {
                                    authController.otpLogin(
                                      widget.number,
                                      authController.verificationCode,
                                      fromOtpLogin: widget.fromOtpLogin,
                                    );
                                  } else {
                                    authController.otpVerification(
                                      widget.number,
                                      authController.verificationCode,
                                      accountVerification: true,
                                    );
                                  }
                                },
                              )
                            : const SpinKitCircle(
                                color: Color.fromRGBO(250, 173, 2, 1),
                                size: 40.0,
                              )
                        : const SizedBox.shrink(),
                    const SizedBox(
                        height: Dimensions.iconSizeOnline +
                            Dimensions.paddingSizeDefault +
                            Dimensions.paddingSizeThree),
                    Center(
                        child: Image.asset(
                      Images.sevenTaxi,
                      height: 30,
                      width: 190,
                    )),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
