import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/maintainance_mode/maintainance_screen.dart';
import 'package:ride_sharing_user_app/features/onboard/screens/onboarding_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/edit_profile_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/images.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _snackBarGuardTimer;
  bool _showOfflineScreen = false;
  bool _isChecking = false;
  bool _routeStarted = false;

  @override
  void initState() {
    super.initState();

    Get.find<ConfigController>().initSharedData();
    _startSnackBarGuard();

    // Same as driver app: start checking immediately after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearSnackBars();
      _startApplication();
    });
  }

  void _startSnackBarGuard() {
    _snackBarGuardTimer?.cancel();
    _snackBarGuardTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _clearSnackBars(),
    );
  }

  void _clearSnackBars() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..removeCurrentSnackBar();
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }

  void _stopSnackBarGuard() {
    _snackBarGuardTimer?.cancel();
    _snackBarGuardTimer = null;
    _clearSnackBars();
  }

  void _openScreen(Widget screen) {
    _stopSnackBarGuard();
    Get.offAll(() => screen);
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final List<InternetAddress> result =
          await InternetAddress.lookup('seventaxi.in').timeout(
        const Duration(seconds: 5),
      );
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (error) {
      debugPrint('Internet check error: $error');
      return false;
    }
  }

  // Called only after the launch animation is completed and by Try again.
  Future<void> _startApplication() async {
    if (_isChecking || _routeStarted || !mounted) return;

    setState(() {
      _isChecking = true;
    });

    final bool connected = await _hasInternetConnection();
    if (!mounted) return;

    if (!connected) {
      _clearSnackBars();
      setState(() {
        _showOfflineScreen = true;
        _isChecking = false;
      });
      return;
    }

    setState(() {
      _showOfflineScreen = false;
    });

    await _route();
  }

  Future<void> _route() async {
    if (_routeStarted || !mounted) return;
    _routeStarted = true;

    try {
      final bool configLoaded = await Get.find<ConfigController>()
          .getConfigData(reload: false, showError: false)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => false,
          );

      if (!mounted) return;

      if (!configLoaded) {
        _routeStarted = false;
        _clearSnackBars();
        setState(() {
          _showOfflineScreen = true;
          _isChecking = false;
        });
        return;
      }

      unawaited(_loadCancellationReasonsSafely());

      final AuthController authController = Get.find<AuthController>();
      if (authController.getUserToken().isNotEmpty) {
        PusherHelper.initilizePusher();
      }

      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;

      if (authController.isLoggedIn()) {
        final userAddress = Get.find<LocationController>().getUserAddress();
        final bool hasAddress = userAddress?.address?.isNotEmpty == true;

        if (!hasAddress) {
          _openScreen(const AccessLocationScreen());
          return;
        }

        final profileResponse =
            await Get.find<ProfileController>().getProfileInfo();
        if (!mounted) return;

        if (profileResponse.statusCode != 200) {
          _openScreen(const SignInScreen());
          return;
        }

        authController.updateToken();
        final dynamic data = profileResponse.body?['data'];
        final int isProfileVerified = data is Map
            ? int.tryParse(data['is_profile_verified'].toString()) ?? 0
            : 0;

        if (isProfileVerified == 1) {
          authController.remainingFindingRideTime();

          final RideController rideController = Get.find<RideController>();
          await rideController.getCurrentRideStatus(
            fromRefresh: true,
            navigateToMap: false,
          );
          if (!mounted) return;

          final String status =
              rideController.tripDetails?.currentStatus?.toLowerCase() ?? '';

          // Completed rides navigate to Payment inside RideController.
          if (status == AppConstants.completed) {
            return;
          }

          if (status == AppConstants.accepted ||
              status == AppConstants.ongoing ||
              status == AppConstants.pending) {
            _openScreen(
              const MapScreen(fromScreen: MapScreenType.splash),
            );
          } else {
            _openScreen(const DashboardScreen());
          }
        } else {
          _openScreen(const EditProfileScreen(fromLogin: true));
        }
      } else {
        final config = Get.find<ConfigController>().config;
        final maintenanceMode = config?.maintenanceMode;

        if (maintenanceMode?.maintenanceStatus == 1 &&
            maintenanceMode?.selectedMaintenanceSystem?.userApp == 1) {
          _openScreen(const MaintenanceScreen());
        } else if (Get.find<ConfigController>().showIntro()) {
          _openScreen(const OnBoardingScreen());
        } else {
          _openScreen(const SignInScreen());
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Customer splash route error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      _routeStarted = false;
      _clearSnackBars();
      setState(() {
        _showOfflineScreen = true;
        _isChecking = false;
      });
    }
  }

  Future<void> _loadCancellationReasonsSafely() async {
    try {
      await Get.find<TripController>()
          .getOngoingAndAcceptedCancellationCauseList();
    } catch (error) {
      debugPrint('Cancellation reason loading error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _showOfflineScreen
          ? _buildOfflineScreen(context)
          : SevenTaxiSplashAnimation(
              onCompleted: () {},
            ),
    );
  }

  Widget _buildOfflineScreen(BuildContext context) {
    const Color brandRed = Color(0xFFE71921);
    const Color ink = Color(0xFF121A2C);
    const Color muted = Color(0xFF6F7787);
    const Color softRed = Color(0xFFFFECEE);

    final Size screenSize = MediaQuery.sizeOf(context);
    final bool isSmallScreen = screenSize.width < 360;
    final bool isVerySmallScreen = screenSize.height < 650;

    final double horizontalPadding = isSmallScreen ? 16 : 20;
    final double cardPadding = isSmallScreen ? 18 : 22;
    final double iconContainerSize = isSmallScreen ? 72 : 82;
    final double iconSize = isSmallScreen ? 36 : 41;
    final double titleFontSize = isSmallScreen ? 18 : 20;
    final double descriptionFontSize = isSmallScreen ? 12 : 13;
    final double buttonFontSize = isSmallScreen ? 14 : 15;
    final double buttonHeight = isSmallScreen ? 48 : 52;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: isVerySmallScreen ? 16 : 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    constraints.maxHeight - (isVerySmallScreen ? 32 : 48),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 390,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      cardPadding,
                      isSmallScreen ? 24 : 28,
                      cardPadding,
                      isSmallScreen ? 18 : 22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 24 : 28,
                      ),
                      border: Border.all(
                        color: const Color(0xFFF0F1F4),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: iconContainerSize,
                          height: iconContainerSize,
                          decoration: const BoxDecoration(
                            color: softRed,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.wifi_off_rounded,
                            size: iconSize,
                            color: brandRed,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 18 : 22),
                        Text(
                          'No internet connection',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textScaler: const TextScaler.linear(1),
                          style: TextStyle(
                            color: ink,
                            fontSize: titleFontSize,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 10),
                        Text(
                          'Please turn on Wi-Fi or mobile data, then tap the button below.',
                          textAlign: TextAlign.center,
                          textScaler: const TextScaler.linear(1),
                          style: TextStyle(
                            color: muted,
                            fontSize: descriptionFontSize,
                            height: 1.45,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 22 : 26),
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: FilledButton.icon(
                            onPressed: _isChecking ? null : _startApplication,
                            style: FilledButton.styleFrom(
                              backgroundColor: brandRed,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFFFA6AA),
                              disabledForegroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  isSmallScreen ? 14 : 16,
                                ),
                              ),
                            ),
                            icon: _isChecking
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.refresh_rounded,
                                    size: 20,
                                  ),
                            label: Text(
                              _isChecking ? 'Checking...' : 'Try again',
                              textScaler: const TextScaler.linear(1),
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _snackBarGuardTimer?.cancel();
    super.dispose();
  }
}

class SevenTaxiSplashAnimation extends StatefulWidget {
  final VoidCallback onCompleted;

  const SevenTaxiSplashAnimation({super.key, required this.onCompleted});

  @override
  State<SevenTaxiSplashAnimation> createState() =>
      _SevenTaxiSplashAnimationState();
}

class _SevenTaxiSplashAnimationState extends State<SevenTaxiSplashAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _cloudCtrl;
  late final AnimationController _contentCtrl;
  late final Animation<Offset> _contentSlide;
  late final AnimationController _greenPinCtrl;
  late final Animation<double> _greenPinScale;
  late final AnimationController _redPinCtrl;
  late final Animation<double> _redPinScale;
  late final AnimationController _taxiCtrl;
  late final Animation<double> _taxiProgress;
  late final AnimationController _redRevealCtrl;
  late final Animation<double> _redReveal;

  bool _revealStarted = false;

  Offset _rippleOrigin = const Offset(0, 0);
  double _taxiX = -65.0;

  static const double _taxiWidth = 65.0;
  static const double _taxiHeight = 32.0;

  static const double _bannerHeight = 100.0;
  static const double _iconGrpHeight = 105.0;
  static const double _bannerCenterFraction = 0.44;

  @override
  void initState() {
    super.initState();

    _cloudCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 15))
          ..repeat();

    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _contentSlide =
        Tween<Offset>(begin: const Offset(-3.0, 0), end: Offset.zero).animate(
            CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));

    _greenPinCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 6));
    _greenPinScale = Tween<double>(begin: 1, end: 0.5).animate(
        CurvedAnimation(parent: _greenPinCtrl, curve: Curves.easeInOut));

    _redPinCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 6));
    _redPinScale = Tween<double>(begin: 0.5, end: 1)
        .animate(CurvedAnimation(parent: _redPinCtrl, curve: Curves.easeInOut));

    _taxiCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _taxiProgress = CurvedAnimation(parent: _taxiCtrl, curve: Curves.linear);

    _redRevealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _redReveal = CurvedAnimation(
      parent: _redRevealCtrl,
      curve: Curves.easeInCubic,
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _contentCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _greenPinCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _redPinCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _taxiCtrl.forward();
  }

  void _triggerReveal() async {
    if (!mounted) return;

    final screenHeight = MediaQuery.of(context).size.height;

    setState(() {
      _rippleOrigin = Offset(
        _taxiX + (_taxiWidth * 0.45),
        screenHeight - (_taxiHeight * 1.2),
      );
    });

    bool navigated = false;
    void maybeNavigate() {
      if (!navigated && _redRevealCtrl.value >= 0.3) {
        navigated = true;
        widget.onCompleted();
      }
    }

    _redRevealCtrl.addListener(maybeNavigate);
    await _redRevealCtrl.forward();
    maybeNavigate();
  }

  @override
  void dispose() {
    _cloudCtrl.dispose();
    _contentCtrl.dispose();
    _greenPinCtrl.dispose();
    _redPinCtrl.dispose();
    _taxiCtrl.dispose();
    _redRevealCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double bannerCenterY = size.height * _bannerCenterFraction;
    final double bannerTop = bannerCenterY - _bannerHeight / 2;
    final double iconGrpTop = bannerCenterY - _iconGrpHeight / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          _buildCloud(size,
              topFraction: 0.08, startFraction: -0.15, width: 110),
          _buildCloud(size, topFraction: 0.09, startFraction: 0.55, width: 85),
          _buildCloud(size, topFraction: 0.17, startFraction: 0.18, width: 95),
          _buildCloud(size, topFraction: 0.18, startFraction: 0.72, width: 75),
          _buildCloud(size, topFraction: 0.25, startFraction: -0.05, width: 80),
          _buildCloud(size, topFraction: 0.26, startFraction: 0.45, width: 90),
          Positioned(
            bottom: 0,
            left: 10,
            right: 10,
            child:
                Image.asset(Images.splashScreenBuilding, fit: BoxFit.fitWidth),
          ),
          Positioned(
            left: 20,
            bottom: 120,
            child: ScaleTransition(
              scale: _greenPinScale,
              alignment: Alignment.bottomCenter,
              child: Image.asset(Images.splashScreenPinTwo, width: 35),
            ),
          ),
          Positioned(
            right: 70,
            bottom: 145,
            child: ScaleTransition(
              scale: _redPinScale,
              alignment: Alignment.bottomCenter,
              child: Image.asset(Images.splashScreenPinOne, width: 35),
            ),
          ),
          Positioned(
            top: bannerTop,
            left: 108,
            right: 0,
            child: SizedBox(
              height: _bannerHeight,
              child: Image.asset(Images.splashScreenSevenTaxiBanner,
                  fit: BoxFit.fill),
            ),
          ),
          Positioned(
            top: iconGrpTop,
            left: -2,
            child: SlideTransition(
              position: _contentSlide,
              child: Image.asset(Images.splashScreenIconGrp,
                  height: _iconGrpHeight),
            ),
          ),
          AnimatedBuilder(
            animation: _taxiProgress,
            builder: (_, child) {
              _taxiX = -65.0 + (size.width + 130) * _taxiProgress.value;
              if (!_revealStarted && (_taxiX + _taxiWidth) >= size.width) {
                _revealStarted = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _triggerReveal();
                });
              }
              return Positioned(
                bottom: 0,
                left: _taxiX,
                child: child!,
              );
            },
            child: Image.asset(
              Images.splashScreenCar,
              width: _taxiWidth,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _redReveal,
                builder: (context, _) {
                  return CustomPaint(
                    painter: TaxiRippleReveal(
                      progress: _redReveal.value,
                      origin: _rippleOrigin,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloud(Size size,
      {required double topFraction,
      required double startFraction,
      required double width}) {
    return AnimatedBuilder(
      animation: _cloudCtrl,
      builder: (_, __) {
        double x = size.width * startFraction + size.width * _cloudCtrl.value;
        x = x % (size.width + width);
        if (x > size.width) x -= (size.width + width);
        return Positioned(
          top: size.height * topFraction,
          left: x,
          child: Image.asset(Images.splashScreenCloud,
              width: width, colorBlendMode: BlendMode.modulate),
        );
      },
    );
  }
}

class TaxiRippleReveal extends CustomPainter {
  final double progress;
  final Offset origin;

  TaxiRippleReveal({
    required this.progress,
    required this.origin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.red.withValues(alpha: progress * 0.25),
    );
  }

  @override
  bool shouldRepaint(covariant TaxiRippleReveal oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.origin != origin;
  }
}
