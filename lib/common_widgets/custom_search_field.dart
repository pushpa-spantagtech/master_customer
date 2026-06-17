import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CustomSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool fillColor;
  final Function(String) onChanged;
  final FocusNode? focusNode;
  final bool isReadOnly;
  final VoidCallback onTap;

  const CustomSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.fillColor = false,
    this.focusNode,
    required this.isReadOnly,
    required this.onTap,
  });

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            readOnly: widget.isReadOnly,
            cursorColor: const Color.fromRGBO(250, 173, 2, 1),
            textInputAction: TextInputAction.search,
            onTap: widget.onTap,
            enabled: true,
            style: textMedium.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: const Color.fromRGBO(20, 20, 20, 0.8)),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: const Color.fromRGBO(20, 20, 20, 0.36)),
              filled: widget.fillColor,
              fillColor: Theme.of(context).cardColor,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0, vertical: Dimensions.paddingSizeDefault),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 0)),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 0)),
            ),
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}
