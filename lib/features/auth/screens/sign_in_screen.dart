import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/google_auth_service.dart';
import 'package:ride_sharing_user_app/features/auth/screens/otp_log_in_screen.dart';
import 'package:ride_sharing_user_app/features/auth/screens/forgot_password_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/message/domain/models/channel_model.dart'
    hide User;
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_up_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  FocusNode phoneNode = FocusNode();
  FocusNode passwordNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (Get.find<AuthController>().getUserNumber().isNotEmpty) {
      phoneController.text = Get.find<AuthController>().getUserNumber();
    }
    passwordController.text = Get.find<AuthController>().getUserPassword();

    if (passwordController.text.isNotEmpty) {
      Get.find<AuthController>().setRememberMe();
    }

    if (Get.find<AuthController>().getLoginCountryCode().isNotEmpty) {
      Get.find<AuthController>().countryDialCode =
          Get.find<AuthController>().getLoginCountryCode();
    } else if (Get.find<ConfigController>().config!.countryCode != null) {
      Get.find<AuthController>().countryDialCode = CountryCode.fromCountryCode(
              Get.find<ConfigController>().config!.countryCode!)
          .dialCode!;
    }
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
                  Images.waveClipperOne,
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
                  children: [
                    Image.asset(Images.logoWithName, height: 75),
                    const SizedBox(
                      height: Dimensions.paddingSizeSmall,
                    ),
                    Text(
                      'get_started'.tr,
                      style: textBold.copyWith(
                          color: const Color.fromRGBO(255, 0, 0, 0.7),
                          fontSize: 30),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      'log_in_message'.tr,
                      style: textRegular.copyWith(
                        color: const Color.fromRGBO(20, 20, 20, 0.6),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    CustomTextField(
                      label: 'mobile_number'.tr,
                      hintText: 'phone'.tr,
                      inputType: TextInputType.phone,
                      countryDialCode: authController.countryDialCode,
                      controller: phoneController,
                      focusNode: phoneNode,
                      nextFocus: passwordNode,
                      inputAction: TextInputAction.next,
                      onCountryChanged: (CountryCode countryCode) {
                        authController.countryDialCode = countryCode.dialCode!;
                        authController.setCountryCode(countryCode.dialCode!);
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeThree),
                    CustomTextField(
                      label: 'password'.tr,
                      hintText: 'enter_password'.tr,
                      inputType: TextInputType.text,
                      prefixIcon: Images.lock,
                      inputAction: TextInputAction.done,
                      isPassword: true,
                      controller: passwordController,
                      focusNode: passwordNode,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeMedium + 1,
                          vertical: Dimensions.paddingSize),
                      child: Row(children: [
                        InkWell(
                          onTap: () => authController.toggleRememberMe(),
                          child: Row(children: [
                            SizedBox(
                                width: 10.0,
                                height: 10.0,
                                child: Transform.scale(
                                  scale: 0.8,
                                  child: Checkbox(
                                    checkColor:
                                        const Color.fromRGBO(255, 255, 255, 1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    activeColor:
                                        const Color.fromRGBO(250, 173, 2, 1),
                                    value: authController.isActiveRememberMe,
                                    onChanged: (bool? isChecked) =>
                                        authController.toggleRememberMe(),
                                  ),
                                )),
                            const SizedBox(width: Dimensions.paddingSizeSix),
                            Text(
                              'remember_me'.tr,
                              style: textMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: const Color.fromRGBO(20, 20, 20, 0.5)),
                            ),
                          ]),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const ForgotPasswordScreen());
                          },
                          child: Text(
                            'forgot_password_?'.tr,
                            style: textMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: const Color.fromRGBO(20, 20, 20, 0.5)),
                          ),
                        ),
                      ]),
                    ),
                    authController.isLoading
                        ? const Center(
                            child: SpinKitCircle(
                            color: Color.fromRGBO(250, 173, 2, 1),
                            size: 40.0,
                          ))
                        : ButtonWidget(
                            textColor: const Color.fromRGBO(255, 255, 255, 1),
                            borderColor:
                                const Color.fromRGBO(255, 128, 128, 0.2),
                            backgroundColor:
                                const Color.fromRGBO(250, 173, 2, 1),
                            fontSize: 18.0,
                            buttonText: 'log_in'.tr,
                            onPressed: () {
                              String phone = phoneController.text.trim();
                              String password = passwordController.text.trim();
                              if (phone.isEmpty) {
                                showCustomSnackBar(
                                    'phone_number_is_required'.tr);
                                FocusScope.of(context).requestFocus(phoneNode);
                              } else if (!GetUtils.isPhoneNumber(
                                  authController.countryDialCode + phone)) {
                                showCustomSnackBar(
                                    'phone_number_is_not_valid'.tr);
                                FocusScope.of(context).requestFocus(phoneNode);
                              } else if (password.isEmpty) {
                                showCustomSnackBar('password_is_required'.tr);
                                FocusScope.of(context)
                                    .requestFocus(passwordNode);
                              } else if (password.length < 8) {
                                showCustomSnackBar(
                                    'minimum_password_length_is_8'.tr);
                              } else {
                                authController.login(
                                    authController.countryDialCode,
                                    phone,
                                    password);
                              }
                            },
                            radius: 50,
                          ),
                    Row(children: [
                      const Expanded(
                          child: Divider(
                        thickness: 1,
                        color: Color.fromRGBO(20, 20, 20, 0.1),
                      )),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: 8),
                        child: Text('or'.tr,
                            style: textBold.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge,
                              color: const Color.fromRGBO(255, 0, 0, 0.7),
                            )),
                      ),
                      const Expanded(
                          child: Divider(
                        thickness: 1,
                        color: Color.fromRGBO(20, 20, 20, 0.1),
                      )),
                    ]),
                    ButtonWidget(
                      imageIcon: Images.tablerMessage,
                      boldText: false,
                      textColor: const Color.fromRGBO(88, 89, 89, 1),
                      borderColor: const Color.fromRGBO(20, 20, 20, 0.2),
                      showBorder: true,
                      borderWidth: 1,
                      transparent: true,
                      buttonText: 'otp_login'.tr,
                      onPressed: () =>
                          Get.to(() => const OtpLoginScreen(fromSignIn: true)),
                      radius: 50,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    // ButtonWidget(
                    //   imageIcon: Images.tablerMessage,
                    //   boldText: false,
                    //   textColor: const Color.fromRGBO(88, 89, 89, 1),
                    //   borderColor: const Color.fromRGBO(20, 20, 20, 0.2),
                    //   showBorder: true,
                    //   borderWidth: 1,
                    //   transparent: true,
                    //   buttonText: 'Continue With Google',
                    //   onPressed: () async {
                    //     // UserCredential? result =
                    //     //     await GoogleAuthService().signInWithGoogle();
                    //     //
                    //     // if (result != null) {
                    //     //   User? user = result.user;
                    //     //
                    //     //   String email = user?.email ?? '';
                    //     //   String name = user?.displayName ?? '';
                    //     //   String phone = user?.phoneNumber ?? '';
                    //     //   String uid = user?.uid ?? '';
                    //     //
                    //     //   print('EMAIL ==> $email');
                    //     //   print('NAME ==> $name');
                    //     //   print('PHONE ==> $phone');
                    //     //
                    //     //   /// CALL EXISTING BACKEND LOGIN API HERE
                    //     //
                    //     //   /// EXISTING USER
                    //     //   if (phone.isNotEmpty) {
                    //     //     Get.offAll(() => const DashboardScreen());
                    //     //   }
                    //     //
                    //     //   /// NEW USER
                    //     //   else {
                    //     //     Get.to(() => const OtpLoginScreen());
                    //     //   }
                    //     // }
                    //   },
                    //   radius: 50,
                    // ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${'do_not_have_an_account'.tr} ',
                          style: textMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: const Color.fromRGBO(20, 20, 20, 0.7),
                              letterSpacing: 0),
                        ),
                        SizedBox(
                          width: Dimensions.fontSizeEight,
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => const SignUpScreen());
                          },
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                          child: Text('sign_up'.tr,
                              style: textMedium.copyWith(
                                color: const Color.fromRGBO(255, 0, 0, 0.7),
                                fontSize: Dimensions.fontSizeLarge,
                              )),
                        )
                      ],
                    ),
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
