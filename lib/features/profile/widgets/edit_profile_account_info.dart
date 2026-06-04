import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';

class EditProfileAccountInfo extends StatefulWidget {
  final bool fromAccount;

  const EditProfileAccountInfo({
    super.key,
    this.fromAccount = false,
  });

  @override
  State<EditProfileAccountInfo> createState() => _EditProfileAccountInfoState();
}

class _EditProfileAccountInfoState extends State<EditProfileAccountInfo> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = Get.find<ProfileController>().profileModel!.data!;
    firstNameController.text = profile.firstName ?? '';
    lastNameController.text = profile.lastName ?? '';
    phoneController.text = profile.phone ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      return SingleChildScrollView(
        child: Column(children: [
          CustomTextField(
            label: 'first_name'.tr,
            prefixIcon: Images.editProfileName,
            borderRadius: 10,
            capitalization: TextCapitalization.words,
            showBorder: true,
            controller: firstNameController,
            hintText: 'enter_first_name'.tr,
          ),
          const SizedBox(
            height: Dimensions.paddingSizeSixteen,
          ),
          CustomTextField(
            label: 'last_name'.tr,
            prefixIcon: Images.editProfileName,
            borderRadius: 10,
            capitalization: TextCapitalization.words,
            showBorder: false,
            controller: lastNameController,
            hintText: 'enter_last_name'.tr,
          ),
          const SizedBox(
            height: Dimensions.paddingSizeSixteen,
          ),
          CustomTextField(
            isEnabled: false,
            label: 'phone'.tr,
            prefixIcon: Images.editProfilePhone,
            borderRadius: 10,
            controller: phoneController,
            showBorder: false,
            hintText: 'enter_your_phone'.tr,
            fillColor: Theme.of(context).hintColor.withValues(alpha: .15),
          ),
          const SizedBox(
            height: Dimensions.paddingSizeSixteen,
          ),
          profileController.isUpdating
              ? const Center(
                  child: SpinKitCircle(
                      color: Color.fromRGBO(250, 173, 2, 1), size: 40.0))
              : ButtonWidget(
                  buttonText: "update_profile".tr,
                  textColor: const Color.fromRGBO(255, 255, 255, 1),
                  borderColor: const Color.fromRGBO(255, 128, 128, 0.2),
                  backgroundColor: const Color.fromRGBO(250, 173, 2, 1),
                  onPressed: () async {
                    Response response = await profileController.updateProfile(
                        firstNameController.text.trim(),
                        lastNameController.text.trim());
                    if (response.statusCode == 200) {
                      showCustomSnackBar('profile_updated_successfully'.tr,
                          isError: false);
                      if (widget.fromAccount) {
                        Get.offAll(() => const AccessLocationScreen());
                      }
                    }
                  }),
        ]),
      );
    });
  }
}
