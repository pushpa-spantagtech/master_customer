import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CalenderWidget extends StatefulWidget {
  final Function(Object? text) onChanged;

  const CalenderWidget({super.key, required this.onChanged});

  @override
  State<CalenderWidget> createState() => _CalenderWidgetState();
}

class _CalenderWidgetState extends State<CalenderWidget> {
  String _range = '';

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        _range = '${DateFormat('yyyy-MM-d').format(args.value.startDate)}/'
            '${DateFormat('yyyy-MM-d').format(args.value.endDate ?? args.value.startDate)}';
      } else if (args.value is DateTime) {
      } else if (args.value is List<DateTime>) {
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> rng = _range.split('/');
    final DateRangePickerController controller = DateRangePickerController();
    DateTime? selectedDate;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault, vertical: 30),
      child: Container(
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(Dimensions.paddingSizeExtraLarge),
            color: const Color.fromRGBO(255, 255, 255, 1)),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                    padding: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeLarge),
                    child: Card(
                        elevation: 0,
                        color: Colors.transparent,
                        child: Text('select_your_date'.tr,
                            style: textBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge)))),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromRGBO(20, 20, 20, 0.1)),
                    ),
                    child: SfDateRangePicker(
                      headerStyle: DateRangePickerHeaderStyle(
                        backgroundColor: const Color.fromRGBO(255, 239, 203, 1),
                        textAlign: TextAlign.left,
                        textStyle: textMedium.copyWith(
                          color: const Color.fromRGBO(20, 20, 20, 1),
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
                      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
                      confirmText: 'apply'.tr,
                      showActionButtons: false,
                      cancelText: '',
                      onCancel: () => Navigator.pop(context),
                      onSubmit: widget.onChanged,
                      todayHighlightColor: const Color.fromRGBO(0, 0, 0, 0.1),
                      monthCellStyle: DateRangePickerMonthCellStyle(
                        todayTextStyle: textMedium.copyWith(
                          color: const Color.fromRGBO(250, 173, 2, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selectionMode: DateRangePickerSelectionMode.range,
                      rangeSelectionColor:
                          const Color.fromRGBO(255, 239, 203, 0.5),
                      view: DateRangePickerView.month,
                      enableMultiView: true,
                      selectionTextStyle: textMedium.copyWith(
                          color: const Color.fromRGBO(255, 255, 255, 1)),
                      navigationDirection:
                          DateRangePickerNavigationDirection.vertical,
                      startRangeSelectionColor:
                          const Color.fromRGBO(250, 173, 2, 1),
                      endRangeSelectionColor:
                          const Color.fromRGBO(250, 173, 2, 0.6),
                      onSelectionChanged: _onSelectionChanged,
                    ),
                  ),
                ),
                const SizedBox(
                  height: Dimensions.paddingSize,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Card(
                      color: Colors.transparent,
                      elevation: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(250, 173, 2, 1),
                            borderRadius: BorderRadius.circular(100)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                width: Dimensions.iconSizeSmall,
                                child: Image.asset(Images.calenderIcon)),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            Text(
                              rng.length > 1 ? rng[0] : 'select',
                              style: textMedium.copyWith(
                                  color:
                                      const Color.fromRGBO(255, 255, 255, 1)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.transparent,
                      elevation: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(250, 173, 2, 1),
                            borderRadius: BorderRadius.circular(100)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                width: Dimensions.iconSizeSmall,
                                child: Image.asset(Images.calenderIcon)),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            Text(
                              rng.length > 1 ? rng[1] : 'select',
                              style: textMedium.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: Dimensions.paddingSize,
                ),
                ButtonWidget(
                  textColor: const Color.fromRGBO(255, 255, 255, 1),
                  borderColor: const Color.fromRGBO(255, 128, 128, 0.2),
                  backgroundColor: const Color.fromRGBO(250, 173, 2, 1),
                  radius: Dimensions.paddingSizeExtraLarge,
                  onPressed: () {
                    selectedDate = controller.selectedDate;
                    if (kDebugMode) {
                      print(selectedDate);
                    }
                    Get.find<TripController>().updateShowCustomDateState(true);
                    Get.find<TripController>()
                        .setFilterDateRangeValue(start: rng[0], end: rng[1]);
                    Get.back();
                  },
                  buttonText: 'apply'.tr,
                ),
              ],
            ),
            Positioned(
                child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Icon(
                          Icons.clear,
                          size: Dimensions.iconSizeMedium,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .color!
                              .withValues(alpha: .5),
                        ))))
          ],
        ),
      ),
    );
  }
}
