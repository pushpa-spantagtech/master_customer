import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/message/domain/models/channel_model.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/message/screens/message_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';

class MessageItem extends StatelessWidget {
  final bool isRead;
  final ChannelUsers? channelUsers;
  final String lastMessage;
  final String tripId;
  final int unReadCount;

  const MessageItem(
      {super.key,
      this.isRead = false,
      required this.channelUsers,
      required this.lastMessage,
      required this.tripId,
      this.unReadCount = 0});

  @override
  Widget build(BuildContext context) {
    return channelUsers != null
        ? InkWell(
            onTap: () => Get.to(() => MessageScreen(
                channelId: channelUsers!.channelId!,
                tripId: tripId,
                userName:
                    '${channelUsers!.user!.firstName!} ${channelUsers!.user!.lastName!}')),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                  horizontal: Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: const Color.fromRGBO(20, 20, 20, 0.1)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(20, 20, 20, 0.1),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                  color: unReadCount == 0
                      ? Theme.of(context).cardColor
                      : Theme.of(context).colorScheme.primary.withValues(alpha: .1)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: Dimensions.paddingSizeSmall,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromRGBO(255, 0, 0, 0.13),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: ImageWidget(
                          height: 35,
                          width: 35,
                          image:
                              '${Get.find<ConfigController>().config?.imageBaseUrl?.profileImageDriver}/${channelUsers?.user?.profileImage ?? ''}'),
                    ),
                  ),
                  const SizedBox(
                    width: Dimensions.paddingSizeSmall,
                  ),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${channelUsers?.user?.firstName ?? ''} ${channelUsers?.user?.lastName ?? ''}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: textBold.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: const Color.fromRGBO(
                                          20, 20, 20, 0.9))),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),
                              Text(
                                lastMessage.isNotEmpty
                                    ? lastMessage
                                    : 'send_an_attachment'.tr,
                                style: textSemiBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color:
                                        const Color.fromRGBO(20, 20, 20, 0.7)),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeSmall,
                              ),
                              Text(
                                  DateConverter
                                      .isoDateTimeStringToDifferentWithCurrentTime(
                                          channelUsers?.updatedAt ??
                                              DateTime.now().toString()),
                                  textDirection: TextDirection.ltr,
                                  style: textMedium.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: Theme.of(context).hintColor))
                            ]),
                      ),
                      unReadCount != 0
                          ? Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: Text(unReadCount.toString(),
                                      style: textRegular.copyWith(
                                          color: Theme.of(context).cardColor))))
                          : const SizedBox()
                    ],
                  )),
                  const SizedBox(
                    width: Dimensions.paddingSizeSmall,
                  ),
                ],
              ),
            ),
          )
        : const SizedBox();
  }
}
