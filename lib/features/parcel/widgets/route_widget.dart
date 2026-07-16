import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

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
  String totalDistance = '0';
  String estDistance = '0';
  String removeComma = '0';

  double _safeDistanceValue(String value) {
    final cleanedValue = value
        .replaceAll('km', '')
        .replaceAll('KM', '')
        .replaceAll(',', '')
        .trim();

    if (cleanedValue.isEmpty || cleanedValue.toLowerCase() == 'null') {
      return 0.0;
    }

    return double.tryParse(cleanedValue) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    totalDistance = widget.totalDistance
        .replaceAll('km', '')
        .replaceAll('KM', '')
        .replaceAll(',', '')
        .trim();

    if (totalDistance.isEmpty || totalDistance.toLowerCase() == 'null') {
      totalDistance = '0';
    }

    final parsedDistance = double.tryParse(totalDistance) ?? 0.0;
    estDistance = parsedDistance.toStringAsFixed(2);

    int stopNumber = 1;

    if (widget.extraOneAddress.isNotEmpty) {
      stopNumber++;
    }

    if (widget.extraTwoAddress.isNotEmpty) {
      stopNumber++;
    }

    return GetBuilder<ParcelController>(
      builder: (parcelController) {
        return GetBuilder<LocationController>(
          builder: (locationController) {
            return Column(
              children: [
                Material(
                  color: Theme.of(context).cardColor,
                  elevation: 1,
                  shadowColor: Colors.black.withValues(alpha: 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(
                      color: Color(0xFFD8DEE8),
                      width: 1.2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        _RoutePoint(
                          title: 'Pickup Location',
                          address: widget.fromAddress,
                          type: _RoutePointType.pickup,
                        ),
                        if (widget.extraOneAddress.isNotEmpty) ...[
                          const _RouteConnector(),
                          _RoutePoint(
                            title: 'Stop 1',
                            address: widget.extraOneAddress,
                            type: _RoutePointType.stop,
                            stopNumber: 1,
                          ),
                        ],
                        if (widget.extraTwoAddress.isNotEmpty) ...[
                          const _RouteConnector(),
                          _RoutePoint(
                            title: 'Stop 2',
                            address: widget.extraTwoAddress,
                            type: _RoutePointType.stop,
                            stopNumber: 2,
                          ),
                        ],
                        if (widget.entrance.isNotEmpty)
                          ...List.generate(
                            widget.entrance
                                .split(',')
                                .where((element) => element.trim().isNotEmpty)
                                .length,
                            (index) {
                              final stops = widget.entrance
                                  .split(',')
                                  .where((element) => element.trim().isNotEmpty)
                                  .toList();

                              return Column(
                                children: [
                                  const _RouteConnector(),
                                  _RoutePoint(
                                    title: 'Stop ${stopNumber + index}',
                                    address: stops[index],
                                    type: _RoutePointType.stop,
                                    stopNumber: stopNumber + index,
                                  ),
                                ],
                              );
                            },
                          ),
                        const _RouteConnector(),
                        _RoutePoint(
                          title: 'Destination',
                          address: widget.toAddress,
                          type: _RoutePointType.destination,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!widget.fromParcelOngoing) ...[
                  const SizedBox(height: 12),
                  GetBuilder<RideController>(
                    builder: (rideController) {
                      final displayDistance =
                          _safeDistanceValue(widget.totalDistance);

                      return Material(
                        color: Theme.of(context).cardColor,
                        elevation: 1,
                        shadowColor: Colors.black.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: Color(0xFFD8DEE8),
                            width: 1.2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF4D6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.route_rounded,
                                  size: 18,
                                  color: Color(0xFFFFB100),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'total_distance'.tr,
                                  style: textMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                '${displayDistance.toStringAsFixed(2)} km',
                                style: textBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

enum _RoutePointType {
  pickup,
  stop,
  destination,
}

class _RoutePoint extends StatelessWidget {
  final String title;
  final String address;
  final _RoutePointType type;
  final int? stopNumber;

  const _RoutePoint({
    required this.title,
    required this.address,
    required this.type,
    this.stopNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _RouteIcon(
              type: type,
              stopNumber: stopNumber,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textMedium.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.48),
                  fontSize: Dimensions.fontSizeExtraSmall,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                address,
                style: textMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: Dimensions.fontSizeSmall,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteIcon extends StatelessWidget {
  final _RoutePointType type;
  final int? stopNumber;

  const _RouteIcon({
    required this.type,
    this.stopNumber,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case _RoutePointType.pickup:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF4D6),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFB100),
                width: 1.7,
              ),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 3.5,
              height: 3.5,
              decoration: const BoxDecoration(
                color: Color(0xFFFFB100),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );

      case _RoutePointType.destination:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFFFE9EC),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.location_on_rounded,
            size: 14,
            color: Color(0xFFFF4D5A),
          ),
        );

      case _RoutePointType.stop:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF4D6),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${stopNumber ?? ''}',
            style: textBold.copyWith(
              color: const Color(0xFFFFB100),
              fontSize: 9,
            ),
          ),
        );
    }
  }
}

class _RouteConnector extends StatelessWidget {
  const _RouteConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 9.5),
      child: SizedBox(
        height: 14,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            4,
            (index) => Container(
              width: 1.5,
              height: 2,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
