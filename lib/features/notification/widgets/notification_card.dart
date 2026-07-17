import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/notification/domain/models/notification_model.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class NotificationCard extends StatelessWidget {
  final Notifications notification;

  const NotificationCard({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final _NotificationStyle notificationStyle =
        _getNotificationStyle(notification.title ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Get.isDarkMode
            ? Theme.of(context).colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Get.isDarkMode
              ? Theme.of(context).dividerColor.withValues(alpha: 0.20)
              : const Color(0xFFF0F1F4),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NotificationIcon(
            style: notificationStyle,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: _NotificationContent(
              notification: notification,
              style: notificationStyle,
            ),
          ),
        ],
      ),
    );
  }

  _NotificationStyle _getNotificationStyle(String title) {
    final String normalizedTitle = title.toLowerCase();

    if (normalizedTitle.contains('cancel')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFFEF4444),
        icon: Icons.cancel_rounded,
      );
    }

    if (normalizedTitle.contains('complete')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFF16A34A),
        icon: Icons.task_alt_rounded,
      );
    }

    if (normalizedTitle.contains('message')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFF2563EB),
        icon: Icons.mark_chat_unread_rounded,
      );
    }

    if (normalizedTitle.contains('arrived')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFF7C3AED),
        icon: Icons.pin_drop_rounded,
      );
    }

    if (normalizedTitle.contains('started')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFF2563EB),
        icon: Icons.play_circle_fill_rounded,
      );
    }

    if (normalizedTitle.contains('payment') &&
        normalizedTitle.contains('pending')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFFF59E0B),
        icon: Icons.account_balance_wallet_rounded,
      );
    }

    if (normalizedTitle.contains('payment')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFF16A34A),
        icon: Icons.payments_rounded,
      );
    }

    if (normalizedTitle.contains('request')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFFF59E0B),
        icon: Icons.directions_car_filled_rounded,
      );
    }

    if (normalizedTitle.contains('way') ||
        normalizedTitle.contains('accepted')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFFF59E0B),
        icon: Icons.local_taxi_rounded,
      );
    }

    return const _NotificationStyle(
      foregroundColor: Color(0xFF6D5EF5),
      icon: Icons.notifications_active_rounded,
    );
  }
}

class _NotificationContent extends StatelessWidget {
  final Notifications notification;
  final _NotificationStyle style;

  const _NotificationContent({
    required this.notification,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title ?? '',
                style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                notification.description ?? '',
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  height: 1.35,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.67),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (notification.createdAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        DateConverter.isoStringToLocalDateAndMonthOnly(
                          notification.createdAt!,
                        ),
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context)
                              .hintColor
                              .withValues(alpha: 0.82),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Positioned(
          top: 3,
          right: 1,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: style.foregroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: style.foregroundColor.withValues(alpha: 0.35),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final _NotificationStyle style;

  const _NotificationIcon({
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Center(
        child: Icon(
          style.icon,
          size: 27,
          color: style.foregroundColor,
        ),
      ),
    );
  }
}

class _NotificationStyle {
  final Color foregroundColor;
  final IconData icon;

  const _NotificationStyle({
    required this.foregroundColor,
    required this.icon,
  });
}
