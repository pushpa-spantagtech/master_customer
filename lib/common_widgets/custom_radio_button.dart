import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CustomRadioButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final int length;
  final int index;

  const CustomRadioButton(
      {super.key,
      required this.text,
      required this.isSelected,
      required this.onTap,
      required this.index,
      required this.length});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.1)),
          // borderRadius: length == 1
          //     ? BorderRadius.circular(10)
          //     : (length > 1 && index == 0)
          //         ? const BorderRadius.only(
          //             topLeft: Radius.circular(10),
          //             topRight: Radius.circular(10))
          //         : (length > 1 && index == length - 1)
          //             ? const BorderRadius.only(
          //                 bottomLeft: Radius.circular(10),
          //                 bottomRight: Radius.circular(10))
          //             : null,
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? const Color.fromRGBO(255, 239, 203, 1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            isSelected
                ? Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 1),
                        borderRadius: BorderRadius.circular(50)),
                    child: const Icon(
                      Icons.check,
                      color: Color.fromRGBO(250, 173, 2, 1),
                      size: 15,
                    ))
                : Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Theme.of(context).hintColor)),
                    child: const SizedBox()),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: textMedium.copyWith(
                  color:
                      !isSelected ? Theme.of(context).hintColor : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
