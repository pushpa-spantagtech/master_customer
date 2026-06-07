import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/maintainance_mode/maintainance_screen.dart';
import 'package:ride_sharing_user_app/features/onboard/screens/onboarding_screen.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/edit_profile_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();

    if (!GetPlatform.isIOS) {
      _checkConnectivity();
    }

    Get.find<TripController>().getOngoingAndAcceptedCancellationCauseList();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.repeat(max: 1);
    _controller.forward();

    Get.find<ConfigController>().initSharedData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkConnectivity() {
    bool isFirst = true;
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);
      if ((isFirst && !isConnected) || !isFirst && context.mounted) {
        ScaffoldMessenger.of(Get.context!).removeCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(
            isConnected ? 'connected'.tr : 'no_connection'.tr,
            textAlign: TextAlign.center,
          ),
        ));
        if (isConnected) {
          _route();
        }
      }
      isFirst = false;
    });
  }

  void _route() async {
    await Get.find<ConfigController>().getConfigData().then((value) {
      if (value) {
        if (Get.find<AuthController>().getUserToken().isNotEmpty) {
          PusherHelper.initilizePusher();
        }
        Future.delayed(const Duration(milliseconds: 100), () {
          if (Get.find<AuthController>().isLoggedIn()) {
            if (Get.find<LocationController>().getUserAddress() != null &&
                Get.find<LocationController>().getUserAddress()!.address !=
                    null &&
                Get.find<LocationController>()
                    .getUserAddress()!
                    .address!
                    .isNotEmpty) {
              Get.find<ProfileController>().getProfileInfo().then((value) {
                if (value.statusCode == 200) {
                  Get.find<AuthController>().updateToken();
                  if (value.body['data']['is_profile_verified'] == 1) {
                    Get.find<AuthController>().remainingFindingRideTime();
                    Get.offAll(() => const DashboardScreen());
                  } else {
                    Get.offAll(() => const EditProfileScreen(fromLogin: true));
                  }
                }
              });
            } else {
              Get.offAll(() => const AccessLocationScreen());
            }
          } else {
            if (Get.find<ConfigController>().config!.maintenanceMode != null &&
                Get.find<ConfigController>()
                        .config!
                        .maintenanceMode!
                        .maintenanceStatus ==
                    1 &&
                Get.find<ConfigController>()
                        .config!
                        .maintenanceMode!
                        .selectedMaintenanceSystem!
                        .userApp ==
                    1) {
              Get.offAll(() => const MaintenanceScreen());
            } else {
              if (Get.find<ConfigController>().showIntro()) {
                Get.offAll(() => const OnBoardingScreen());
              } else {
                Get.offAll(() => const SignInScreen());
              }
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SevenTaxiSplashAnimation(
        onCompleted: _route,
      ),
    );
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
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _taxiProgress = CurvedAnimation(parent: _taxiCtrl, curve: Curves.linear);

    _redRevealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
      if (!navigated && _redRevealCtrl.value >= 0.92) {
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
            left: 0,
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
