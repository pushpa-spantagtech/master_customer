import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/services/ride_service_interface.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/splash/domain/models/config_model.dart';
import 'package:ride_sharing_user_app/features/splash/domain/services/config_service_interface.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/trip/domain/services/service_interface.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/features/trip/helpers/trip_pdf_data.dart';

class _RideService implements RideServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TripService implements TripServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ConfigService implements ConfigServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ConfigController extends ConfigController {
  _ConfigController() : super(configServiceInterface: _ConfigService());

  @override
  ConfigModel get config => ConfigModel(
        currencyDecimalPoint: '2',
        currencySymbol: 'Rs',
        reviewStatus: false,
      );
}

void main() {
  const channel = MethodChannel('com.seventaxi.customer/trip_pdf');
  late Map<String, String> translations;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final loader = FontLoader('SFProText');
    for (final weight in ['regular', 'medium', 'semibold', 'bold']) {
      loader.addFont(rootBundle.load('assets/font/sf-pro-text-$weight.ttf'));
    }
    await loader.load();
    translations = Map<String, String>.from(
      jsonDecode(await rootBundle.loadString('assets/language/en.json')) as Map,
    );
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    Get.reset();
  });

  test('Document retains long addresses, every stop and driver/vehicle details',
      () {
    Get.put<ConfigController>(_ConfigController());
    final address = List.filled(100, 'Long street address').join(' ');
    final rows = TripPdfData.rows(TripDetails(
      pickupAddress: address,
      intermediateAddresses: '["First stop", "Second stop", "Third stop"]',
      entrance: 'Side gate',
      driver: Driver(firstName: 'Test', lastName: 'Driver'),
      driverAvgRating: '4.8',
      vehicle: Vehicle(
          model: Model(name: 'Sedan'), licencePlateNumber: 'TN 01 AB 1234'),
    ));
    final values = {for (final row in rows) row['label']: row['value']};
    expect(values['Pickup'], address);
    expect(values['Stop 3'], 'Third stop');
    expect(values['Entrance'], 'Side gate');
    expect(values['Driver'], 'Test Driver');
    expect(values['Rating'], '4.8');
    expect(values['Vehicle'], 'Sedan');
    expect(values['Registration number'], 'TN 01 AB 1234');
  });

  Future<void> showScreen(WidgetTester tester, {TripDetails? trip}) async {
    Get.testMode = true;
    Get.addTranslations({'en_US': translations});
    Get.put(RideController(rideServiceInterface: _RideService())).tripDetails =
        trip;
    Get.put(TripController(tripServiceInterface: _TripService()));
    Get.put<ConfigController>(_ConfigController());
    await tester.pumpWidget(const GetMaterialApp(
      locale: Locale('en', 'US'),
      home: TripDetailsScreen(tripId: 'trip-id', fromNotification: true),
    ));
    await tester.pump();
  }

  testWidgets('Download is disabled while trip data is loading',
      (tester) async {
    await showScreen(tester);
    final button = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.download_rounded));
    expect(button.onPressed, isNull);
  });

  testWidgets('Exports full trip content and refId after storage preparation',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final saved = Completer<MethodCall>();
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (call.method == 'save') {
        saved.complete(call);
        return 'REF-123.pdf';
      }
      return null;
    });
    await showScreen(tester,
        trip: TripDetails(
          id: 'trip-id',
          refId: 'REF-123',
          type: 'parcel',
          pickupAddress: 'Pickup address',
          destinationAddress: 'Destination address',
          actualDistance: '10',
          paymentMethod: 'cash',
          currentStatus: 'completed',
          paidFare: 200,
          createdAt: '2026-09-24 10:00:00',
        ));
    await tester.tap(find.byTooltip('Download PDF'));
    await tester.pumpAndSettle();
    expect(saved.isCompleted, isTrue);
    final call = await saved.future;
    expect(calls, ['prepare', 'save']);
    expect(call.arguments['refId'], 'REF-123');
    expect(call.arguments.containsKey('image'), isFalse);
    expect(call.arguments.containsKey('header'), isFalse);
    final rows = (call.arguments['rows'] as List).cast<Map>();
    final values = {
      for (final row in rows)
        if (row.containsKey('label')) row['label']: row['value']
    };
    expect(values['Pickup'], 'Pickup address');
    expect(values['Destination'], 'Destination address');
    expect(values[translations['total_distance']], '10 km');
    expect(values[translations['sub_total']], 'Rs 200.00');
    for (final key in [
      'fare_price',
      'idle_price',
      'delay_price',
      'cancellation_price',
      'coupon',
      'discount',
      'tips',
      'vat_tax',
      'payment'
    ]) {
      expect(values.containsKey(translations[key]), isTrue, reason: key);
    }
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
        tester
            .widget<IconButton>(
                find.widgetWithIcon(IconButton, Icons.download_rounded))
            .onPressed,
        isNotNull);
  });
}
