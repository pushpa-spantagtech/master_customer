import 'dart:convert';

import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';

/// Document data independent of the screen's size, scrolling and image loading.
class TripPdfData {
  static List<Map<String, String>> rows(TripDetails trip) {
    final rows = <Map<String, String>>[];
    void section(String title) => rows.add({'section': title});
    void row(String label, String? value, {bool total = false}) => rows.add({
          'label': label,
          'value': value == null || value.trim().isEmpty || value == 'null'
              ? '—'
              : value,
          if (total) 'total': 'true',
        });
    void money(String label, double? value,
            {bool discount = false, bool total = false}) =>
        row(label.tr,
            '${discount ? '-' : ''}${PriceConverter.convertPrice(value ?? 0)}',
            total: total);

    section('trip_details'.tr);
    final date = DateTime.tryParse(trip.createdAt ?? '');
    row('Date',
        date == null ? trip.createdAt : DateConverter.localToIsoString(date));
    row('Status', trip.currentStatus?.tr);
    row('Service',
        trip.type == 'parcel' ? 'parcel'.tr : trip.vehicleCategory?.name);
    row('Pickup', trip.pickupAddress);
    final stops = trip.intermediateAddresses;
    if (stops != null && stops.isNotEmpty && stops != '[[, ]]') {
      try {
        final decoded = jsonDecode(stops);
        if (decoded is List) {
          for (var i = 0; i < decoded.length; i++) {
            row('Stop ${i + 1}', decoded[i]?.toString());
          }
        } else {
          row('Intermediate stops', stops);
        }
      } on FormatException {
        row('Intermediate stops', stops);
      }
    }
    row('Destination', trip.destinationAddress);
    if (trip.entrance?.isNotEmpty ?? false) row('Entrance', trip.entrance);
    row('total_distance'.tr,
        trip.actualDistance == null ? null : '${trip.actualDistance} km');

    section('Fare breakdown');
    money('fare_price', trip.distanceWiseFare);
    money('idle_price', trip.idleFee);
    money('delay_price', trip.delayFee);
    money('cancellation_price', trip.cancellationFee);
    money('coupon', trip.couponAmount, discount: true);
    money('discount', trip.discountAmount, discount: true);
    money('tips', trip.tips);
    money('vat_tax', trip.vatTax);
    money('sub_total', trip.paidFare, total: true);
    row('payment'.tr, trip.paymentMethod?.tr);
    row('Payment status', trip.paymentStatus?.tr);

    if (trip.driver != null ||
        trip.vehicle != null ||
        trip.vehicleCategory != null) {
      section('rider_details'.tr);
      rows.add({
        'photos': 'true',
        if (trip.driver != null) 'driver': 'Driver photo',
        if (trip.vehicle != null || trip.vehicleCategory != null)
          'vehicle': 'Vehicle photo',
      });
    }
    if (trip.driver != null) {
      row(
          'Driver',
          [trip.driver!.firstName, trip.driver!.lastName]
              .whereType<String>()
              .where((name) => name.isNotEmpty)
              .join(' '));
      row(
          'Rating',
          (double.tryParse(trip.driverAvgRating ?? '') ?? 0)
              .toStringAsFixed(1));
    }
    if (trip.vehicle != null) {
      row('Vehicle', trip.vehicle!.model?.name);
      row('Registration number', trip.vehicle!.licencePlateNumber);
    }
    return rows;
  }
}
