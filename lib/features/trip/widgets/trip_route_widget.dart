import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/divider_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

class TripRouteWidget extends StatelessWidget {
  final String pickupAddress;
  final String destinationAddress;
  final String? extraOne;
  final String? extraTwo;
  final String? entrance;
  final bool fromCard;

  const TripRouteWidget(
      {super.key,
      required this.pickupAddress,
      required this.destinationAddress,
      this.extraOne,
      this.extraTwo,
      this.entrance,
      this.fromCard = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (riderController) {
      return Row(
        children: [
          Column(
            children: [
              SizedBox(
                  width: Dimensions.iconSizeMedium,
                  child: Image.asset(
                    Images.currentLocation,
                    color: const Color.fromRGBO(250, 173, 2, 1),
                  )),
              if ((extraOne != null && extraOne!.isNotEmpty) ||
                  (extraTwo != null && extraTwo!.isNotEmpty))
                const SizedBox(
                    height: 45,
                    width: 10,
                    child: CustomDivider(
                      height: 2,
                      dashWidth: 1,
                      axis: Axis.vertical,
                      color: Color.fromRGBO(68, 68, 68, 0.27),
                    )),
              if ((extraOne != null && extraOne!.isNotEmpty) ||
                  (extraTwo != null && extraTwo!.isNotEmpty))
                SizedBox(
                    width: Dimensions.iconSizeMedium,
                    child: Image.asset(Images.customerRouteIcon)),
              const SizedBox(
                  height: 35,
                  width: 10,
                  child: CustomDivider(
                    color: Color.fromRGBO(68, 68, 68, 0.27),
                    height: 2,
                    dashWidth: 1,
                    axis: Axis.vertical,
                  )),
              SizedBox(
                  width: Dimensions.iconSizeMedium,
                  child: Image.asset(
                    Images.customerDestinationIcon,
                    color: const Color.fromRGBO(250, 173, 2, 1),
                  )),
            ],
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pickupAddress,
                style: textRegular.copyWith(),
                overflow: TextOverflow.ellipsis,
              ),
              // const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              if (extraOne != null && extraOne!.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeSmall),
                    child: Text(extraOne!,
                        overflow: TextOverflow.ellipsis,
                        style: textRegular.copyWith(
                            color: Theme.of(Get.context!)
                                .primaryColor
                                .withValues(alpha: .75),
                            fontSize: Dimensions.fontSizeSmall))),
              if ((extraOne != null && extraOne!.isNotEmpty) ||
                  (extraTwo != null && extraTwo!.isNotEmpty))
                const Padding(
                  padding:
                      EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                  child: SizedBox(
                      height: 20,
                      width: 10,
                      child: CustomDivider(
                        height: 2,
                        dashWidth: 1,
                        axis: Axis.vertical,
                        color: Color.fromRGBO(68, 68, 68, 0.27),
                      )),
                ),
              if (extraTwo != null && extraOne!.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeSmall),
                    child: Text(extraTwo!,
                        overflow: TextOverflow.ellipsis,
                        style: textRegular.copyWith(
                            color: Theme.of(Get.context!)
                                .primaryColor
                                .withValues(alpha: .75),
                            fontSize: Dimensions.fontSizeSmall))),
              if (extraOne != null || extraTwo != null)
                const SizedBox(height: Dimensions.paddingSizeSmall),
              Padding(
                padding: EdgeInsets.only(
                    top: fromCard
                        ? Dimensions.paddingSizeSmall
                        : Dimensions.paddingSizeLarge),
                child: Text(
                  destinationAddress,
                  style: textRegular.copyWith(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              entrance != null && entrance!.isNotEmpty
                  ? Divider(
                      color: Theme.of(context).hintColor,
                    )
                  : const SizedBox.shrink(),
              entrance != null && entrance!.isNotEmpty
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                            height: 25, child: Image.asset(Images.curvedArrow)),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Container(
                            transform: Matrix4.translationValues(0, 10, 0),
                            child: Text(entrance!,
                                style: textMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault)))
                      ],
                    )
                  : const SizedBox.shrink()
            ],
          )),
        ],
      );
    });
  }
}
