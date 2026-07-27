import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/domain/models/error_response.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';

class ApiChecker {
  static void checkApi(Response response) {
    final String message =
        response.body is Map && response.body['message'] != null
            ? response.body['message'].toString()
            : (response.statusText ?? 'Something went wrong');

    if (response.statusCode == 401) {
      Get.find<ConfigController>().removeSharedData();
      Get.offAll(() => const SignInScreen());
      showCustomSnackBar(message);
    } else if (response.statusCode == 403 || response.statusCode == 422) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(response.body);
      if (errorResponse.errors != null && errorResponse.errors!.isNotEmpty) {
        showCustomSnackBar(errorResponse.errors![0].message!);
      } else {
        showCustomSnackBar(message);
      }
    } else if (response.statusCode == 404) {
      showCustomSnackBar(message);
    } else if (response.statusCode == 500) {
      showCustomSnackBar(message);
    } else {
      showCustomSnackBar(message);
    }
  }
}
