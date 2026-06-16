import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';

class LocalRideBottomSheet {
  static void show() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.black54,
                ),
              ),
            ),
            const Icon(
              Icons.info_outline,
              size: 40,
              color: Colors.orange,
            ),
            const SizedBox(height: 15),
            const Text(
              'This destination falls within our local service area. Please book a Local Ride instead of Outstation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            ButtonWidget(
              textColor: Colors.white,
              borderColor: const Color.fromRGBO(255, 128, 128, 0.2),
              backgroundColor: const Color.fromRGBO(250, 173, 2, 1),
              fontSize: 18,
              buttonText: 'Continue with Local Ride'.tr,
              onPressed: () {
                Get.back();
                Get.offAll(() => const DashboardScreen());
              },
              radius: 5,
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
