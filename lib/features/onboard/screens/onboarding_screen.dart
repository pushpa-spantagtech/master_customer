import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/onboard/controllers/on_board_page_controller.dart';
import 'package:ride_sharing_user_app/features/onboard/widget/pager_content.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: Colors.red,
        toolbarHeight: 14,
        automaticallyImplyLeading: false,
      ),
      body: GetBuilder<OnBoardController>(
        builder: (onBoardController) {
          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  onPageChanged: (value) {
                    onBoardController.onPageChanged(value);
                  },
                  itemCount: AppConstants.onBoardPagerData.length,
                  itemBuilder: (context, index) => PagerContent(
                    image: AppConstants
                        .onBoardPagerData[onBoardController.pageIndex].image,
                    text: AppConstants
                        .onBoardPagerData[onBoardController.pageIndex].title,
                    index: index,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: Dimensions.paddingSizeExtraLarge + 1,
                    right: Dimensions.paddingSizeExtraLarge + 1,
                    bottom: Dimensions.paddingSizeLarge),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        AppConstants.onBoardPagerData.length,
                        (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width:
                                onBoardController.pageIndex == index ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 0, 0, 1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          );
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (onBoardController.pageIndex ==
                            AppConstants.onBoardPagerData.length - 1) {
                          Get.find<ConfigController>().disableIntro();
                          Get.offAll(() => const SignInScreen());
                        } else {
                          onBoardController.onPageIncrement();
                        }
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(255, 0, 0, 1),
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox(
                          height: 16,
                          width: 10,
                          child: Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: Color.fromRGBO(255, 255, 255, 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
