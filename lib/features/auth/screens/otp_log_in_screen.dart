import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_up_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/screens/verification_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';

class OtpLoginScreen extends StatefulWidget {
  final bool fromSignIn;

  const OtpLoginScreen({super.key, this.fromSignIn = false});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  TextEditingController phoneController = TextEditingController();
  FocusNode phoneNode = FocusNode();

  @override
  void initState() {
    super.initState();

    Get.find<AuthController>().countryDialCode = CountryCode.fromCountryCode(
            Get.find<ConfigController>().config!.countryCode!)
        .dialCode!;
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
                height: Dimensions.paddingSizeSix,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    right: Dimensions.paddingSizeSixteen,
                    left: Dimensions.paddingSizeSixteen,
                    bottom: Dimensions.paddingSizeSixteen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Image.asset(Images.logoWithName, height: 75)),
                    const SizedBox(
                      height: Dimensions.paddingSizeThirty +
                          Dimensions.paddingSizeSixteen,
                    ),
                    Text(
                      'otp_login'.tr,
                      style: textBold.copyWith(
                        color: const Color.fromRGBO(255, 0, 0, 0.7),
                        fontSize: Dimensions.paddingSizeThirty,
                      ),
                    ),
                    Text(
                      'verification_code'.tr,
                      style: textMedium.copyWith(
                        color: const Color.fromRGBO(20, 20, 20, 0.6),
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                    const SizedBox(
                      height: Dimensions.paddingSizeSmall,
                    ),
                    CustomTextField(
                      label: 'enter_your_phone_number'.tr,
                      hintText: 'phone'.tr,
                      inputType: TextInputType.phone,
                      countryDialCode: authController.countryDialCode,
                      controller: phoneController,
                      focusNode: phoneNode,
                      inputAction: TextInputAction.done,
                      onCountryChanged: (CountryCode countryCode) {
                        authController.countryDialCode = countryCode.dialCode!;
                        authController.setCountryCode(countryCode.dialCode!);
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSize),
                    authController.isLoading
                        ? const Center(
                            child: SpinKitCircle(
                                color: Color.fromRGBO(250, 173, 2, 1),
                                size: 40.0))
                        : ButtonWidget(
                            buttonText: 'send_otp'.tr,
                            textColor: const Color.fromRGBO(255, 255, 255, 1),
                            borderColor:
                                const Color.fromRGBO(255, 128, 128, 0.2),
                            backgroundColor:
                                const Color.fromRGBO(250, 173, 2, 1),
                            fontSize: 16.0,
                            onPressed: () {
                              String phone = phoneController.text.trim();
                              if (phone.isEmpty) {
                                showCustomSnackBar(
                                    'enter_your_phone_number'.tr);
                                FocusScope.of(context).requestFocus(phoneNode);
                              } else if (!GetUtils.isPhoneNumber(
                                  authController.countryDialCode + phone)) {
                                showCustomSnackBar(
                                    'phone_number_is_not_valid'.tr);
                              } else {
                                authController
                                    .sendOtp(
                                        authController.countryDialCode + phone)
                                    .then((value) {
                                  if (value.statusCode == 200) {
                                    Get.to(() => VerificationScreen(
                                          number:
                                              authController.countryDialCode +
                                                  phone,
                                          fromOtpLogin: widget.fromSignIn,
                                        ));
                                  }
                                });
                              }
                            },
                            radius: 50,
                          ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        '${'do_not_have_an_account'.tr} ',
                        style: textMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: const Color.fromRGBO(20, 20, 20, 0.7),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      TextButton(
                        onPressed: () {
                          Get.off(() => const SignUpScreen());
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          overlayColor: Colors.transparent,
                        ),
                        child: Text('sign_up'.tr,
                            style: textMedium.copyWith(
                              color: const Color.fromRGBO(255, 0, 0, 0.7),
                              fontSize: Dimensions.fontSizeLarge,
                            )),
                      )
                    ]),
                    const SizedBox(
                        height: Dimensions.iconSizeOnline +
                            Dimensions.paddingSizeDefault +
                            Dimensions.paddingSizeLarge),
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
