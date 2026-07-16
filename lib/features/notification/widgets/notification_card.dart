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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showNotificationDetails(
          context,
          notificationStyle,
        ),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
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
          ),
        ),
      ),
    );
  }

  void _showNotificationDetails(
    BuildContext context,
    _NotificationStyle notificationStyle,
  ) {
    Get.bottomSheet(
      Material(
        color: Colors.transparent,
        child: Container(
          width: Get.width,
          padding: EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault,
            10,
            Dimensions.paddingSizeDefault,
            MediaQuery.paddingOf(context).bottom + 24,
          ),
          decoration: BoxDecoration(
            color: Get.isDarkMode
                ? Theme.of(context).colorScheme.surface
                : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(26),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 22),
              _NotificationIcon(
                style: notificationStyle,
                size: 58,
                iconSize: 28,
              ),
              const SizedBox(height: 14),
              Text(
                notification.title ?? '',
                textAlign: TextAlign.center,
                style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                notification.description ?? '',
                textAlign: TextAlign.center,
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  height: 1.45,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.68),
                ),
              ),
              if (notification.createdAt != null) ...[
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateConverter.isoStringToLocalDateAndMonthOnly(
                        notification.createdAt!,
                      ),
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
    );
  }

  _NotificationStyle _getNotificationStyle(String title) {
    final String normalizedTitle = title.toLowerCase();

    if (normalizedTitle.contains('cancel')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFFEF4444),
        backgroundColor: Color(0xFFFFECEC),
        icon: Icons.cancel_rounded,
      );
    }

    if (normalizedTitle.contains('complete')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFF16A34A),
        backgroundColor: Color(0xFFEAF8EF),
        icon: Icons.task_alt_rounded,
      );
    }

    if (normalizedTitle.contains('message')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFF2563EB),
        backgroundColor: Color(0xFFEAF2FF),
        icon: Icons.mark_chat_unread_rounded,
      );
    }

    if (normalizedTitle.contains('arrived')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFF7C3AED),
        backgroundColor: Color(0xFFF2ECFF),
        icon: Icons.pin_drop_rounded,
      );
    }

    if (normalizedTitle.contains('started')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFF2563EB),
        backgroundColor: Color(0xFFE8F0FF),
        icon: Icons.play_circle_fill_rounded,
      );
    }

    if (normalizedTitle.contains('payment') &&
        normalizedTitle.contains('pending')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFFF59E0B),
        backgroundColor: Color(0xFFFFF7E4),
        icon: Icons.account_balance_wallet_rounded,
      );
    }

    if (normalizedTitle.contains('payment')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFF16A34A),
        backgroundColor: Color(0xFFEAF8EF),
        icon: Icons.payments_rounded,
      );
    }

    if (normalizedTitle.contains('request')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFFF59E0B),
        backgroundColor: Color(0xFFFFF7E4),
        icon: Icons.directions_car_filled_rounded,
      );
    }

    if (normalizedTitle.contains('way') ||
        normalizedTitle.contains('accepted')) {
      return const _NotificationStyle(
        foregroundColor: Color(0xFFF59E0B),
        backgroundColor: Color(0xFFFFF7E4),
        icon: Icons.local_taxi_rounded,
      );
    }

    return const _NotificationStyle(
      foregroundColor: Color(0xFF6D5EF5),
      backgroundColor: Color(0xFFF0EEFF),
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
  final double size;
  final double iconSize;

  const _NotificationIcon({
    required this.style,
    this.size = 48,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        style.icon,
        size: iconSize,
        color: style.foregroundColor,
      ),
    );
  }
}

class _NotificationStyle {
  final Color foregroundColor;
  final Color backgroundColor;
  final IconData icon;

  const _NotificationStyle({
    required this.foregroundColor,
    required this.backgroundColor,
    required this.icon,
  });
}
