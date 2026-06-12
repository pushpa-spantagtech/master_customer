import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/notification/controllers/notification_controller.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_card.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_shimmer.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    Get.find<NotificationController>().getNotificationList(1);
    super.initState();
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
          padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSixteen, 0,
              Dimensions.paddingSizeSixteen, 0),
          child: GetBuilder<NotificationController>(
              builder: (notificationController) {
            return notificationController.notificationModel != null
                ? (notificationController.notificationModel!.data != null &&
                        notificationController
                            .notificationModel!.data!.isNotEmpty)
                    ? SingleChildScrollView(
                        controller: scrollController,
                        child: PaginatedListWidget(
                          scrollController: scrollController,
                          totalSize: notificationController
                              .notificationModel!.totalSize,
                          offset: (notificationController.notificationModel !=
                                      null &&
                                  notificationController
                                          .notificationModel!.offset !=
                                      null)
                              ? int.parse(notificationController
                                  .notificationModel!.offset
                                  .toString())
                              : null,
                          onPaginate: (int? offset) async {
                            await notificationController
                                .getNotificationList(offset!);
                          },
                          itemView: ListView.builder(
                            itemCount: notificationController
                                .notificationModel!.data!.length,
                            padding: const EdgeInsets.only(
                                top: Dimensions.paddingSize),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return NotificationCard(
                                  notification: notificationController
                                      .notificationModel!.data![index]);
                            },
                          ),
                        ),
                      )
                    : const NoDataWidget(title: 'no_notification_found')
                : const NotificationShimmer();
          }),
        ),
      ),
    );
  }
}
