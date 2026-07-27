import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/categoty_model.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RideCategoryWidget extends StatelessWidget {
  final Function(void)? onTap;

  const RideCategoryWidget({super.key, this.onTap});

  static const Color _brandRed = Color(0xFFE71921);
  static const Color _brandGold = Color(0xFFFFB100);
  static const Color _ink = Color(0xFF121A2C);
  static const Color _muted = Color(0xFF6F7787);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      return GetBuilder<CategoryController>(builder: (categoryController) {
        if (categoryController.categoryList == null) {
          return const Center(
              child: SpinKitCircle(color: _brandGold, size: 40.0));
        }
        if (categoryController.categoryList!.isEmpty) {
          return Center(child: Text('no_category_found'.tr));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('choose_your_ride'.tr,
                    style: textBold.copyWith(color: _ink, fontSize: 20)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      borderRadius: BorderRadius.circular(999)),
                  child: Row(children: [
                    Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: _brandRed, shape: BoxShape.circle)),
                    const SizedBox(width: 7),
                    Text('SevenTaxi',
                        style:
                            textBold.copyWith(color: _brandRed, fontSize: 13)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 126,
              child: ListView.separated(
                itemCount: categoryController.categoryList!.length,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final category = categoryController.categoryList![index];
                  final selected = rideController.rideCategoryIndex == index;
                  return _PremiumRideCategoryCard(
                      index: index,
                      category: category,
                      selected: selected,
                      onTap: onTap);
                },
              ),
            ),
          ],
        );
      });
    });
  }
}

class _PremiumRideCategoryCard extends StatelessWidget {
  final int index;
  final Category category;
  final bool selected;
  final Function(void)? onTap;

  const _PremiumRideCategoryCard(
      {required this.index,
      required this.category,
      required this.selected,
      required this.onTap});

  static const Color _brandRed = Color(0xFFE71921);
  static const Color _ink = Color(0xFF121A2C);
  static const Color _muted = Color(0xFF6F7787);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.find<RideController>().setRideCategoryIndex(index);
        onTap?.call('');
      },
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 138,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFFE71921), Color(0xFFFF5A1F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)
              : null,
          color: selected ? null : Colors.white,
          border: Border.all(
              color: selected ? Colors.transparent : const Color(0xFFE8EBF0),
              width: 1.2),
          boxShadow: [
            BoxShadow(
                color: selected
                    ? _brandRed.withValues(alpha: 0.24)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: selected ? 24 : 14,
                offset: Offset(0, selected ? 12 : 8)),
          ],
        ),
        child: Stack(children: [
          if (selected)
            Positioned(
                right: -18,
                bottom: -22,
                child: Icon(Icons.directions_car_filled_rounded,
                    size: 94, color: Colors.white.withValues(alpha: 0.13))),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                    height: 42, child: _CategoryImage(category: category))),
            const Spacer(),
            Text(category.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textBold.copyWith(
                    color: selected ? Colors.white : _ink, fontSize: 18)),
            const SizedBox(height: 3),
            Text(selected ? 'Selected' : 'Tap to choose',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textMedium.copyWith(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.86)
                        : _muted,
                    fontSize: 12)),
          ]),
          if (selected)
            Positioned(
                right: 0,
                top: 0,
                child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        color: _brandRed, size: 18))),
        ]),
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  final Category category;

  const _CategoryImage({required this.category});

  @override
  Widget build(BuildContext context) {
    if (category.id == '0') {
      return Image.asset(category.image ?? Images.car, fit: BoxFit.contain);
    }
    return ImageWidget(
      height: 42,
      width: 86,
      image:
          '${Get.find<ConfigController>().config?.imageBaseUrl?.vehicleCategory}/${category.image}',
    );
  }
}
