import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/home/widgets/voice_search_dialog.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';

class HomeSearchWidget extends StatelessWidget {
  const HomeSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: const Color.fromRGBO(250, 173, 2, 1),
      autofocus: false,
      readOnly: true,
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeExtraSmall,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromRGBO(250, 173, 2, 1),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromRGBO(250, 173, 2, 1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromRGBO(250, 173, 2, 1),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromRGBO(250, 173, 2, 1),
          ),
        ),
        isDense: true,
        hintText: 'where_to_go'.tr,
        hintStyle: textMedium.copyWith(
          color: const Color.fromRGBO(20, 20, 20, 1),
        ),
        suffixIcon: IconButton(
          color: Theme.of(context).hintColor,
          onPressed: () {
            Get.dialog(const VoiceSearchDialog(), barrierDismissible: false);
          },
          icon: Image.asset(
            Images.microPhoneIcon,
            color: Get.isDarkMode ? Theme.of(context).hintColor : null,
            height: 20,
            width: 20,
          ),
        ),
        prefixIcon: IconButton(
          onPressed: () => Get.to(() => const SetDestinationScreen()),
          icon: Image.asset(
            Images.homeSearchIcon,
            color: Get.isDarkMode ? Theme.of(context).hintColor : null,
            height: 15,
            width: 15,
          ),
        ),
      ),
      onTap: () => Get.to(() => const SetDestinationScreen()),
    );
  }
}
