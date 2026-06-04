import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/banner_view.dart';
import 'package:ride_sharing_user_app/features/home/widgets/best_offers_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/coupon_home_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_map_view.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_search_widget.dart';
import 'package:ride_sharing_user_app/features/my_offer/controller/offer_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/driver_request_dialog.dart';
import 'package:ride_sharing_user_app/helper/home_screen_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
import 'package:ride_sharing_user_app/features/home/controllers/banner_controller.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_my_address.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String greetingMessage() {
    var timeNow = DateTime.now().hour;
    if (timeNow <= 12) {
      return 'good_morning'.tr;
    } else if ((timeNow > 12) && (timeNow <= 16)) {
      return 'good_afternoon'.tr;
    } else if ((timeNow > 16) && (timeNow < 20)) {
      return 'good_evening'.tr;
    } else {
      return 'good_night'.tr;
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  bool clickedMenu = false;

  Future<void> loadData() async {
    Get.find<ParcelController>().getUnpaidParcelList();
    Get.find<BannerController>().getBannerList();
    Get.find<CategoryController>().getCategoryList();
    Get.find<AddressController>().getAddressList(1);
    Get.find<CouponController>().getCouponList(1, isUpdate: false);
    Get.find<OfferController>().getOfferList(1);
    if (Get.find<ProfileController>().profileModel == null) {
      Get.find<ProfileController>().getProfileInfo();
    }
    await Get.find<RideController>().getCurrentRide();
    if (Get.find<RideController>().currentTripDetails != null) {
      Get.find<RideController>().getBiddingList(
          Get.find<RideController>().currentTripDetails!.id!, 1);
      PusherHelper().pusherDriverStatus(
          Get.find<RideController>().currentTripDetails!.id!);
      if (Get.find<RideController>().currentTripDetails!.currentStatus ==
              'accepted' ||
          Get.find<RideController>().currentTripDetails!.currentStatus ==
              'ongoing') {
        Get.find<RideController>().startLocationRecord();
      }
    } else {
      Get.find<RideController>().clearBiddingList();
    }
    await Get.find<ParcelController>().getOngoingParcelList();
    if (Get.find<ParcelController>().parcelListModel!.data!.isNotEmpty) {
      for (var element in Get.find<ParcelController>().parcelListModel!.data!) {
        PusherHelper().pusherDriverStatus(element.id!);
      }
    }
    Get.find<RideController>().getNearestDriverList(
      Get.find<LocationController>().getUserAddress()!.latitude!.toString(),
      Get.find<LocationController>().getUserAddress()!.longitude!.toString(),
    );
    HomeScreenHelper().checkMaintanceMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
        toolbarHeight: 14,
        automaticallyImplyLeading: false,
      ),
      body: GetBuilder<RideController>(builder: (rideController) {
        return GetBuilder<ParcelController>(builder: (parcelController) {
          int parcelCount = 0; // Parcel feature hidden
          int rideCount = (rideController.rideDetails != null &&
                  rideController.rideDetails!.type == 'ride_request' &&
                  (rideController.rideDetails!.currentStatus == 'pending' ||
                      rideController.rideDetails!.currentStatus == 'accepted' ||
                      rideController.rideDetails!.currentStatus == 'ongoing' ||
                      (rideController.rideDetails!.currentStatus ==
                              'completed' &&
                          rideController.rideDetails!.paymentStatus! ==
                              'unpaid') ||
                      (rideController.rideDetails!.currentStatus ==
                              'cancelled' &&
                          rideController.rideDetails!.paymentStatus! ==
                              'unpaid')))
              ? 1
              : 0;

          return Stack(children: [
            GetBuilder<ProfileController>(builder: (profileController) {
              return GetBuilder<RideController>(builder: (rideController) {
                return GetBuilder<ParcelController>(
                    builder: (parcelController) {
                  return RefreshIndicator(
                    color: const Color.fromRGBO(250, 173, 2, 1),
                    onRefresh: () async {
                      await loadData();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          GetBuilder<BannerController>(
                            builder: (bannerController) {
                              return bannerController.bannerList != null &&
                                      bannerController.bannerList!.isNotEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal: 2,
                                      ),
                                      child: BannerView(),
                                    )
                                  : const SizedBox();
                            },
                          ),

                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: HomeSearchWidget(),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: HomeMapView(),
                          ),
                          // HomeMyAddress(addressPage: AddressPage.home),
                          GetBuilder<OfferController>(
                            builder: (offerController) {
                              return offerController.bestOfferModel != null &&
                                      offerController.bestOfferModel!.data !=
                                          null &&
                                      offerController
                                          .bestOfferModel!.data!.isNotEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeEight,
                                          vertical: 4),
                                      child: BestOfferWidget(),
                                    )
                                  : const SizedBox();
                            },
                          ),
                          GetBuilder<CouponController>(
                            builder: (couponController) {
                              return couponController.couponModel != null &&
                                      couponController.couponModel!.data !=
                                          null &&
                                      couponController
                                          .couponModel!.data!.isNotEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeEight,
                                          vertical: 4),
                                      child: HomeCouponWidget(),
                                    )
                                  : const SizedBox();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                });
              });
            }),
            (rideCount + parcelCount) != 0
                ? Positioned(
                    child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          clickedMenu = true;
                        });
                      },
                      onHorizontalDragEnd: (DragEndDetails details) {
                        _onHorizontalDrag(details);
                      },
                      child: Stack(children: [
                        SizedBox(
                          width: 70,
                          child: Image.asset(
                            Images.homeMapIcon,
                            color: const Color.fromRGBO(250, 173, 2, 1),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          bottom: 15,
                          left: 35,
                          right: 0,
                          child: SizedBox(
                              height: 10,
                              child: Image.asset(Images.ongoing, scale: 2.7)),
                        ),
                        Positioned(
                          bottom: 85,
                          right: 5,
                          child: Container(
                            width: 20,
                            height: 20,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                                child: Text(
                              '${rideCount + parcelCount}',
                              style: textRegular.copyWith(
                                color: Colors.white,
                                fontSize: Dimensions.fontSizeExtraSmall,
                              ),
                            )),
                          ),
                        )
                      ]),
                    ),
                  ))
                : const SizedBox(),
            if (clickedMenu)
              Positioned(
                  child: Align(
                alignment: Alignment.centerRight,
                child: GetBuilder<RideController>(builder: (rideController) {
                  return GetBuilder<ParcelController>(
                      builder: (parcelController) {
                    return Container(
                      width: 200,
                      height: 70,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .hintColor
                                .withValues(alpha: .5),
                            blurRadius: 1,
                            spreadRadius: 1,
                            offset: const Offset(1, 1),
                          )
                        ],
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(10)),
                        color: Theme.of(context).cardColor,
                      ),
                      child: Row(children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              clickedMenu = false;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Theme.of(context).hintColor,
                              size: Dimensions.iconSizeMedium,
                            ),
                          ),
                        ),
                        Column(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeDefault),
                            child: InkWell(
                              onTap: () async {
                                await rideController.getCurrentRideStatus(
                                    fromRefresh: true);
                                setState(() {
                                  clickedMenu = false;
                                });
                              },
                              child: Container(
                                width: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromRGBO(0, 0, 0, 0.1),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color.fromRGBO(255, 239, 203, 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('ongoing_ride'.tr),
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor:
                                            Theme.of(context).colorScheme.error,
                                        child: Text(
                                          '$rideCount',
                                          style: textRegular.copyWith(
                                            color: Theme.of(context).cardColor,
                                            fontSize: Dimensions.fontSizeSmall,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Parcel delivery button hidden
                        ]),
                      ]),
                    );
                  });
                }),
              )),
          ]);
        });
      }),
      floatingActionButton:
          GetBuilder<RideController>(builder: (rideController) {
        return rideController.biddingList.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(bottom: Get.height * 0.08),
                child: FloatingActionButton(
                  onPressed: () {
                    if (!rideController.isLoading) {
                      rideController
                          .getBiddingList(
                              rideController.currentTripDetails!.id!, 1)
                          .then((value) {
                        if (rideController.biddingList.isNotEmpty) {
                          Get.dialog(
                              barrierDismissible: true,
                              barrierColor: Colors.black.withValues(alpha: 0.5),
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                              DriverRideRequestDialog(
                                  tripId: Get.find<RideController>()
                                      .currentTripDetails!
                                      .id!));
                        }
                      });
                    }
                  },
                  backgroundColor: Colors.transparent,
                  child: Image.asset(Images.biddingIcon),
                ),
              )
            : const SizedBox();
      }),
    );
  }

  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0) return;

    if (details.primaryVelocity!.compareTo(0) == -1) {
      debugPrint('dragged from left');
    } else {
      debugPrint('dragged from right');
    }
  }
}
