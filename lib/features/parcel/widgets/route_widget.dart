import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/divider_widget.dart';

class RouteWidget extends StatefulWidget {
  final String totalDistance;
  final String fromAddress;
  final String toAddress;
  final String extraOneAddress;
  final String extraTwoAddress;
  final String entrance;
  final bool fromParcelOngoing;

  const RouteWidget({
    super.key,
    required this.totalDistance,
    required this.fromAddress,
    required this.toAddress,
    required this.extraOneAddress,
    required this.extraTwoAddress,
    required this.entrance,
    this.fromParcelOngoing = false,
  });

  @override
  State<RouteWidget> createState() => _RouteWidgetState();
}

class _RouteWidgetState extends State<RouteWidget> {
  String totalDistance = '0', estDistance = '0', removeComma = '0';

  @override
  Widget build(BuildContext context) {
    if (widget.totalDistance.contains("km")) {
      removeComma = widget.totalDistance.replaceAll("km", '');
      totalDistance = removeComma.replaceAll(",", '');
    }
    estDistance = double.parse(totalDistance).toStringAsFixed(2);

    return GetBuilder<ParcelController>(builder: (parcelController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        return Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSix),
                child: Column(children: [
                  SizedBox(
                      width: Dimensions.iconSizeMedium,
                      child: Image.asset(
                        Images.boxIconsLocation,
                        height: 20,
                        width: 20,
                      )),
                  const SizedBox(
                      height: 30,
                      width: 15,
                      child: CustomDivider(
                          height: 2,
                          dashWidth: 1,
                          axis: Axis.vertical,
                          color: Colors.transparent)),
                  SizedBox(
                      width: Dimensions.iconSizeMedium,
                      child: Image.asset(
                        Images.tablerLocation,
                        height: 20,
                        width: 20,
                      ))
                ])),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    height: 40,
                    child: Text(
                      widget.fromAddress,
                      style: textMedium.copyWith(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    )),
                SizedBox(
                    height: widget.extraOneAddress.isNotEmpty
                        ? Dimensions.paddingSizeSmall
                        : 0),
                widget.extraOneAddress.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: Dimensions.paddingSizeSmall),
                        child: Text(
                          widget.extraOneAddress,
                          style: textMedium.copyWith(
                              color: Theme.of(Get.context!)
                                  .primaryColor
                                  .withValues(alpha: .75),
                              fontSize: Dimensions.fontSizeSmall),
                          overflow: TextOverflow.ellipsis,
                        ))
                    : const SizedBox(),
                widget.extraOneAddress.isNotEmpty &&
                        widget.extraTwoAddress.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: Dimensions.paddingSizeExtraSmall),
                        child: SizedBox(
                            height: 20,
                            width: 10,
                            child: CustomDivider(
                              height: 2,
                              dashWidth: 1,
                              axis: Axis.vertical,
                              color:
                                  Get.isDarkMode ? Colors.white : Colors.black,
                            )))
                    : const SizedBox(),
                widget.extraTwoAddress.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: Dimensions.paddingSizeSmall),
                        child: Text(
                          widget.extraTwoAddress,
                          style: textMedium.copyWith(
                              color: Theme.of(Get.context!)
                                  .primaryColor
                                  .withValues(alpha: .75),
                              fontSize: Dimensions.fontSizeSmall),
                          overflow: TextOverflow.ellipsis,
                        ))
                    : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text(
                  widget.toAddress,
                  overflow: TextOverflow.ellipsis,
                  style: textMedium.copyWith(),
                  maxLines: 2,
                ),
                if (widget.entrance.isNotEmpty)
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    SizedBox(
                        height: 25,
                        child: Image.asset(Images.curvedArrow,
                            color: const Color.fromRGBO(250, 173, 2, 1))),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Container(
                        transform: Matrix4.translationValues(0, 10, 0),
                        child: Text(widget.entrance,
                            style: textMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault)))
                  ]),
              ],
            )),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          if (!widget.fromParcelOngoing)
            GetBuilder<RideController>(builder: (rideController) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Image.asset(Images.distanceCalculated,
                      width: 20, color: const Color.fromRGBO(250, 173, 2, 1)),
                  const SizedBox(
                    width: 4,
                  ),
                  Text("total_distance".tr, style: textMedium.copyWith()),
                  const Spacer(),
                  Text(
                      widget.totalDistance.contains('km')
                          ? widget.totalDistance
                          : '${double.parse(widget.totalDistance).toStringAsFixed(2)} km',
                      style: textMedium.copyWith()),
                ]),
              );
            }),
        ]);
      });
    });
  }
}
