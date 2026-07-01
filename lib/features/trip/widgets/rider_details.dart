import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/contact_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';

class ActivityScreenRiderDetails extends StatelessWidget {
  const ActivityScreenRiderDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      print("========== DRIVER DETAILS ==========");
      print("Driver Object : ${rideController.tripDetails?.driver}");
      print("Driver ID     : ${rideController.tripDetails?.driver?.id}");
      print("First Name    : ${rideController.tripDetails?.driver?.firstName}");
      print("Last Name     : ${rideController.tripDetails?.driver?.lastName}");
      print(
          "Profile Image : ${rideController.tripDetails?.driver?.profileImage}");
      print("Trip Status   : ${rideController.tripDetails?.currentStatus}");
      print("====================================");
      String ratting = rideController.tripDetails?.driverAvgRating != null
          ? double.parse(rideController.tripDetails!.driverAvgRating!)
              .toStringAsFixed(1)
          : "0";
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
            border: Border.all(
                width: .75, color: const Color.fromRGBO(20, 20, 20, 0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Row(children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: ImageWidget(
                      height: 50,
                      width: 50,
                      image: rideController.tripDetails?.driver != null
                          ? '${Get.find<ConfigController>().config!.imageBaseUrl!.profileImageDriver}'
                              '/${rideController.tripDetails!.driver!.profileImage}'
                          : '')),
              const SizedBox(
                width: Dimensions.paddingSizeSmall,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  rideController.tripDetails?.driver != null
                      ? SizedBox(
                          width: 100,
                          child: Text(
                            '${rideController.tripDetails!.driver!.firstName!} ${rideController.tripDetails!.driver!.lastName!}',
                            style: textMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: const Color.fromRGBO(20, 20, 20, 0.7)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : const SizedBox(),
                  Text.rich(TextSpan(
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .color!
                          .withValues(alpha: 0.8),
                    ),
                    children: [
                      WidgetSpan(
                          child: Icon(
                            Icons.star,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            size: 15,
                          ),
                          alignment: PlaceholderAlignment.middle),
                      TextSpan(
                          text: ratting,
                          style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault)),
                    ],
                  )),
                ],
              ),
              Container(
                  width: 1,
                  height: 25,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.25),
                  margin: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeExtraLarge)),
              ContactWidget(
                driverId: rideController.tripDetails?.driver?.id ?? '0',
              ),
            ]),
          ),
          const Divider(
            height: 1,
            color: Color.fromRGBO(0, 0, 0, 0.1),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: rideController.tripDetails?.vehicle != null
                ? Row(children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rideController.tripDetails!.vehicle != null
                                ? rideController
                                    .tripDetails!.vehicle!.model!.name!
                                : '',
                            style: textBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: const Color.fromRGBO(20, 20, 20, 1)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text.rich(
                              TextSpan(
                                style: textRegular.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color!
                                        .withValues(alpha: 0.8)),
                                children: [
                                  TextSpan(
                                      text: rideController.tripDetails!.vehicle!
                                          .licencePlateNumber,
                                      style: textMedium.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: const Color.fromRGBO(
                                              20, 20, 20, 0.6))),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis),
                        ]),
                    const Spacer(),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusOverLarge,
                          ),
                          child: ImageWidget(
                            image:
                                '${Get.find<ConfigController>().config!.imageBaseUrl!.vehicleModel!}/${rideController.tripDetails!.vehicle!.model!.image!}',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ])
                : const SizedBox(),
          ),
        ]),
      );
    });
  }
}
