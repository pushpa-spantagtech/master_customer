import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';

class EstimatedFareAndDistance extends StatelessWidget {
  final bool fromPickLocation;
  final bool isParcel;

  const EstimatedFareAndDistance({
    super.key,
    this.fromPickLocation = false,
    this.isParcel = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      final colorScheme = Theme.of(context).colorScheme;

      final String distanceText = rideController.remainingDistanceModel !=
                  null &&
              rideController.remainingDistanceModel!.isNotEmpty
          ? rideController.remainingDistanceModel![0].distanceText ?? '0.00 km'
          : '${double.tryParse(rideController.estimatedDistance.toString())?.toStringAsFixed(2) ?? '0.00'} km';

      final double fare = fromPickLocation
          ? rideController.estimatedFare
          : rideController.tripDetails?.paymentStatus == 'paid'
              ? rideController.tripDetails?.paidFare ?? 0
              : rideController.tripDetails?.actualFare ?? 0;

      return Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  icon: Icons.route_rounded,
                  value: distanceText,
                  label: 'distance_away'.tr,
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.outlineVariant,
              ),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.payments_outlined,
                  value: PriceConverter.convertPrice(fare),
                  label: 'fare_price'.tr,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFB300),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 19,
              color: const Color(0xFFFF9800),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
