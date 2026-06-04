import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/categoty_model.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CategoryWidget extends StatelessWidget {
  final Category category;
  final bool? isSelected;
  final bool fromSelect;
  final int index;
  final Function(void)? onTap;

  const CategoryWidget(
      {super.key,
      required this.category,
      this.isSelected,
      this.fromSelect = false,
      required this.index,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.find<RideController>().setRideCategoryIndex(index);
        if (!fromSelect) {
          Get.to(() => const SetDestinationScreen());
        } else {
          onTap!('');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: (isSelected != null && isSelected!)
              ? const Color.fromRGBO(255, 255, 255, 1)
              : Theme.of(context).hintColor.withValues(alpha: 0.1),
          border: Border.all(
            color: (isSelected ?? false)
                ? const Color.fromRGBO(255, 0, 0, 0.3)
                : const Color.fromRGBO(0, 0, 0, 0.1),
          ),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSixteen),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            category.name ?? '',
            style: textSemiBold.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.8),
              fontSize: Dimensions.fontSizeSmall,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: category.id == '0'
                ? Image.asset(
                    category.image ?? '',
                    height: 20,
                    width: 65,
                  )
                : ImageWidget(
                    height: 20, width: 65,
                    image:
                        '${Get.find<ConfigController>().config?.imageBaseUrl?.vehicleCategory}/${category.image}',
                    // fit: BoxFit.contain,
                  ),
          ),
        ]),
      ),
    );
  }
}
