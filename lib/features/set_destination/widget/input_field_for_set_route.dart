import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode node;
  final String? hint;
  final bool showSuffix;

  const InputField({
    super.key,
    required this.controller,
    required this.node,
    this.hint,
    this.showSuffix = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autocorrect: false,
      enableSuggestions: false,
      spellCheckConfiguration: null,
      controller: controller,
      style: textMedium.copyWith(
          fontSize: Dimensions.fontSizeLarge,
          color: const Color.fromRGBO(20, 20, 20, 0.8)),
      focusNode: node,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        fillColor: Get.isDarkMode ? Theme.of(context).cardColor : null,
        filled: Get.isDarkMode,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
            vertical: Dimensions.paddingSizeSmall),
        hintText: hint ?? 'Enter Route',
        suffixIcon: showSuffix
            ? const Icon(Icons.place_outlined,
                color: Color.fromRGBO(20, 20, 20, 0.7))
            : null,
        hintStyle: textMedium.copyWith(
            color: const Color.fromRGBO(20, 20, 20, 0.36),
            fontSize: Dimensions.fontSizeSmall),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: Color.fromRGBO(0, 0, 0, 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: Color.fromRGBO(0, 0, 0, 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: Color.fromRGBO(0, 0, 0, 0.1),
          ),
        ),
      ),
      cursorColor: const Color.fromRGBO(250, 173, 2, 1),
    );
  }
}
