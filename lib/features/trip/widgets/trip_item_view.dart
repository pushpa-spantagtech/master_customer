import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/payment/screens/review_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripItemView extends StatelessWidget {
  final TripDetails tripDetails;
  final bool isDetailsScreen;

  const TripItemView({
    super.key,
    required this.tripDetails,
    this.isDetailsScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Material(
        color: Theme.of(context).cardColor,
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(
            color: Color(0xFFF1F2F5),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _handleTripTap(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _VehicleSection(tripDetails: tripDetails),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TripRoute(
                        pickupAddress: tripDetails.pickupAddress ?? '',
                        destinationAddress:
                            tripDetails.destinationAddress ?? '',
                      ),
                      const SizedBox(height: 12),
                      _DateRow(createdAt: tripDetails.createdAt),
                      const SizedBox(height: 12),
                      _BottomSection(
                        tripDetails: tripDetails,
                        isDetailsScreen: isDetailsScreen,
                        displayFare: _displayFare(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTripTap() {
    final String status = tripDetails.currentStatus ?? '';

    if (status == 'accepted' || status == 'ongoing' || status == 'pending') {
      if (tripDetails.type == 'parcel') {
        Get.find<RideController>()
            .getRideDetails(tripDetails.id!)
            .then((value) {
          if (status == 'accepted') {
            Get.find<ParcelController>()
                .updateParcelState(ParcelDeliveryState.otpSent);
            Get.to(() => const MapScreen(fromScreen: MapScreenType.parcel));
          } else if (status == 'ongoing') {
            Get.find<ParcelController>()
                .updateParcelState(ParcelDeliveryState.parcelOngoing);

            if (value.body['data']['parcel_information']['payer'] == 'sender' &&
                value.body['data']['payment_status'] == 'unpaid') {
              Get.off(() => const PaymentScreen(fromParcel: true));
            } else {
              Get.to(() => const MapScreen(fromScreen: MapScreenType.parcel));
            }
          } else {
            Get.find<ParcelController>()
                .updateParcelState(ParcelDeliveryState.findingRider);
            Get.to(() => const MapScreen(fromScreen: MapScreenType.parcel));
          }
        });
      } else {
        Get.find<RideController>().getRideDetails(tripDetails.id!);

        if (status == 'accepted') {
          Get.find<RideController>()
              .updateRideCurrentState(RideState.acceptingRider);
        } else if (status == 'ongoing') {
          Get.find<RideController>()
              .updateRideCurrentState(RideState.ongoingRide);
        } else {
          Get.find<RideController>()
              .updateRideCurrentState(RideState.findingRider);
        }

        Get.to(() => const MapScreen(fromScreen: MapScreenType.ride));
      }
    } else {
      if (status == 'completed' && tripDetails.paymentStatus == 'unpaid') {
        Get.find<RideController>().getFinalFare(tripDetails.id!).then((value) {
          Get.to(
            () => PaymentScreen(fromParcel: tripDetails.type == 'parcel'),
          );
        });
      } else {
        Get.to(() => TripDetailsScreen(tripId: tripDetails.id!));
      }
    }
  }

  double _displayFare() {
    final String status = tripDetails.currentStatus ?? '';

    if (status == 'cancelled' ||
        status == 'completed' ||
        (tripDetails.parcelInformation?.payer == 'sender' &&
            status == 'ongoing')) {
      return tripDetails.paidFare ?? 0;
    }

    if ((tripDetails.discountActualFare ?? 0) > 0) {
      return tripDetails.discountActualFare ?? 0;
    }

    return tripDetails.actualFare ?? 0;
  }
}

class _VehicleSection extends StatelessWidget {
  final TripDetails tripDetails;

  const _VehicleSection({required this.tripDetails});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 58,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: tripDetails.type != 'parcel'
                  ? ImageWidget(
                      width: 72,
                      height: 58,
                      image: tripDetails.vehicle != null
                          ? '${Get.find<ConfigController>().config!.imageBaseUrl!.vehicleModel!}/${tripDetails.vehicle!.model!.image!}'
                          : '${Get.find<ConfigController>().config!.imageBaseUrl!.vehicleCategory!}/${tripDetails.vehicleCategory?.image!}',
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      Images.parcel,
                      width: 64,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            tripDetails.type != 'parcel'
                ? tripDetails.vehicleCategory?.name ?? ''
                : 'parcel'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textMedium.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.48),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripRoute extends StatelessWidget {
  final String pickupAddress;
  final String destinationAddress;

  const _TripRoute({
    required this.pickupAddress,
    required this.destinationAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              const SizedBox(height: 2),
              const _PickupPointIcon(),
              const SizedBox(height: 3),
              const _RouteLine(),
              const SizedBox(height: 3),
              const Icon(
                Icons.location_on_rounded,
                size: 18,
                color: Color(0xFFE74C3C),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AddressText(address: pickupAddress),
              const SizedBox(height: 14),
              _AddressText(address: destinationAddress),
            ],
          ),
        ),
      ],
    );
  }
}

class _PickupPointIcon extends StatelessWidget {
  const _PickupPointIcon();

  @override
  Widget build(BuildContext context) {
    const Color pickupColor = Color(0xFFFFB100);

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: pickupColor,
          width: 1.8,
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          color: pickupColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          5,
          (index) => Container(
            width: 2,
            height: 2,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressText extends StatelessWidget {
  final String address;

  const _AddressText({required this.address});

  @override
  Widget build(BuildContext context) {
    return Text(
      address,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textRegular.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.color
            ?.withValues(alpha: 0.82),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String? createdAt;

  const _DateRow({required this.createdAt});

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';

    if (createdAt != null && createdAt!.isNotEmpty) {
      formattedDate = DateConverter.localToIsoString(
        DateTime.parse(createdAt!),
      );
    }

    return Row(
      children: [
        Icon(
          Icons.calendar_month_rounded,
          size: 17,
          color: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.color
              ?.withValues(alpha: 0.38),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            formattedDate,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.45),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomSection extends StatelessWidget {
  final TripDetails tripDetails;
  final bool isDetailsScreen;
  final double displayFare;

  const _BottomSection({
    required this.tripDetails,
    required this.isDetailsScreen,
    required this.displayFare,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDetailsScreen) {
      return Row(
        children: [
          Expanded(
            child: tripDetails.estimatedFare != null
                ? Text(
                    PriceConverter.convertPrice(displayFare),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.82),
                    ),
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 8),
          _StatusChip(status: tripDetails.currentStatus ?? ''),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tripDetails.estimatedFare != null)
                Text(
                  PriceConverter.convertPrice(tripDetails.paidFare ?? 0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.82),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                (tripDetails.currentStatus ?? '').tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
        if (Get.find<ConfigController>().config!.reviewStatus! &&
            !(tripDetails.isReviewed ?? false) &&
            tripDetails.driver != null &&
            tripDetails.paymentStatus == 'paid')
          InkWell(
            onTap: () {
              Get.to(() => ReviewScreen(tripId: tripDetails.id!));
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    Images.reviewIcon,
                    height: 15,
                    width: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'give_review'.tr,
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(status, context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        status.tr,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textMedium.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: statusColor,
        ),
      ),
    );
  }

  Color _statusColor(String value, BuildContext context) {
    switch (value.toLowerCase()) {
      case 'ongoing':
        return const Color(0xFF1976D2);
      case 'completed':
        return const Color(0xFF1B9A59);
      case 'cancelled':
        return const Color(0xFFE74B4B);
      case 'accepted':
        return const Color(0xFFFF9800);
      case 'pending':
        return const Color(0xFF7B61FF);
      default:
        return Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color
                ?.withValues(alpha: 0.72) ??
            const Color(0xFF6F7787);
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
