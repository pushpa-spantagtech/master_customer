import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

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

    int stopNumber = 1;

    if (widget.extraOneAddress.isNotEmpty) {
      stopNumber++;
    }

    if (widget.extraTwoAddress.isNotEmpty) {
      stopNumber++;
    }

    return GetBuilder<ParcelController>(builder: (parcelController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSix),
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Padding(
              //     padding: const EdgeInsets.symmetric(
              //         horizontal: Dimensions.paddingSizeSix),
              //     child: Column(children: [
              // SizedBox(
              //     width: Dimensions.iconSizeMedium,
              //     child: Image.asset(
              //       Images.boxIconsLocation,
              //       height: 20,
              //       width: 20,
              //     )),
              // const SizedBox(
              //     height: 30,
              //     width: 15,
              //     child: CustomDivider(
              //         height: 2,
              //         dashWidth: 1,
              //         axis: Axis.vertical,
              //         color: Colors.transparent)),
              // SizedBox(
              //     width: Dimensions.iconSizeMedium,
              //     child: Image.asset(
              //       Images.tablerLocation,
              //       height: 20,
              //       width: 20,
              //     ))
              // ])),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: Dimensions.iconSizeMedium,
                            child: Image.asset(
                              Images.boxIconsLocation,
                              height: 20,
                              width: 20,
                            )),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pickup",
                                style: textMedium.copyWith(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.fromAddress,
                                style: textMedium.copyWith(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// EXTRA ROUTE 1 (If using existing feature)
                    if (widget.extraOneAddress.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFB300),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  "1",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Stop 1",
                                    style: textMedium.copyWith(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.extraOneAddress,
                                    style: textMedium.copyWith(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    /// EXTRA ROUTE 2
                    if (widget.extraTwoAddress.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFB300),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  "2",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Stop 2",
                                    style: textMedium.copyWith(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.extraTwoAddress,
                                    style: textMedium.copyWith(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    /// ENTRANCE STOPS
                    if (widget.entrance.isNotEmpty)
                      ...List.generate(
                        widget.entrance
                            .split(',')
                            .where((e) => e.trim().isNotEmpty)
                            .length,
                        (index) {
                          final stops = widget.entrance
                              .split(',')
                              .where((e) => e.trim().isNotEmpty)
                              .toList();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFB300),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${stopNumber + index}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Stop ${stopNumber + index}",
                                        style: textMedium.copyWith(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        stops[index],
                                        style: textMedium.copyWith(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 4),

                    /// DROP
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: Dimensions.iconSizeMedium,
                            child: Image.asset(
                              Images.tablerLocation,
                              height: 20,
                              width: 20,
                            )),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Drop",
                                style: textMedium.copyWith(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.toAddress,
                                style: textMedium.copyWith(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
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
          ]),
        );
      });
    });
  }
}
