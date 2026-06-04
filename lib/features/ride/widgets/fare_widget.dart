import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class FareWidget extends StatelessWidget {
  final String title;
  final String value;
  const FareWidget({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(value,
          style: textBold.copyWith(
              color: const Color.fromRGBO(20, 20, 20, 0.7),
              fontSize: Dimensions.fontSizeLarge)),
      const SizedBox(height: Dimensions.paddingSizeThree),
      Text(title,
          style: textRegular.copyWith(
              color: const Color.fromRGBO(20, 20, 20, 0.7),
              fontSize: Dimensions.fontSizeDefault)),
    ]);
  }
}
