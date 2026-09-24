import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

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
import 'package:ride_sharing_user_app/util/dimensions.dart';

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
    // Advance Flutter's fake frame/timer clock while allowing raster work
    // to finish on the engine's real asynchronous clock.
    for (var attempt = 0; attempt < 100 && !saved.isCompleted; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
    }
    expect(saved.isCompleted, isTrue);
    await tester.runAsync(() async {
      final call = await saved.future.timeout(const Duration(seconds: 20));
      expect(calls, ['prepare', 'save']);
      expect(call.arguments['refId'], 'REF-123');
      final codec =
          await ui.instantiateImageCodec(call.arguments['image'] as Uint8List);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, (400 - 2 * Dimensions.paddingSizeDefault) * 2);
      // The exported receipt must include content outside the 600px viewport.
      expect(frame.image.height, greaterThan(1200));
      final pixels = (await frame.image.toByteData())!;
      var darkPixelsBelowViewport = 0;
      for (var offset = 1200 * frame.image.width * 4;
          offset < pixels.lengthInBytes;
          offset += 4) {
        if (pixels.getUint8(offset) < 150 &&
            pixels.getUint8(offset + 1) < 150 &&
            pixels.getUint8(offset + 2) < 150 &&
            pixels.getUint8(offset + 3) > 200) {
          darkPixelsBelowViewport++;
        }
      }
      expect(darkPixelsBelowViewport, greaterThan(0));
      frame.image.dispose();
      codec.dispose();
    });
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
