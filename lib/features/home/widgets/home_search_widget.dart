import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class HomeSearchWidget extends StatelessWidget {
  final bool isLocal;
  final bool isRental;
  final bool isOutstation;

  const HomeSearchWidget({
    super.key,
    this.isLocal = false,
    this.isRental = false,
    this.isOutstation = false,
  });

  static const Color _brandRed = Color(0xFFE71921);
  static const Color _ink = Color(0xFF121A2C);
  static const Color _muted = Color(0xFF8B93A1);

  @override
  Widget build(BuildContext context) {
    if (isRental) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () => Get.to(
            () => SetDestinationScreen(
          isLocal: isLocal,
          isRental: isRental,
          isOutstation: isOutstation,
        ),
      ),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [

            Container(
              height: 76,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFFFCACA),
                  width: 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _brandRed.withValues(alpha: 0.07),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [

                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: _brandRed,
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'where_to_go'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(
                        color: _ink,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 18,
              top: -9,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  isOutstation ? 'Drop city' : 'Destination',
                  style: textMedium.copyWith(
                    color: _brandRed,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}