import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/address/widgets/address_item_card.dart';
import 'package:ride_sharing_user_app/features/home/widgets/address_shimmer.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
import 'package:ride_sharing_user_app/features/address/screens/add_new_address.dart';

enum AddressPage { home, sender, receiver }

class HomeMyAddress extends StatefulWidget {
  final String? title;
  final AddressPage? addressPage;

  const HomeMyAddress({super.key, this.title, this.addressPage});

  @override
  State<HomeMyAddress> createState() => _HomeMyAddressState();
}

class _HomeMyAddressState extends State<HomeMyAddress> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddressController>(builder: (addressController) {
      return Container(
        padding: const EdgeInsets.all(Dimensions.paddingSize),
        decoration: BoxDecoration(
            color: (addressController.addressList != null &&
                    addressController.addressList!.isNotEmpty)
                ? const Color.fromRGBO(255, 255, 255, 1)
                : null),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Text(
          //   widget.title ?? 'my_address'.tr,
          //   style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
          // ),
          // if (addressController.addressList != null &&
          //     addressController.addressList!.isNotEmpty)
          //   Text('saved_address_for_your_trip'.tr,
          //       style:
          //           textRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
          // const SizedBox(height: Dimensions.paddingSizeSmall),
          addressController.addressList != null
              ? addressController.addressList!.isNotEmpty
                  ? SizedBox(
                      height: Get.width * 0.15,
                      child: ListView.builder(
                        itemCount: addressController.addressList?.length,
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return AddressItemCard(
                            address: addressController.addressList![index],
                          );
                        },
                      ),
                    )
                  : InkWell(
                      onTap: () =>
                          Get.to(() => const AddNewAddress(address: null)),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                Dimensions.paddingSizeSmall),
                            color: Get.isDarkMode
                                ? Theme.of(context).canvasColor
                                : const Color.fromRGBO(255, 239, 203, 1),
                            border: Border.all(
                              color: Get.isDarkMode
                                  ? Theme.of(context).canvasColor
                                  : const Color.fromRGBO(0, 0, 0, 0.1),
                            )),
                        child: Row(children: [
                          Padding(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeDefault),
                            child: Container(
                              width: Dimensions.buttonSize,
                              height: Dimensions.buttonSize,
                              decoration: BoxDecoration(
                                color: Get.isDarkMode
                                    ? Theme.of(context).cardColor
                                    : const Color.fromRGBO(255, 255, 255, 1),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.paddingSizeExtraSmall),
                              ),
                              child: const Center(
                                  child: Icon(Icons.add,
                                      color: Color.fromRGBO(250, 173, 2, 1))),
                            ),
                          ),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('add_address'.tr,
                                    style: textRegular.copyWith(
                                        fontSize: Dimensions.fontSizeLarge)),
                                Text(
                                  'save_your_address_for_quick_trip'.tr,
                                  style: textRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall),
                                ),
                              ])),
                          Padding(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall),
                            child: SizedBox(
                                width: 100,
                                child: Image.asset(Images.addNewAddress)),
                          ),
                        ]),
                      ),
                    )
              : const AddressShimmer(),
        ]),
      );
    });
  }
}
