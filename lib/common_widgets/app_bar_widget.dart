import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showActionButton;
  final Function()? onBackPressed;
  final bool centerTitle;
  final double? fontSize;
  final double? toolbarHeight;
  final bool isHome;
  final String? subTitle;
  final Color? backgroundColor;

  const AppBarWidget({
    super.key,
    required this.title,
    this.subTitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = false,
    this.showActionButton = true,
    this.isHome = false,
    this.fontSize,
    this.toolbarHeight,
    this.backgroundColor,
  });

  final Color whiteColor = const Color.fromRGBO(255, 255, 255, 1);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(150.0),
      child: AppBar(
        elevation: 0,
        backgroundColor:
            backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        toolbarHeight: toolbarHeight ?? 80,
        automaticallyImplyLeading: false,
        title: InkWell(
          onTap: isHome
              ? () {
                  Address? address =
                      Get.find<LocationController>().getUserAddress();
                  if (address == null || address.longitude == null) {
                    Get.to(() => const AccessLocationScreen());
                  } else {
                    Get.find<LocationController>().updatePosition(
                      LatLng(address.latitude!, address.longitude!),
                      false,
                      LocationType.location,
                    );
                    Get.to(() => const PickMapScreen(
                        type: LocationType.accessLocation,
                        oldLocationExist: true));
                  }
                }
              : null,
          child: Padding(
            padding: EdgeInsets.only(
                left: showBackButton
                    ? Dimensions.paddingSizeExtraSmall
                    : Dimensions.paddingSizeSixteen),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.tr,
                  style: textSemiBold.copyWith(
                      fontSize: fontSize ?? Dimensions.fontSizeLarge,
                      color: const Color.fromRGBO(255, 255, 255, 1),
                      letterSpacing: 0),
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
                subTitle != null
                    ? Text(
                        '${'trip'.tr} #$subTitle',
                        style: textRegular.copyWith(
                          fontSize: fontSize ??
                              (isHome
                                  ? Dimensions.fontSizeLarge
                                  : Dimensions.fontSizeLarge),
                          color: whiteColor,
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const SizedBox(),
                isHome
                    ? GetBuilder<LocationController>(
                        builder: (locationController) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeExtraSmall),
                          child: Row(children: [
                            Icon(Icons.place_outlined,
                                color: whiteColor, size: 16),
                            const SizedBox(width: Dimensions.paddingSizeSeven),
                            Expanded(
                                child: Text(
                              locationController.getUserAddress()?.address ??
                                  '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textRegular.copyWith(
                                  color: whiteColor,
                                  fontSize: Dimensions.fontSizeExtraSmall),
                            )),
                          ]),
                        );
                      })
                    : const SizedBox.shrink()
              ],
            ),
          ),
        ),
        centerTitle: centerTitle,
        excludeHeaderSemantics: true,
        titleSpacing: 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                iconSize: 22,
                color: const Color.fromRGBO(255, 255, 255, 1),
                onPressed: () =>
                    onBackPressed != null ? onBackPressed!() : Get.back(),
              )
            : null,
      ),
    );
  }

  @override
  Size get preferredSize => const Size(Dimensions.webMaxWidth, 150);
}
