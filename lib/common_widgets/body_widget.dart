import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

class BodyWidget extends StatefulWidget {
  final Widget body;
  final AppBarWidget appBar;
  final double topMargin;

  const BodyWidget({
    super.key,
    required this.body,
    required this.appBar,
    this.topMargin = 0,
  });

  @override
  State<BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      widget.appBar,
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(top: widget.topMargin),
          child: Material(
            color: const Color.fromRGBO(255, 255, 255, 1),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: widget.body,
            ),
          ),
        ),
      ),
    ]);
  }
}
