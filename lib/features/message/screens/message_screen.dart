import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/message/widget/message_bubble.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/message/controllers/message_controller.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_shimmer.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';
import 'dart:math' as math;

class MessageScreen extends StatefulWidget {
  final String channelId;
  final String tripId;
  final String userName;

  const MessageScreen({
    super.key,
    required this.channelId,
    required this.tripId,
    required this.userName,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  void initState() {
    Get.find<MessageController>().findChannelRideStatus(widget.channelId);
    Get.find<MessageController>().getConversation(widget.channelId, 1);
    Get.find<MessageController>().subscribeMessageChannel(widget.tripId);
    super.initState();
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: BodyWidget(
        appBar: AppBarWidget(
          title: "${'chat_with'.tr} ${widget.userName}",
          showBackButton: true,
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
          toolbarHeight: 65,
        ),
        body: GetBuilder<MessageController>(builder: (messageController) {
          return Column(children: [
            (messageController.messageModel?.data != null)
                ? messageController.messageModel!.data!.isNotEmpty
                    ? Expanded(
                        child: SingleChildScrollView(
                        controller: scrollController,
                        reverse: true,
                        child: PaginatedListWidget(
                          reverse: true,
                          scrollController: scrollController,
                          totalSize: messageController.messageModel!.totalSize,
                          offset: (messageController.messageModel != null &&
                                  messageController.messageModel!.offset !=
                                      null)
                              ? int.parse(messageController.messageModel!.offset
                                  .toString())
                              : null,
                          onPaginate: (int? offset) async {
                            await messageController.getConversation(
                                widget.channelId, offset!);
                          },
                          itemView: ListView.builder(
                            reverse: true,
                            itemCount:
                                messageController.messageModel!.data!.length,
                            padding: const EdgeInsets.all(0),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              if (index != 0) {
                                return ConversationBubble(
                                  message: messageController
                                      .messageModel!.data![index],
                                  previousMessage: messageController
                                      .messageModel!.data![index - 1],
                                  index: index,
                                  length: messageController
                                      .messageModel!.data!.length,
                                );
                              } else {
                                return ConversationBubble(
                                  message: messageController
                                      .messageModel!.data![index],
                                  index: index,
                                  length: messageController
                                      .messageModel!.data!.length,
                                );
                              }
                            },
                          ),
                        ),
                      ))
                    : const Expanded(
                        child: NoDataWidget(title: 'no_message_found'))
                : const Expanded(child: NotificationShimmer()),

            (messageController.pickedImageFile != null &&
                    messageController.pickedImageFile!.isNotEmpty)
                ? Container(
                    height: 90,
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: messageController.pickedImageFile!.length,
                      itemBuilder: (context, index) {
                        return Stack(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: Image.file(
                                    File(messageController
                                        .pickedImageFile![index].path),
                                    fit: BoxFit.cover,
                                  )),
                            ),
                          ),
                          Positioned(
                              right: 5,
                              child: InkWell(
                                onTap: () => messageController
                                    .pickMultipleImage(true, index: index),
                                child: const Icon(Icons.cancel_outlined,
                                    color: Colors.red),
                              )),
                        ]);
                      },
                    ),
                  )
                : const SizedBox(),

            messageController.otherFile != null
                ? Stack(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      height: 25,
                      child:
                          Text(messageController.otherFile!.names.toString()),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () => messageController.pickOtherFile(true),
                        child: const Icon(Icons.cancel_outlined,
                            color: Colors.red),
                      ),
                    ),
                  ])
                : const SizedBox(),

            ///Message send field here.

            const SizedBox(height: 12),
            messageController.channelRideStatus
                ? SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFFD9DEE8),
                            width: 1.2,
                          ),
                        ),
                        child: Form(
                          key: messageController.conversationKey,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller:
                                      messageController.conversationController,
                                  minLines: 1,
                                  maxLines: 4,
                                  keyboardType: TextInputType.multiline,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  textAlignVertical: TextAlignVertical.center,
                                  style: textMedium.copyWith(
                                    fontSize: 15,
                                    height: 1.25,
                                    color: const Color(0xFF121A2C),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "type_here".tr,
                                    hintStyle: textRegular.copyWith(
                                      color: const Color(0xFF8C95A3),
                                      fontSize: 15,
                                      height: 1.25,
                                    ),
                                    filled: false,
                                    isDense: true,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Material(
                                  color: const Color(0xFFE71921),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () {
                                      if (messageController
                                              .conversationController.text
                                              .trim()
                                              .isEmpty &&
                                          messageController
                                              .pickedImageFile!.isEmpty &&
                                          messageController.otherFile == null) {
                                        showCustomSnackBar('write_something'.tr,
                                            isError: true);
                                      } else if (messageController
                                          .conversationKey.currentState!
                                          .validate()) {
                                        messageController.sendMessage(
                                            widget.channelId, widget.tripId);
                                      }
                                      messageController.conversationController
                                          .clear();
                                    },
                                    child: SizedBox(
                                      width: 44,
                                      height: 44,
                                      child: Center(
                                        child: messageController.isSending ||
                                                messageController.isImagePicked
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Transform(
                                                alignment: Alignment.center,
                                                transform: Get.find<
                                                            LocalizationController>()
                                                        .isLtr
                                                    ? Matrix4.identity()
                                                    : Matrix4.rotationY(
                                                        math.pi),
                                                child: const Icon(
                                                  Icons.send_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 55,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(248, 249, 250, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.block),
                            const SizedBox(width: 5),
                            Text(
                              "you_could't_replay_you_have_no_trip".tr,
                              style: textMedium.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: const Color.fromRGBO(20, 20, 20, 1)),
                            ),
                          ]),
                    )),
          ]);
        }),
      ),
    );
  }
}
