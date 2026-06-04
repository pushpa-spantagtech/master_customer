import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class AddressItemCard extends StatelessWidget {
  final Address address;

  const AddressItemCard({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => SetDestinationScreen(address: address));
      },
      child: Container(
        width: Get.width - 32,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSize),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 1),
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
          border: Border.all(
            color: Theme.of(context).hintColor.withAlpha(65),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              address.addressLabel == 'home'
                  ? Images.homeIcon
                  : address.addressLabel == 'office'
                      ? Images.workIcon
                      : Images.otherIcon,
              color: Get.find<ThemeController>().darkTheme
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).hintColor,
              height: 16,
              width: 16,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(address.addressLabel!.tr, style: textBold),
                Text(
                  address.address ?? '',
                  style: textRegular,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).hintColor,
            size: 20,
          ),
        ]),
      ),
    );
  }
}
