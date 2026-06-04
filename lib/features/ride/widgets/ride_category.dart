import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/category_widget.dart';

class RideCategoryWidget extends StatelessWidget {
  final Function(void)? onTap;
  const RideCategoryWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      return GetBuilder<CategoryController>(builder: (categoryController) {
        return categoryController.categoryList != null
            ? categoryController.categoryList!.isNotEmpty
                ? SizedBox(
                    height: 60,
                    child: ListView.builder(
                        itemCount: categoryController.categoryList!.length,
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return CategoryWidget(
                            index: index,
                            fromSelect: true,
                            category: categoryController.categoryList![index],
                            isSelected:
                                rideController.rideCategoryIndex == index,
                            onTap: onTap,
                          );
                        }))
                : Center(child: Text('no_category_found'.tr))
            : const Center(
                child: SpinKitCircle(
                    color: Color.fromRGBO(250, 173, 2, 1), size: 40.0));
      });
    });
  }
}
