import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/message/controllers/message_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityScreenRiderDetails extends StatelessWidget {
  const ActivityScreenRiderDetails({super.key});

  static const Color _brandOrange = Color(0xFFFF9800);
  static const Color _softOrange = Color(0xFFFFF3DD);
  static const Color _orangeBorder = Color(0xFFFFD9A0);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(
      builder: (rideController) {
        final trip = rideController.tripDetails;
        final driver = trip?.driver;
        final vehicle = trip?.vehicle;
        final colorScheme = Theme.of(context).colorScheme;

        final String rating = driver != null && trip?.driverAvgRating != null
            ? double.tryParse(
                  trip!.driverAvgRating!,
                )?.toStringAsFixed(1) ??
                '0.0'
            : '0.0';

        final String driverName = driver == null
            ? ''
            : '${driver.firstName ?? ''} ${driver.lastName ?? ''}'.trim();

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFFFFB000),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ImageWidget(
                          height: 48,
                          width: 48,
                          image: driver != null
                              ? '${Get.find<ConfigController>().config!.imageBaseUrl!.profileImageDriver}/${driver.profileImage}'
                              : '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: _brandOrange,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                rating,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _ActionButton(
                      tooltip: 'Message',
                      icon: Icons.chat_bubble_rounded,
                      backgroundColor: _softOrange,
                      iconColor: _brandOrange,
                      borderColor: _orangeBorder,
                      onTap: driver == null
                          ? null
                          : () => Get.find<MessageController>().createChannel(
                                driver.id ?? '0',
                                trip?.id,
                              ),
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      tooltip: 'Call',
                      icon: Icons.call_rounded,
                      backgroundColor: _softOrange,
                      iconColor: _brandOrange,
                      borderColor: _orangeBorder,
                      onTap: driver?.phone == null
                          ? null
                          : () => _launchPhone(driver!.phone!),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outlineVariant,
              ),
              if (vehicle != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.model?.name ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              vehicle.licencePlateNumber ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    letterSpacing: 0.5,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 132,
                        height: 62,
                        child: ImageWidget(
                          image:
                              '${Get.find<ConfigController>().config!.imageBaseUrl!.vehicleModel}/${vehicle.model?.image ?? ''}',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;
  final Color backgroundColor;
  final Color iconColor;
  final Color borderColor;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    required this.backgroundColor,
    required this.iconColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isEnabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        style: IconButton.styleFrom(
          fixedSize: const Size(44, 44),
          minimumSize: const Size(44, 44),
          maximumSize: const Size(44, 44),
          padding: EdgeInsets.zero,
          backgroundColor:
              isEnabled ? backgroundColor : colorScheme.surfaceContainerHighest,
          foregroundColor: isEnabled
              ? iconColor
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          disabledForegroundColor:
              colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          side: BorderSide(
            color: isEnabled ? borderColor : colorScheme.outlineVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        icon: Icon(
          icon,
          size: 21,
        ),
      ),
    );
  }
}
