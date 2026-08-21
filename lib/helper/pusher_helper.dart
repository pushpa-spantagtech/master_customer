import 'dart:convert';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/payment/screens/review_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

class PusherHelper {
  static PusherChannelsClient? pusherClient;

  late PrivateChannel pusherDriverAccepted;
  late PrivateChannel driverTripStarted;
  late PrivateChannel driverTripCancelled;
  late PrivateChannel driverTripCompleted;
  late PrivateChannel driverPaymentReceived;

  /*
   * ------------------------------------------------------------
   * Initialize Pusher
   * ------------------------------------------------------------
   */
  static Future<void> initilizePusher() async {
    try {
      final PusherChannelsOptions options = PusherChannelsOptions.fromHost(
        host: Get.find<ConfigController>().config!.webSocketUrl ?? '',
        scheme: 'ws',
        key: AppConstants.appKey,
        port: int.parse(
          Get.find<ConfigController>().config?.webSocketPort ?? '6001',
        ),
      );

      pusherClient = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (
          exception,
          trace,
          refresh,
        ) async {
          debugPrint(
            'PUSHER CONNECTION ERROR: $exception',
          );

          Get.find<ConfigController>().setPusherStatus('Disconnected');

          refresh();
        },
      );

      await pusherClient?.connect();

      final String? socketId =
          pusherClient?.channelsManager.channelsConnectionDelegate.socketId;

      if (socketId != null && socketId.isNotEmpty) {
        debugPrint(
          'PUSHER CONNECTED: $socketId',
        );

        Get.find<ConfigController>().setPusherStatus('Connected');
      } else {
        debugPrint(
          'PUSHER SOCKET ID NOT AVAILABLE',
        );

        Get.find<ConfigController>().setPusherStatus('Disconnected');
      }
    } catch (e) {
      debugPrint(
        'PUSHER INITIALIZATION ERROR: $e',
      );

      Get.find<ConfigController>().setPusherStatus('Disconnected');
    }
  }

  /*
   * ------------------------------------------------------------
   * Subscribe to all events for current trip
   * ------------------------------------------------------------
   */
  void pusherDriverStatus(String tripId) {
    if (pusherClient == null ||
        Get.find<ConfigController>().pusherConnectionStatus != 'Connected') {
      debugPrint(
        'PUSHER NOT CONNECTED - '
        'status: ${Get.find<ConfigController>().pusherConnectionStatus}',
      );

      return;
    }

    _subscribeDriverAccepted(tripId);
    _subscribeTripStarted(tripId);
    _subscribeTripCancelled(tripId);
    _subscribeTripCompleted(tripId);
    _subscribePaymentReceived(tripId);
  }

  /*
   * ------------------------------------------------------------
   * DRIVER ACCEPTED
   * ------------------------------------------------------------
   */
  void _subscribeDriverAccepted(String tripId) {
    pusherDriverAccepted = pusherClient!.privateChannel(
      "private-driver-trip-accepted.$tripId",
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate
              .forPrivateChannel(
        authorizationEndpoint: Uri.parse(
          'https://${Get.find<ConfigController>().config!.webSocketUrl}/broadcasting/auth',
        ),
        headers: {
          "Accept": "application/json",
          "Authorization":
              "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "PUT, GET, POST, DELETE, OPTIONS",
        },
      ),
    );

    if (pusherDriverAccepted.currentStatus != null) {
      return;
    }

    pusherDriverAccepted.subscribe();

    pusherDriverAccepted
        .bind("driver-trip-accepted.$tripId")
        .listen((event) async {
      try {
        if (event.data == null) {
          return;
        }

        final dynamic data = jsonDecode(event.data!);

        final String eventTripId = data['id']?.toString() ?? '';

        final String type = data['type']?.toString() ?? '';

        if (eventTripId.isEmpty) {
          return;
        }

        debugPrint(
          'PUSHER DRIVER ACCEPTED: $eventTripId',
        );

        if (Get.isDialogOpen == true) {
          Get.back();
        }

        final response =
            await Get.find<RideController>().getRideDetails(eventTripId);

        if (response.statusCode != 200) {
          return;
        }

        if (type == 'parcel') {
          Get.find<ParcelController>().updateParcelState(
            ParcelDeliveryState.acceptRider,
          );

          Get.find<RideController>().startLocationRecord();

          Get.find<MapController>().notifyMapController();

          if (Get.currentRoute != '/MapScreen') {
            Get.to(
              () => const MapScreen(
                fromScreen: MapScreenType.parcel,
              ),
            );
          }

          return;
        }

        Get.find<RideController>().updateRideCurrentState(
          RideState.acceptingRider,
        );

        Get.find<RideController>().startLocationRecord();

        Get.find<MapController>().notifyMapController();

        if (Get.currentRoute != '/MapScreen') {
          Get.to(
            () => const MapScreen(
              fromScreen: MapScreenType.splash,
            ),
          );
        }
      } catch (e) {
        debugPrint(
          'DRIVER ACCEPTED EVENT ERROR: $e',
        );
      }
    });
  }

  /*
   * ------------------------------------------------------------
   * TRIP STARTED
   * ------------------------------------------------------------
   */
  void _subscribeTripStarted(String tripId) {
    driverTripStarted = pusherClient!.privateChannel(
      "private-driver-trip-started.$tripId",
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate
              .forPrivateChannel(
        authorizationEndpoint: Uri.parse(
          'https://${Get.find<ConfigController>().config!.webSocketUrl}/broadcasting/auth',
        ),
        headers: {
          "Accept": "application/json",
          "Authorization":
              "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "PUT, GET, POST, DELETE, OPTIONS",
        },
      ),
    );

    if (driverTripStarted.currentStatus != null) {
      return;
    }

    driverTripStarted.subscribe();

    driverTripStarted.bind("driver-trip-started.$tripId").listen((event) async {
      try {
        if (event.data == null) {
          return;
        }

        final dynamic data = jsonDecode(event.data!);

        final String eventTripId = data['id']?.toString() ?? '';

        final String type = data['type']?.toString() ?? '';

        if (eventTripId.isEmpty) {
          return;
        }

        debugPrint(
          'PUSHER TRIP STARTED: $eventTripId',
        );

        Get.find<RideController>().startLocationRecord();

        /*
         * Parcel
         */
        if (type == 'parcel') {
          await Get.find<MapController>().getPolyline();

          Get.find<ParcelController>().updateParcelState(
            ParcelDeliveryState.parcelOngoing,
          );

          if (Get.find<RideController>().tripDetails == null) {
            await Get.find<RideController>().getRideDetails(eventTripId);
          }

          final parcelInformation =
              Get.find<RideController>().tripDetails?.parcelInformation;

          if (parcelInformation?.payer == 'sender') {
            final response =
                await Get.find<RideController>().getFinalFare(eventTripId);

            if (response.statusCode == 200) {
              Get.find<MapController>().notifyMapController();

              if (Get.currentRoute != '/PaymentScreen') {
                Get.off(
                  () => const PaymentScreen(
                    fromParcel: true,
                  ),
                );
              }
            }
          }

          return;
        }

        /*
         * Normal ride
         */
        Get.find<RideController>().updateRideCurrentState(
          RideState.ongoingRide,
        );

        Get.find<MapController>().notifyMapController();

        if (Get.currentRoute != '/MapScreen') {
          Get.to(
            () => const MapScreen(
              fromScreen: MapScreenType.splash,
            ),
          );
        }
      } catch (e) {
        debugPrint(
          'TRIP STARTED EVENT ERROR: $e',
        );
      }
    });
  }

  /*
   * ------------------------------------------------------------
   * TRIP CANCELLED
   * ------------------------------------------------------------
   */
  void _subscribeTripCancelled(String tripId) {
    driverTripCancelled = pusherClient!.privateChannel(
      "private-driver-trip-cancelled.$tripId",
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate
              .forPrivateChannel(
        authorizationEndpoint: Uri.parse(
          'https://${Get.find<ConfigController>().config!.webSocketUrl}/broadcasting/auth',
        ),
        headers: {
          "Accept": "application/json",
          "Authorization":
              "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "PUT, GET, POST, DELETE, OPTIONS",
        },
      ),
    );

    if (driverTripCancelled.currentStatus != null) {
      return;
    }

    driverTripCancelled.subscribe();

    driverTripCancelled
        .bind("driver-trip-cancelled.$tripId")
        .listen((event) async {
      try {
        debugPrint(
          'PUSHER TRIP CANCELLED: ${event.data}',
        );

        Get.find<RideController>().stopLocationRecord();

        /*
         * Refresh backend status so local ride
         * information is no longer stale.
         */
        await Get.find<RideController>().getCurrentRideStatus(
          navigateToMap: false,
          fromRefresh: true,
        );

        Get.offAll(
          () => const DashboardScreen(),
        );
      } catch (e) {
        debugPrint(
          'TRIP CANCELLED EVENT ERROR: $e',
        );
      }
    });
  }

  /*
   * ------------------------------------------------------------
   * TRIP COMPLETED
   *
   * IMPORTANT CUSTOMER FIX
   * ------------------------------------------------------------
   */
  void _subscribeTripCompleted(String tripId) {
    driverTripCompleted = pusherClient!.privateChannel(
      "private-driver-trip-completed.$tripId",
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate
              .forPrivateChannel(
        authorizationEndpoint: Uri.parse(
          'https://${Get.find<ConfigController>().config!.webSocketUrl}/broadcasting/auth',
        ),
        headers: {
          "Accept": "application/json",
          "Authorization":
              "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "PUT, GET, POST, DELETE, OPTIONS",
        },
      ),
    );

    if (driverTripCompleted.currentStatus != null) {
      return;
    }

    driverTripCompleted.subscribe();

    driverTripCompleted
        .bind("driver-trip-completed.$tripId")
        .listen((event) async {
      try {
        debugPrint(
          'PUSHER DRIVER TRIP COMPLETED: ${event.data}',
        );

        if (event.data == null) {
          return;
        }

        final dynamic data = jsonDecode(event.data!);

        final String completedTripId = data['id']?.toString() ?? '';

        final String type = data['type']?.toString() ?? '';

        if (completedTripId.isEmpty) {
          return;
        }

        /*
         * Immediately stop ongoing polling.
         */
        Get.find<RideController>().stopLocationRecord();

        /*
         * Parcel flow
         */
        if (type == 'parcel') {
          Get.find<RideController>().clearRideDetails();

          if (Get.find<ConfigController>().config!.reviewStatus!) {
            Get.off(
              () => ReviewScreen(
                tripId: completedTripId,
              ),
            );
          } else {
            Get.offAll(
              () => const DashboardScreen(),
            );
          }

          return;
        }

        /*
         * NORMAL RIDE
         *
         * Do not depend on locally cached status.
         *
         * Ask backend for current ride again.
         *
         * RideController.getCurrentRideStatus()
         * handles:
         *
         * completed + unpaid
         *        ↓
         * final fare
         *        ↓
         * PaymentScreen
         */
        await Get.find<RideController>().getCurrentRideStatus(
          navigateToMap: false,
          fromRefresh: true,
        );
      } catch (e) {
        debugPrint(
          'PUSHER COMPLETED EVENT ERROR: $e',
        );

        /*
         * Do not force navigation back to the
         * ongoing screen.
         *
         * RideController polling/API refresh
         * remains the fallback.
         */
      }
    });
  }

  /*
   * ------------------------------------------------------------
   * PAYMENT RECEIVED
   * ------------------------------------------------------------
   */
  void _subscribePaymentReceived(String tripId) {
    driverPaymentReceived = pusherClient!.privateChannel(
      "private-driver-payment-received.$tripId",
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate
              .forPrivateChannel(
        authorizationEndpoint: Uri.parse(
          'https://${Get.find<ConfigController>().config!.webSocketUrl}/broadcasting/auth',
        ),
        headers: {
          "Accept": "application/json",
          "Authorization":
              "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "PUT, GET, POST, DELETE, OPTIONS",
        },
      ),
    );

    if (driverPaymentReceived.currentStatus != null) {
      return;
    }

    driverPaymentReceived.subscribe();

    driverPaymentReceived
        .bind("driver-payment-received.$tripId")
        .listen((event) {
      try {
        if (event.data == null) {
          return;
        }

        final dynamic data = jsonDecode(event.data!);

        final String eventTripId = data['id']?.toString() ?? '';

        final String type = data['type']?.toString() ?? '';

        debugPrint(
          'PUSHER PAYMENT RECEIVED: $eventTripId',
        );

        Get.find<RideController>().stopLocationRecord();

        if (Get.find<ConfigController>().config!.reviewStatus! &&
            type == 'ride_request') {
          Get.find<RideController>().tripDetails = null;

          Get.off(
            () => ReviewScreen(
              tripId: eventTripId,
            ),
          );
        } else {
          Get.find<RideController>().tripDetails = null;

          Get.offAll(
            () => const DashboardScreen(),
          );
        }
      } catch (e) {
        debugPrint(
          'PAYMENT RECEIVED EVENT ERROR: $e',
        );
      }
    });
  }

/*
   * ------------------------------------------------------------
   * Common private channel authorization
   * ------------------------------------------------------------
   */
}
