import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/loader_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/rider_info.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/trip_details.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/trip_item_view.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

class TripDetailsScreen extends StatefulWidget {
  final String tripId;
  final bool fromNotification;

  const TripDetailsScreen(
      {super.key, required this.tripId, this.fromNotification = false});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  static const _pdfChannel = MethodChannel('com.seventaxi.customer/trip_pdf');
  bool _downloading = false;
  final _contentCapture = ScreenshotController();

  Widget _details(TripDetails trip) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TripItemView(tripDetails: trip, isDetailsScreen: true),
          TripDetailWidget(tripDetails: trip),
          if (trip.driver != null) RiderInfo(tripDetails: trip),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
      );

  Future<void> _downloadPdf(TripDetails trip) async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      await _pdfChannel.invokeMethod<void>('prepare');
      if (!mounted) return;
      final width = context.size!.width.clamp(0.0, Dimensions.webMaxWidth);
      // Capture the full rendered Column inside the scroll view, preserving
      // loaded images, text layout and content beyond the viewport.
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      final bytes = await _contentCapture.capture(pixelRatio: 2);
      if (bytes == null) throw StateError('Trip content is unavailable');
      if (!mounted) return;
      final header = await ScreenshotController().captureFromWidget(
        Localizations.override(
          context: context,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(padding: EdgeInsets.zero),
            child: Directionality(
              textDirection: Directionality.of(context),
              child: AppBarWidget(
                title: 'trip_details'.tr,
                subTitle: trip.refId,
                showBackButton: false,
                toolbarHeight: 70,
                backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
                centerTitle: true,
              ),
            ),
          ),
        ),
        context: context,
        pixelRatio: 2,
        targetSize: Size(width, 70),
      );
      await _pdfChannel.invokeMethod<String>('save', {
        'image': bytes,
        'header': header,
        'padding': Dimensions.paddingSizeDefault * 2,
        'refId': trip.refId ?? widget.tripId,
      });
    } on PlatformException catch (error) {
      showCustomSnackBar(
          error.message ?? 'Could not download PDF. Please try again.');
    } catch (_) {
      showCustomSnackBar('Could not download PDF. Please try again.');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  void initState() {
    if (!widget.fromNotification) {
      Get.find<RideController>().getRideDetails(widget.tripId);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<RideController>(
        builder: (rideController) {
          return PopScope(
            onPopInvoked: (didPop) {
              rideController.clearRideDetails();
            },
            child: BodyWidget(
              appBar: AppBarWidget(
                title: 'trip_details'.tr,
                actions: !kIsWeb &&
                        defaultTargetPlatform == TargetPlatform.android
                    ? [
                        IconButton(
                          tooltip: 'Download PDF',
                          onPressed: _downloading ||
                                  rideController.tripDetails == null
                              ? null
                              : () => _downloadPdf(rideController.tripDetails!),
                          icon: _downloading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.download_rounded,
                                  color: Colors.white),
                        ),
                      ]
                    : null,
                subTitle: rideController.tripDetails?.refId,
                showBackButton: true,
                toolbarHeight: 70,
                backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
                centerTitle: true,
              ),
              body: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child:
                    GetBuilder<TripController>(builder: (activityController) {
                  return rideController.tripDetails != null
                      ? SingleChildScrollView(
                          child: Screenshot(
                            controller: _contentCapture,
                            child: ColoredBox(
                                color: Colors.white,
                                child: _details(rideController.tripDetails!)),
                          ),
                        )
                      : const LoaderWidget();
                }),
              ),
            ),
          );
        },
      ),
      /* bottomNavigationBar: GetBuilder<RideController>(builder: (rideController){
        return (rideController.tripDetails != null && rideController.tripDetails!.type == 'parcel' */ /*&& rideController.tripDetails!.currentStatus == 'ongoing'*/ /*) ?
        Container(color: Theme.of(context).cardColor,
          child: Container(height: 110,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.paddingSizeExtraLarge), topRight: Radius.circular(Dimensions.paddingSizeExtraLarge)),
              border: Border(top: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.5)))
            ),
            child: Column(children: [
              Text('9  5  9  9',style: textBold.copyWith(fontSize: 20),),

              Text.rich(TextSpan(style: textRegular.copyWith(fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.8)), children:  [

                TextSpan(text: 'please_share_the'.tr,
                    style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.8),
                        fontSize: Dimensions.fontSizeDefault)),

                TextSpan(text: ' OTP '.tr,
                    style: textSemiBold.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault)),

                TextSpan(text: 'with_the_driver'.tr, style: textRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.8),
                    fontSize: Dimensions.fontSizeDefault)),]), textAlign: TextAlign.center),

              const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
              Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: Center(child: SliderButton(
                    action: (){
                      ///TODO
                    },
                    label: Text('parcel_received'.tr,style: TextStyle(color: Theme.of(context).cardColor),),
                    dismissThresholds: 0.5, dismissible: false, shimmer: false,
                    width: 1170, height: 40, buttonSize: 40, radius: 20,
                    icon: Center(child: Container(width: 36, height: 36,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardColor),
                        child: Center(child: Icon(
                            Get.find<LocalizationController>().isLtr ? Icons.arrow_forward_ios_rounded : Icons.keyboard_arrow_left,
                            color: Colors.grey, size: 20.0)))),

                    isLtr: Get.find<LocalizationController>().isLtr,
                    boxShadow: const BoxShadow(blurRadius: 0),
                    buttonColor: Colors.transparent,
                    backgroundColor: Theme.of(context).primaryColor,
                    baseColor: Theme.of(context).primaryColor)),
              )
            ],),
          ),
        ) : const SizedBox();
      },),*/
    );
  }
}
