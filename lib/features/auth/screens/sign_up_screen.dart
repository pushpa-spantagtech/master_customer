import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/settings/screens/policy_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/domain/models/sign_up_body.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode fNameNode = FocusNode();
  FocusNode lNameNode = FocusNode();
  FocusNode phoneNode = FocusNode();
  FocusNode confirmPasswordNode = FocusNode();
  FocusNode passwordNode = FocusNode();

  bool isTermsAccepted = false;
  bool hasOpenedTerms = false;

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        authController.resetTermsAndConditions();
      }
    });

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Image.asset(Images.logoWithName, height: 75)),
                    const SizedBox(height: Dimensions.paddingSizeThree),
                    Text(
                      'sign_up'.tr,
                      style: textBold.copyWith(
                        color: const Color.fromRGBO(255, 0, 0, 0.7),
                        fontSize: Dimensions.paddingSizeThirty,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeSmall),
                      child: Text(
                        'sign_up_message'.tr,
                        style: textMedium.copyWith(
                          color: const Color.fromRGBO(20, 20, 20, 0.6),
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ),
                    CustomTextField(
                      label: 'first_name'.tr,
                      capitalization: TextCapitalization.words,
                      hintText: 'first_name'.tr,
                      inputType: TextInputType.name,
                      prefixIcon: Images.profileIcon,
                      controller: fNameController,
                      focusNode: fNameNode,
                      nextFocus: lNameNode,
                      inputAction: TextInputAction.next,
                    ),
                    CustomTextField(
                      label: 'last_name'.tr,
                      capitalization: TextCapitalization.words,
                      hintText: 'last_name'.tr,
                      inputType: TextInputType.name,
                      prefixIcon: Images.profileIcon,
                      controller: lNameController,
                      focusNode: lNameNode,
                      nextFocus: phoneNode,
                      inputAction: TextInputAction.next,
                    ),
                    CustomTextField(
                      label: 'phone'.tr,
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
                    CustomTextField(
                      label: 'password'.tr,
                      hintText: 'enter_password'.tr,
                      inputType: TextInputType.text,
                      prefixIcon: Images.lock,
                      isPassword: true,
                      controller: passwordController,
                      focusNode: passwordNode,
                      nextFocus: confirmPasswordNode,
                      inputAction: TextInputAction.next,
                    ),
                    CustomTextField(
                      label: 'confirm_password'.tr,
                      hintText: 'enter_confirm_password'.tr,
                      inputType: TextInputType.text,
                      prefixIcon: Images.lock,
                      controller: confirmPasswordController,
                      focusNode: confirmPasswordNode,
                      inputAction: TextInputAction.done,
                      isPassword: true,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeEight,
                        vertical: Dimensions.paddingSizeTwo,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Transform.scale(
                              scale: 1,
                              child: Checkbox(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                checkColor:
                                    const Color.fromRGBO(255, 255, 255, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                side: BorderSide(
                                  color: Theme.of(context).hintColor,
                                ),
                                activeColor:
                                    const Color.fromRGBO(250, 173, 2, 1),
                                value: authController.isTermsAccepted,
                                onChanged: (value) {
                                  authController
                                      .toggleTermsAccepted(value ?? false);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Text(
                            '${'i_agree'.tr} ',
                            style: textMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: const Color.fromRGBO(20, 20, 20, 0.7),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await Get.to(() => const PolicyScreen());
                              authController.markTermsAsOpened();
                            },
                            child: Text(
                              'terms_and_conditions'.tr,
                              style: textMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: const Color.fromRGBO(250, 173, 2, 1),
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    authController.isLoading
                        ? const Center(
                            child: SpinKitCircle(
                                color: Color.fromRGBO(250, 173, 2, 1),
                                size: 40.0))
                        : ButtonWidget(
                            buttonText: 'register'.tr,
                            textColor: const Color.fromRGBO(255, 255, 255, 1),
                            borderColor:
                                const Color.fromRGBO(255, 128, 128, 0.2),
                            backgroundColor:
                                const Color.fromRGBO(250, 173, 2, 1),
                            fontSize: 18.0,
                            radius: 28,
                            onPressed: () {
                              String fName = fNameController.text.trim();
                              String lName = lNameController.text.trim();
                              String phone = phoneController.text.trim();
                              String password = passwordController.text.trim();
                              String confirmPassword =
                                  confirmPasswordController.text.trim();

                              if (fName.isEmpty) {
                                showCustomSnackBar('first_name_is_required'.tr);
                                FocusScope.of(context).requestFocus(fNameNode);
                              } else if (lName.isEmpty) {
                                showCustomSnackBar('last_name_is_required'.tr);
                                FocusScope.of(context).requestFocus(lNameNode);
                              } else if (phone.isEmpty) {
                                showCustomSnackBar(
                                    'Please enter your mobile number'.tr);
                                FocusScope.of(context).requestFocus(phoneNode);
                              } else if (phone.length != 10) {
                                showCustomSnackBar(
                                    'Please enter a valid 10-digit mobile number.');
                                FocusScope.of(context).requestFocus(phoneNode);
                              } else if (!GetUtils.isPhoneNumber(
                                  authController.countryDialCode + phone)) {
                                showCustomSnackBar(
                                    'Please enter a valid mobile number.');
                                FocusScope.of(context).requestFocus(phoneNode);
                              } else if (password.isEmpty) {
                                showCustomSnackBar('password_is_required'.tr);
                                FocusScope.of(context)
                                    .requestFocus(passwordNode);
                              } else if (password.length < 8) {
                                showCustomSnackBar(
                                    'minimum_password_length_is_8'.tr);
                                FocusScope.of(context)
                                    .requestFocus(passwordNode);
                              } else if (confirmPassword.isEmpty) {
                                showCustomSnackBar(
                                    'confirm_password_is_required'.tr);
                                FocusScope.of(context)
                                    .requestFocus(confirmPasswordNode);
                              } else if (password != confirmPassword) {
                                showCustomSnackBar('password_is_mismatch'.tr);
                                FocusScope.of(context)
                                    .requestFocus(confirmPasswordNode);
                              } else if (!authController.isTermsAccepted) {
                                showCustomSnackBar(
                                  'Please read and accept the Terms & Conditions before registering.',
                                );
                                return;
                              } else {
                                authController.register(SignUpBody(
                                    fName: fName,
                                    lName: lName,
                                    phone:
                                        authController.countryDialCode + phone,
                                    password: password,
                                    confirmPassword: confirmPassword,
                                    userType: AppConstants.customerType));
                              }
                            },
                          ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        '${'already_have_an_account_?'.tr} ',
                        style: textMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: const Color.fromRGBO(20, 20, 20, 0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.find<AuthController>().resetTermsAndConditions();
                          Get.back();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          overlayColor: Colors.transparent,
                        ),
                        child: Text('login'.tr,
                            style: textMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: const Color.fromRGBO(255, 0, 0, 0.7),
                            )),
                      ),
                    ]),
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
