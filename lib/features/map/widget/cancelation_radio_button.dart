import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:ride_sharing_user_app/common_widgets/custom_radio_button.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';

import 'package:ride_sharing_user_app/util/dimensions.dart';

import 'package:ride_sharing_user_app/util/styles.dart';

class CancellationRadioButton extends StatefulWidget {
  final bool isOngoing;

  const CancellationRadioButton({super.key, required this.isOngoing});

  @override
  State<CancellationRadioButton> createState() =>
      _CancellationRadioButtonState();
}

class _CancellationRadioButtonState extends State<CancellationRadioButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'why_do_you_want_to_cancel'.tr,
          style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
        const SizedBox(
          height: Dimensions.paddingSizeDefault,
        ),
        GetBuilder<TripController>(builder: (tripController) {
          List<String> cancelList = widget.isOngoing
              ? (tripController
                      .tripCancellationCauseList!.data!.ongoingRide!.isEmpty
                  ? ["Trip taking too long", "Customer requested cancel"]
                  : tripController
                      .tripCancellationCauseList!.data!.ongoingRide!)
              : (tripController.tripCancellationCauseList!.data!.acceptedRide ??
                  []);

          if (cancelList.isEmpty) {
            return const SizedBox();
          }

          int length = cancelList.length;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CustomRadioButton(
                      text: cancelList[index],
                      isSelected:
                          tripController.tripCancellationCauseCurrentIndex ==
                              index,
                      onTap: () {
                        tripController.setCancellationCurrentIndex(index);
                        setState(() {});
                      },
                      length: length,
                      index: index),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
