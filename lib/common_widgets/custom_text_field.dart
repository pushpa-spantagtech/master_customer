import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/country_picker_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final bool isPassword;
  final bool isAmount;
  final Function(String text)? onChanged;
  final bool isEnabled;
  final int maxLines;
  final TextCapitalization capitalization;
  final double borderRadius;
  final String? prefixIcon;
  final String? suffixIcon;
  final bool showBorder;
  final String? countryDialCode;
  final double prefixHeight;
  final Color? fillColor;
  final bool prefix;
  final bool suffix;
  final Function()? onPressedSuffix;
  final Function(CountryCode countryCode)? onCountryChanged;
  final String? errorText;
  final Function()? onTap;
  final bool read;

  const CustomTextField({
    super.key,
    this.label = '',
    this.hintText = 'Write something...',
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.isEnabled = true,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.onChanged,
    this.prefixIcon,
    this.capitalization = TextCapitalization.none,
    this.isPassword = false,
    this.isAmount = false,
    this.borderRadius = 12,
    this.showBorder = true,
    this.prefixHeight = 32,
    this.countryDialCode,
    this.onCountryChanged,
    this.fillColor,
    this.prefix = true,
    this.suffix = true,
    this.suffixIcon,
    this.onPressedSuffix,
    this.errorText,
    this.onTap,
    this.read = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _validate = true;
  bool _isFocused = false;
  final Color borderColor = const Color.fromRGBO(250, 173, 2, 1);

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = widget.focusNode?.hasFocus ?? false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((widget.label ?? '').isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              widget.label ?? '',
              style: textMedium.copyWith(
                fontSize: Dimensions.paddingSizeSixteen,
                color: const Color.fromRGBO(20, 20, 20, 0.7),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          maxLines: widget.maxLines,
          controller: widget.controller,
          focusNode: widget.focusNode,
          style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              height: 1.0,
              color: const Color.fromRGBO(20, 20, 20, 0.8)),
          textInputAction: widget.inputAction,
          keyboardType:
          (widget.isAmount || widget.inputType == TextInputType.phone)
              ? const TextInputType.numberWithOptions(
            signed: false,
            decimal: true,
          )
              : widget.inputType,
          cursorColor: borderColor,
          textCapitalization: widget.capitalization,
          enabled: widget.isEnabled,
          autofocus: false,
          textAlignVertical: TextAlignVertical.center,
          autofillHints: widget.inputType == TextInputType.name
              ? [AutofillHints.name]
              : widget.inputType == TextInputType.emailAddress
              ? [AutofillHints.email]
              : widget.inputType == TextInputType.phone
              ? [AutofillHints.telephoneNumber]
              : widget.inputType == TextInputType.streetAddress
              ? [AutofillHints.fullStreetAddress]
              : widget.inputType == TextInputType.url
              ? [AutofillHints.url]
              : widget.inputType ==
              TextInputType.visiblePassword
              ? [AutofillHints.password]
              : null,
          obscureText: widget.isPassword ? _obscureText : false,
          inputFormatters: widget.inputType == TextInputType.phone
              ? <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ]
              : widget.isAmount
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
              : null,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                  color: Theme.of(context)
                      .hintColor
                      .withValues(alpha: widget.showBorder ? 1 : 0.0)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(
                color: Color.fromRGBO(248, 249, 250, 1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: borderColor),
            ),
            hintText: widget.hintText,
            fillColor: _isFocused
                ? const Color.fromRGBO(255, 255, 255, 1)
                : (widget.fillColor ?? const Color.fromRGBO(248, 249, 250, 1)),
            hintStyle: textRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).hintColor),
            filled: true,
            contentPadding: EdgeInsets.symmetric(
                horizontal: 0, vertical: !widget.isEnabled ? 12 : 0),
            prefixIcon: widget.prefix == false
                ? null
                : widget.prefixIcon != null
                ? Container(
              width: widget.prefixHeight,
              padding: const EdgeInsets.only(left: 8),
              child: Center(
                child: Image.asset(
                  widget.prefixIcon!,
                  height: 20,
                  width: 20,
                  color: const Color.fromRGBO(250, 173, 2, 1),
                ),
              ),
            )
                : Padding(
              padding: const EdgeInsets.only(left: 14),
              child: IntrinsicWidth(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24,
                      child: Center(
                        child: CodePickerWidget(
                          flagWidth: 24,
                          padding: EdgeInsets.zero,
                          onChanged: widget.onCountryChanged,
                          initialSelection: widget.countryDialCode,
                          favorite: [widget.countryDialCode!],
                          showDropDownButton: true,
                          showCountryOnly: true,
                          showOnlyCountryWhenClosed: true,
                          showFlagDialog: true,
                          hideMainText: true,
                          showFlagMain: true,
                          dialogBackgroundColor:
                          Theme.of(context).cardColor,
                          barrierColor: Get.isDarkMode
                              ? Colors.black.withValues(alpha: 0.4)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.countryDialCode ?? '',
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: const Color.fromRGBO(20, 20, 20, 0.8),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            ),
            suffixIcon: widget.suffixIcon != null
                ? InkWell(
              onTap: widget.onPressedSuffix,
              child: Container(
                margin: EdgeInsets.only(
                    right: widget.fillColor != null ? 0 : 10),
                width: 40,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: widget.fillColor != null
                      ? Colors.transparent
                      : Theme.of(context)
                      .primaryColor
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(widget.borderRadius),
                    bottomLeft: Radius.circular(widget.borderRadius),
                  ),
                ),
                child: Center(
                    child: Image.asset(widget.suffixIcon!,
                        height: 20, width: 20)),
              ),
            )
                : widget.isPassword
                ? IconButton(
              icon: Icon(
                  _obscureText
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: _obscureText
                      ? Theme.of(context)
                      .hintColor
                      .withValues(alpha: 0.5)
                      : borderColor),
              onPressed: _toggle,
            )
                : null,
            errorText: _validate ? widget.errorText : '',
            errorStyle: textRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall, height: 0.1),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                  color: Theme.of(context)
                      .hintColor
                      .withValues(alpha: widget.showBorder ? 1 : 0.0)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
          onSubmitted: (text) {
            widget.nextFocus != null
                ? FocusScope.of(context).requestFocus(widget.nextFocus)
                : null;
            setState(() {
              widget.controller!.text.isEmpty
                  ? _validate = true
                  : _validate = false;
            });
          },
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          readOnly: widget.read,
        ),
      ],
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
