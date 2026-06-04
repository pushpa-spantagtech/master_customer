import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/notification/domain/models/notification_model.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class NotificationCard extends StatelessWidget {
  final Notifications notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.bottomSheet(Container(
          width: Get.width,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 1),
            border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.1)),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimensions.paddingSizeLarge),
              topRight: Radius.circular(Dimensions.paddingSizeLarge),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSize),
                margin:
                    const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.1)),
                  color: Get.isDarkMode
                      ? Theme.of(context).scaffoldBackgroundColor
                      : const Color.fromRGBO(255, 239, 203, 1),
                  borderRadius:
                      BorderRadius.circular(Dimensions.paddingSizeSmall),
                ),
                child: Image.asset(
                  Images.notificationCarIcon,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  color: const Color.fromRGBO(250, 173, 2, 1),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(notification.title ?? '', style: textBold),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                notification.description ?? '',
                style: textRegular.copyWith(
                    color: const Color.fromRGBO(20, 20, 20, 0.6)),
              ),
              const SizedBox(height: 30),
            ]),
          ),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Get.isDarkMode
              ? Theme.of(context).scaffoldBackgroundColor
              : const Color.fromRGBO(255, 255, 255, 1),
          border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.1)),
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimensions.radiusLarge)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeLarge,
        ),
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSize),
            margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Get.isDarkMode
                  ? Theme.of(context).scaffoldBackgroundColor
                  : const Color.fromRGBO(255, 239, 203, 1),
              border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.1)),
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
            ),
            child: Image.asset(
              Images.notificationCarIcon,
              width: 20,
              height: 20,
              fit: BoxFit.cover,
              color: const Color.fromRGBO(250, 173, 2, 1),
            ),
          ),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(
                      right: Dimensions.paddingSizeExtraLarge),
                  child: Text(
                    notification.title ?? '',
                    style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeExtraSmall),
                  child: Row(children: [
                    Text(
                      DateConverter.isoStringToLocalDateAndMonthOnly(
                          notification.createdAt!),
                      style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Icon(
                      Icons.alarm,
                      size: Dimensions.fontSizeLarge,
                      color: const Color.fromRGBO(250, 173, 2, 1),
                    ),
                  ]),
                ),
              ]),
              Text(notification.description ?? '',
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
      ),
    );
  }
}
