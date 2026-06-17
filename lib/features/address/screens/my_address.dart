import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/confirmation_dialog_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/features/address/screens/add_new_address.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';

class MyAddressScreen extends StatefulWidget {
  const MyAddressScreen({super.key});

  @override
  State<MyAddressScreen> createState() => _MyAddressScreenState();
}

class _MyAddressScreenState extends State<MyAddressScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<AddressController>().getAddressList(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        title: Text('my_address'.tr,
            style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeLarge, color: Colors.white),
            maxLines: 1,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis),
        backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
        toolbarHeight: 65,
        automaticallyImplyLeading: false,
        excludeHeaderSemantics: true,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        height: Get.height,
        width: Dimensions.webMaxWidth,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(25), topLeft: Radius.circular(25)),
            color: Theme.of(context).cardColor),
        child: GetBuilder<AddressController>(builder: (addressController) {
          return addressController.addressList != null
              ? addressController.addressList!.isNotEmpty
                  ? Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.78,
                          child: ListView.builder(
                            itemCount: addressController.addressList!.length,
                            shrinkWrap: true,
                            addRepaintBoundaries: false,
                            addAutomaticKeepAlives: false,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) => AddressCard(
                                address: addressController.addressList![index]),
                          ),
                        ),
                      ],
                    )
                  : const NoDataWidget(
                      title: 'no_address_found',
                    )
              : const Center(
                  child: SpinKitCircle(
                  color: Color.fromRGBO(250, 173, 2, 1),
                  size: 40.0,
                ));
        }),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.transparent,
          child: const Icon(
            Icons.add_circle,
            color: Color.fromRGBO(250, 173, 2, 1),
            size: Dimensions.iconSizeExtraLarge,
          ),
          onPressed: () {
            Get.to(() => const AddNewAddress());
          }),
    );
  }
}

class AddressCard extends StatelessWidget {
  final Address address;

  const AddressCard({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeSmall, Dimensions.paddingSizeDefault, 0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(Dimensions.paddingSizeExtraLarge),
            border: Border.all(color: const Color.fromRGBO(20, 20, 20, 0.2))),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeDefault,
              horizontal: Dimensions.paddingSizeDefault),
          child: Row(children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Theme.of(context).hintColor)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: Dimensions.iconSizeLarge,
                    child: Image.asset(
                      address.addressLabel == 'home'
                          ? Images.homeIcon
                          : address.addressLabel == 'office'
                              ? Images.workIcon
                              : Images.otherIcon,
                      color: Get.find<ThemeController>().darkTheme
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).hintColor,
                    )),
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address.addressLabel!.tr,
                        style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: const Color.fromRGBO(20, 20, 20, 0.9))),
                    Text(
                      address.address!,
                      style: textSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: const Color.fromRGBO(20, 20, 20, 0.7)),
                    ),
                  ]),
            )),
            InkWell(
              onTap: () => Get.to(() => AddNewAddress(address: address)),
              child: SizedBox(
                  width: Dimensions.iconSizeLarge,
                  child: Image.asset(
                    Images.editIcon,
                    color: const Color.fromRGBO(255, 0, 0, 0.7),
                  )),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            InkWell(
                onTap: () {
                  Get.dialog(
                      ConfirmationDialogWidget(
                        icon: Images.completeIcon,
                        description: 'are_you_sure'.tr,
                        onYesPressed: () {
                          Get.find<AddressController>()
                              .deleteAddress(address.id.toString());
                        },
                      ),
                      barrierDismissible: false);
                },
                child: SizedBox(
                    width: Dimensions.iconSizeLarge,
                    child: Image.asset(
                      Images.delete,
                      color: const Color.fromRGBO(255, 0, 0, 0.7),
                    ))),
          ]),
        ),
      ),
    );
  }
}
