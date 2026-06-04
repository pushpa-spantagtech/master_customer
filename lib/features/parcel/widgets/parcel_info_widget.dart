import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/auth/widgets/test_field_title.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';
import 'package:flutter/services.dart';
import 'package:ride_sharing_user_app/util/styles.dart';


class ParcelInfoWidget extends StatefulWidget {
  final bool isSender;
  final GlobalKey<ExpandableBottomSheetState> expandableKey;
  const ParcelInfoWidget({super.key, required this.isSender, required this.expandableKey});

  @override
  State<ParcelInfoWidget> createState() => _ParcelInfoWidgetState();
}

class _ParcelInfoWidgetState extends State<ParcelInfoWidget> {


  @override
  void initState() {
    super.initState();

    if(widget.isSender) {
      Get.find<ParcelController>().senderContactController.text = Get.find<ProfileController>().profileModel!.data!.phone!;
      Get.find<ParcelController>().senderNameController.text = Get.find<ProfileController>().customerName();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParcelController>(builder: (parcelController) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

        TextFieldTitle(title: 'contact'.tr, textOpacity: 0.8),
        CustomTextField(
          prefix: false,
          borderRadius: 10,
          showBorder: false,
          hintText: 'contact_number'.tr,
          fillColor:  Get.isDarkMode? Theme.of(context).cardColor : Theme.of(context).primaryColor.withValues(alpha: 0.04),
          controller: widget.isSender ? parcelController.senderContactController : parcelController.receiverContactController,
          focusNode: widget.isSender ? parcelController.senderContactNode : parcelController.receiverContactNode,
          nextFocus: widget.isSender ? parcelController.senderNameNode : parcelController.receiverNameNode,
          inputType: TextInputType.phone,
          ),

        TextFieldTitle(title: 'name'.tr, textOpacity: 0.8),
        CustomTextField(
          prefixIcon: Images.editProfilePhone,
          borderRadius: 10,
          showBorder: false,
          prefix: false,
          capitalization: TextCapitalization.words,
          hintText: 'name'.tr,
          fillColor: Get.isDarkMode? Theme.of(context).cardColor : Theme.of(context).primaryColor.withValues(alpha: 0.04),
          controller: widget.isSender ? parcelController.senderNameController : parcelController.receiverNameController,
          focusNode: widget.isSender ? parcelController.senderNameNode : parcelController.receiverNameNode,
          nextFocus: widget.isSender ? parcelController.senderAddressNode : parcelController.receiverAddressNode,
          inputType: TextInputType.text,
          onTap: () => parcelController.focusOnBottomSheet(widget.expandableKey)),

        TextFieldTitle(title: 'address'.tr, textOpacity: 0.8),

        InkWell(
          onTap: () => RouteHelper.goPageAndHideTextField(context, PickMapScreen(
            type: widget.isSender? LocationType.senderLocation : LocationType.receiverLocation,
          )),
          child: CustomTextField(
            prefix: false,
            suffixIcon: Images.location,
            borderRadius: 10,
            isEnabled: false,
            showBorder: false,
            hintText: 'location'.tr,
            fillColor:  Get.isDarkMode? Theme.of(context).cardColor : Theme.of(context).primaryColor.withValues(alpha: 0.04),
            controller: widget.isSender ? parcelController.senderAddressController : parcelController.receiverAddressController,
            focusNode: widget.isSender ? parcelController.senderAddressNode : parcelController.receiverAddressNode,
            inputType: TextInputType.text,
            inputAction: TextInputAction.done,
            onTap: () => parcelController.focusOnBottomSheet(widget.expandableKey),
          ),
        ),

        GetBuilder<AddressController>(builder: (addressController){
          return addressController.addressList != null ?
          addressController.addressList!.isNotEmpty ?
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: SizedBox(
              height: Get.width *0.075,
              child: ListView.builder(
                itemCount: addressController.addressList?.length,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context,index) {
                  return InkWell(
                    onTap: () {
                      if(widget.isSender) {
                        Get.find<LocationController>().setSenderAddress(addressController.addressList?[index]);
                      }else {
                        Get.find<LocationController>().setReceiverAddress(addressController.addressList?[index]);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSize),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border.all(
                          color:Get.isDarkMode ?
                          Theme.of(context).hintColor :
                          Theme.of(context).primaryColor.withValues(alpha: 0.4),width:0.5,
                        ),
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Image.asset(
                          addressController.addressList?[index].addressLabel == 'home' ? Images.homeIcon :
                          addressController.addressList?[index].addressLabel == 'office' ? Images.workIcon : Images.otherIcon,
                          color: Get.find<ThemeController>().darkTheme ?
                          Theme.of(context).primaryColor :
                          Theme.of(context).hintColor,
                          height: 16,width: 16,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Text(addressController.addressList![index].addressLabel!.tr,style: textBold),

                      ]),
                    ),
                  );
                },
              ),
            ),
          ) :
          const SizedBox(height: Dimensions.paddingSizeSmall) :
          const SizedBox(height: Dimensions.paddingSizeSmall);
        }),

        ButtonWidget(buttonText: "next".tr,
          onPressed: () {
            if(parcelController.tabController.index == 0) {
              if(parcelController.senderContactController.text.isEmpty){
                showCustomSnackBar('enter_sender_contact_number'.tr);
                FocusScope.of(context).requestFocus(parcelController.senderContactNode);
              }else if(parcelController.senderNameController.text.isEmpty){
                showCustomSnackBar('enter_sender_name'.tr);
                FocusScope.of(context).requestFocus(parcelController.senderNameNode);
                parcelController.focusOnBottomSheet(widget.expandableKey);
              } else if(parcelController.senderAddressController.text.isEmpty){
                showCustomSnackBar('enter_sender_address'.tr);
                RouteHelper.goPageAndHideTextField(context, PickMapScreen(
                  type: widget.isSender? LocationType.senderLocation : LocationType.receiverLocation,
                ));
              }else {
                parcelController.updateTabControllerIndex(1);
              }
            }
            else {
              if(parcelController.receiverContactController.text.isEmpty){
                showCustomSnackBar('enter_receiver_contact_number'.tr);
                FocusScope.of(context).requestFocus(parcelController.receiverContactNode);
              }else if(parcelController.receiverNameController.text.isEmpty){
                showCustomSnackBar('enter_receiver_name'.tr);
                FocusScope.of(context).requestFocus(parcelController.receiverNameNode);
                parcelController.focusOnBottomSheet(widget.expandableKey);
              } else if(parcelController.receiverAddressController.text.isEmpty){
                showCustomSnackBar('enter_receiver_address'.tr);
                RouteHelper.goPageAndHideTextField(context, PickMapScreen(
                  type: widget.isSender? LocationType.senderLocation : LocationType.receiverLocation,
                ));
              }else if(parcelController.senderContactController.text.isEmpty){
                showCustomSnackBar('enter_sender_contact_number'.tr);
              }else if(parcelController.senderNameController.text.isEmpty){
                showCustomSnackBar('enter_sender_name'.tr);
              } else if(parcelController.senderAddressController.text.isEmpty){
                showCustomSnackBar('enter_sender_address'.tr);
                RouteHelper.goPageAndHideTextField(context, PickMapScreen(
                  type: widget.isSender? LocationType.senderLocation : LocationType.receiverLocation,
                ));
              }else {
                Get.find<MapController>().notifyMapController();
                parcelController.updateParcelState(ParcelDeliveryState.addOtherParcelDetails);
              }
            }
          },
        ),

      ]);
    });
  }
}
