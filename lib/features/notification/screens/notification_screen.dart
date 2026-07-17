import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';
import 'package:ride_sharing_user_app/features/notification/controllers/notification_controller.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_card.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_shimmer.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<NotificationController>().getNotificationList(1);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyWidget(
        appBar: AppBarWidget(
          title: 'notification'.tr,
          showBackButton: false,
          toolbarHeight: 65,
          fontSize: 18,
          backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeSixteen,
            0,
            Dimensions.paddingSizeSixteen,
            0,
          ),
          child: GetBuilder<NotificationController>(
            builder: (notificationController) {
              if (notificationController.notificationModel == null) {
                return const NotificationShimmer();
              }

              final notifications =
                  notificationController.notificationModel!.data;

              if (notifications == null || notifications.isEmpty) {
                return const NoDataWidget(
                  title: 'no_notification_found',
                );
              }

              return SingleChildScrollView(
                controller: scrollController,
                child: PaginatedListWidget(
                  scrollController: scrollController,
                  totalSize:
                  notificationController.notificationModel!.totalSize,
                  offset:
                  notificationController.notificationModel!.offset != null
                      ? int.tryParse(
                    notificationController
                        .notificationModel!.offset
                        .toString(),
                  )
                      : null,
                  onPaginate: (int? offset) async {
                    if (offset != null) {
                      await notificationController.getNotificationList(offset);
                    }
                  },
                  itemView: ListView.builder(
                    itemCount: notifications.length,
                    padding: const EdgeInsets.only(
                      top: Dimensions.paddingSize,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return NotificationCard(
                        notification: notifications[index],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
