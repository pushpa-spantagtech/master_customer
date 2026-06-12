import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/address/screens/my_address.dart';
import 'package:ride_sharing_user_app/features/message/screens/message_list.dart';
import 'package:ride_sharing_user_app/features/my_level/screens/my_level_screen.dart';
import 'package:ride_sharing_user_app/features/my_offer/screens/my_offer_screen.dart';
import 'package:ride_sharing_user_app/features/profile/widgets/profile_item.dart';
import 'package:ride_sharing_user_app/features/settings/screens/setting_screen.dart';
import 'package:ride_sharing_user_app/features/support/support_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/settings/screens/policy_screen.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/edit_profile_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/confirmation_dialog_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: GetBuilder<ProfileController>(builder: (profileController) {
        return BodyWidget(
          appBar: AppBarWidget(
            title: 'profile'.tr,
            showBackButton: false,
            fontSize: 18,
            toolbarHeight: 65,
            backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 100,
                    width: Get.width,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusExtraLarge),
                      border: Border.all(
                          color: const Color.fromRGBO(255, 255, 255, 0.2)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                      color: const Color.fromRGBO(255, 255, 255, 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color.fromRGBO(255, 0, 0, 0.13),
                                width: 3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: ImageWidget(
                              height: 80,
                              width: 80,
                              image: profileController
                                          .profileModel?.data?.profileImage !=
                                      null
                                  ? '${Get.find<ConfigController>().config!.imageBaseUrl!.profileImage}/'
                                      '${profileController.profileModel?.data?.profileImage ?? ''}'
                                  : '',
                              placeholder: Images.personPlaceholder,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSixteen),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                profileController.customerName(),
                                style: textBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    profileController
                                            .profileModel!.data!.userRating ??
                                        "0",
                                    style: textBold.copyWith(
                                        fontSize:
                                            Dimensions.fontSizeExtraSmall),
                                  ),
                                  _buildRideCount(
                                    'ride',
                                    '${profileController.profileModel?.data?.totalRideCount ?? 0}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 16,
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => const EditProfileScreen()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 216, 216, 1),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.edit,
                            size: 12,
                            color: Color.fromRGBO(255, 0, 0, 0.7),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            'Edit profile',
                            style: textSemiBold.copyWith(
                                fontSize: 12,
                                color: const Color.fromRGBO(255, 0, 0, 0.7)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // ProfileMenuItem(
              //   title: 'profile',
              //   icon: Images.profileIcon,
              //   onTap: () => Get.to(() => const EditProfileScreen()),
              // ),
              ProfileMenuItem(
                title: 'my_address',
                icon: Images.location,
                onTap: () => Get.to(() => const MyAddressScreen()),
              ),
              ProfileMenuItem(
                title: 'message',
                icon: Images.profileMessage,
                onTap: () => Get.to(() => const MessageListScreen()),
              ),
              // ProfileMenuItem(
              //   title: 'my_wallet',
              //   icon: Images.profileMyWallet,
              //   onTap: () => Get.to(() => const WalletScreen()),
              // ),
              ProfileMenuItem(
                title: 'my_offer',
                icon: Images.paymentAndVoucher,
                onTap: () => Get.to(() => MyOfferWidget()),
              ),
              ProfileMenuItem(
                title: 'my_trips',
                icon: Images.profileMyTrip,
                onTap: () => Get.to(() => const TripScreen(fromProfile: true)),
              ),
              if (Get.find<ConfigController>().config?.levelStatus ?? false)
                ProfileMenuItem(
                  title: 'my_level',
                  icon: Images.myLevelIcon,
                  onTap: () => Get.to(() => const MyLevelScreen()),
                ),
              ProfileMenuItem(
                title: 'help_support',
                icon: Images.profileHelpSupport,
                onTap: () => Get.to(() => const HelpAndSupportScreen()),
              ),
              ProfileMenuItem(
                title: 'settings',
                icon: Images.profileSetting,
                onTap: () => Get.to(() => const SettingScreen()),
              ),
              ProfileMenuItem(
                title: 'terms_and_condition',
                icon: Images.termsAndCondition,
                onTap: () => Get.to(() => PolicyScreen(
                      image: Get.find<ConfigController>()
                              .config
                              ?.termsAndConditions
                              ?.image ??
                          '',
                    )),
              ),
              ProfileMenuItem(
                title: 'logout',
                icon: Images.profileLogout,
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return GetBuilder<AuthController>(
                            builder: (authController) {
                          return ConfirmationDialogWidget(
                            icon: Images.profileLogout,
                            isLoading: authController.isLoading,
                            description:
                                'do_you_want_to_log_out_this_account'.tr,
                            onYesPressed: () {
                              Get.find<AuthController>().logOut();
                            },
                          );
                        });
                      });
                },
              ),
              ProfileMenuItem(
                title: 'permanently_delete_account'.tr,
                icon: Images.deleteAccountIcon,
                divider: false,
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return GetBuilder<AuthController>(
                            builder: (authController) {
                          return ConfirmationDialogWidget(
                            icon: Images.profileLogout,
                            isLoading: authController.isLoading,
                            description: 'are_you_sure_permanent_delete_smg'.tr,
                            onYesPressed: () {
                              Get.find<AuthController>().permanentlyDelete();
                            },
                          );
                        });
                      });
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge * 4),
            ]),
          ),
        );
      }),
    );
  }

  Row _buildRideCount(String title, String value) {
    return Row(
      children: [
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        Text(
          '($value  ${title.tr})',
          style: textSemiBold.copyWith(
            color: const Color.fromRGBO(20, 20, 20, 0.7),
            fontSize: Dimensions.fontSizeEight,
          ),
        ),
      ],
    );
  }
}
