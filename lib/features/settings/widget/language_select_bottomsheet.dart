import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class LanguageSelectBottomSheet extends StatelessWidget {
  const LanguageSelectBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
        builder: (localizationController) {
      return PopScope(
        onPopInvoked: (val) {
          localizationController.setInitialIndex();
        },
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
            child: Column(children: [
              Image.asset(
                Images.smallIcon,
                height: 10,
                width: 40,
              ),
              const SizedBox(
                height: Dimensions.paddingSizeExtraSmall,
              ),
              Text(
                'select_language'.tr,
                style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(
                height: Dimensions.paddingSizeSmall,
              ),
              Text(
                'choose_your_language_to_processed'.tr,
                style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              ListView.builder(
                itemCount: AppConstants.languages.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      localizationController.setSelectIndex(index);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: localizationController.selectIndex == index
                              ? const Color.fromRGBO(255, 239, 203, 1)
                              : null,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusLarge),
                          border: localizationController.selectIndex == index
                              ? Border.all(
                                  color: const Color.fromRGBO(0, 0, 0, 0.1))
                              : null),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(children: [
                          Image.asset(
                            AppConstants.languages[index].imageUrl,
                            height: 26,
                            width: 26,
                          ),
                          const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall,
                          ),
                          Text(
                            '${AppConstants.languages[index].countryCode} (${AppConstants.languages[index].languageName})',
                            style: textSemiBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault),
                          ),
                        ]),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: Dimensions.paddingSizeDefault,
              ),
              ButtonWidget(
                buttonText: 'update'.tr,
                textColor: const Color.fromRGBO(255, 255, 255, 1),
                borderColor: const Color.fromRGBO(255, 128, 128, 0.2),
                backgroundColor: const Color.fromRGBO(250, 173, 2, 1),
                onPressed: () {
                  localizationController.setLanguage(Locale(
                      AppConstants.languages[localizationController.selectIndex]
                          .languageCode,
                      AppConstants.languages[localizationController.selectIndex]
                          .countryCode));
                  Get.back();
                },
              )
            ]),
          ),
        ),
      );
    });
  }
}
