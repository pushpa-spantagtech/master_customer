import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          style: textSemiBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: const Color(0xFF121A2C),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Select one reason to continue',
          style: textRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: const Color(0xFF7A8291),
          ),
        ),
        const SizedBox(height: 10),
        GetBuilder<TripController>(
          builder: (tripController) {
            final List<String> cancelList = widget.isOngoing
                ? (tripController
                        .tripCancellationCauseList!.data!.ongoingRide!.isEmpty
                    ? <String>[
                        'Trip taking too long',
                        'Customer requested cancel',
                      ]
                    : tripController
                        .tripCancellationCauseList!.data!.ongoingRide!)
                : (tripController
                        .tripCancellationCauseList!.data!.acceptedRide ??
                    <String>[]);

            if (cancelList.isEmpty) {
              return const SizedBox();
            }

            final int length = cancelList.length;

            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final bool isSelected =
                    tripController.tripCancellationCauseCurrentIndex == index;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == length - 1 ? 0 : 6,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        tripController.setCancellationCurrentIndex(index);
                        setState(() {});
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 46),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFF4F4)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFE71921)
                                : const Color(0xFFE1E5EC),
                            width: isSelected ? 1.4 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFFE71921)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFE71921)
                                      : const Color(0xFF9CA4B2),
                                  width: 1.2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cancelList[index],
                                style: textMedium.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: isSelected
                                      ? const Color(0xFF121A2C)
                                      : const Color(0xFF596273),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
