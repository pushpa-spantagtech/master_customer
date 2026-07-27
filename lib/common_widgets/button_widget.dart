import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ButtonWidget extends StatelessWidget {
  final Function()? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets margin;
  final double height;
  final double width;
  final double? fontSize;
  final double radius;
  final IconData? icon;
  final String? imageIcon;
  final bool showBorder;
  final double borderWidth;
  final Color? borderColor;
  final Color? textColor;
  final Color? backgroundColor;
  final bool boldText;

  const ButtonWidget({
    super.key,
    this.onPressed,
    required this.buttonText,
    this.transparent = false,
    this.margin = EdgeInsets.zero,
    this.width = Dimensions.webMaxWidth,
    this.height = 48,
    this.fontSize,
    this.radius = 18,
    this.icon,
    this.imageIcon,
    this.showBorder = false,
    this.borderWidth = 1,
    this.borderColor,
    this.textColor,
    this.backgroundColor,
    this.boldText = true,
  }) : assert(
          !(icon != null && imageIcon != null),
          'Provide either icon or imageIcon, not both',
        );

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = backgroundColor ??
        (onPressed == null
            ? Theme.of(context).disabledColor
            : transparent
                ? Colors.transparent
                : Theme.of(context).primaryColor);

    final Color foregroundColor = textColor ??
        (transparent ? Theme.of(context).primaryColor : Colors.white);

    final ButtonStyle buttonStyle = FilledButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: Theme.of(context).disabledColor,
      disabledForegroundColor: Colors.white.withValues(alpha: 0.75),
      minimumSize: Size(width, height),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      elevation: 0,
      shadowColor: transparent
          ? Colors.transparent
          : Theme.of(context).primaryColor.withValues(alpha: 0.25),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: showBorder
            ? BorderSide(
                color: borderColor ?? Theme.of(context).primaryColor,
                width: borderWidth,
              )
            : BorderSide.none,
      ),
    );

    return Center(
      child: SizedBox(
        width: width,
        child: Padding(
          padding: margin,
          child: FilledButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageIcon != null) ...[
                  Image.asset(
                    imageIcon!,
                    height: 22,
                    width: 22,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    size: 22,
                    color: foregroundColor,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                ],
                Flexible(
                  child: Text(
                    buttonText,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: (boldText ? textBold : textMedium).copyWith(
                      color: foregroundColor,
                      fontSize: fontSize ?? Dimensions.fontSizeLarge,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
