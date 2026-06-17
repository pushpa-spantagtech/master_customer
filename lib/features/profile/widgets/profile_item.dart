import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final String icon;
  final Function()? onTap;
  final bool divider;

  const ProfileMenuItem(
      {super.key,
      required this.title,
      required this.icon,
      this.onTap,
      this.divider = true});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
          child: ListTile(
        leading: Image.asset(icon,
            width: 20,
            height: 20,
            fit: BoxFit.cover,
            color: const Color.fromRGBO(250, 173, 2, 1)),
        title: Text(title.tr,
            style: textMedium.copyWith(
                color: Theme.of(context).textTheme.bodyLarge!.color)),
        onTap: onTap,
      )),
      divider
          ? const Divider(color: Color.fromRGBO(0, 0, 0, 0.2), thickness: 1)
          : const SizedBox(),
    ]);
  }
}
