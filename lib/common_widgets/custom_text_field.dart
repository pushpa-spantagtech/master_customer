import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/country_picker_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  const PhoneNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 10) {
      digits = digits.substring(digits.length - 10);
    }

    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}

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
    widget.focusNode?.addListener(_focusListener);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_focusListener);
    super.dispose();
  }

  void _focusListener() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode?.hasFocus ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double radius = widget.borderRadius < 14 ? 16 : widget.borderRadius;
    final Color normalBorderColor = Theme.of(context)
        .hintColor
        .withValues(alpha: widget.showBorder ? 0.35 : 0.0);
    const Color disabledFillColor = Color.fromRGBO(248, 249, 250, 1);
    final Color activeFillColor =
        _isFocused ? Colors.white : (widget.fillColor ?? Colors.white);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: TextField(
        maxLines: widget.maxLines,
        controller: widget.controller,
        focusNode: widget.focusNode,
        style: textRegular.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          height: 1.2,
          color: const Color.fromRGBO(20, 20, 20, 0.85),
        ),
        textInputAction: widget.inputAction,
        keyboardType:
            (widget.isAmount || widget.inputType == TextInputType.phone)
                ? const TextInputType.numberWithOptions(
                    signed: false, decimal: true)
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
                            : widget.inputType == TextInputType.visiblePassword
                                ? [AutofillHints.password]
                                : null,
        obscureText: widget.isPassword ? _obscureText : false,
        inputFormatters: widget.inputType == TextInputType.phone
            ? const <TextInputFormatter>[
          PhoneNumberFormatter(),
        ]
            : widget.isAmount
                ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                : null,
        decoration: InputDecoration(
          labelText: (widget.label ?? '').isNotEmpty ? widget.label : null,
          hintText: widget.hintText,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          floatingLabelStyle: textMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: borderColor,
          ),
          labelStyle: textRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).hintColor,
          ),
          hintStyle: textRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).hintColor.withValues(alpha: 0.75),
          ),
          filled: true,
          fillColor: widget.isEnabled ? activeFillColor : disabledFillColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(color: normalBorderColor),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide:
                BorderSide(color: normalBorderColor.withValues(alpha: 0.35)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(color: borderColor, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error, width: 1.4),
          ),
          prefixIcon: widget.prefix == false
              ? null
              : widget.prefixIcon != null
                  ? SizedBox(
                      width: 54,
                      child: Center(
                        child: Image.asset(
                          widget.prefixIcon!,
                          height: 22,
                          width: 22,
                          color: borderColor,
                        ),
                      ),
                    )
                  : _countryCodePrefix(context),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 54, minHeight: 52),
          suffixIcon: _suffixIcon(context),
          suffixIconConstraints:
              const BoxConstraints(minWidth: 48, minHeight: 52),
          errorText: _validate ? widget.errorText : '',
          errorStyle: textRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall, height: 0.2),
        ),
        onSubmitted: (text) {
          if (widget.nextFocus != null) {
            FocusScope.of(context).requestFocus(widget.nextFocus);
          }
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
    );
  }

  Widget? _countryCodePrefix(BuildContext context) {
    if (widget.countryDialCode == null) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 6),
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
                  dialogBackgroundColor: Theme.of(context).cardColor,
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
    );
  }

  Widget? _suffixIcon(BuildContext context) {
    if (widget.suffix == false) {
      return null;
    }

    if (widget.suffixIcon != null) {
      return InkWell(
        onTap: widget.onPressedSuffix,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 48,
          child: Center(
            child: Image.asset(widget.suffixIcon!, height: 20, width: 20),
          ),
        ),
      );
    }

    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: _obscureText
              ? Theme.of(context).hintColor.withValues(alpha: 0.7)
              : borderColor,
        ),
        onPressed: _toggle,
      );
    }

    return null;
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
