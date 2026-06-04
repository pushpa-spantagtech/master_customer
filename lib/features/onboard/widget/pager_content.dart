import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class PagerContent extends StatelessWidget {
  const PagerContent({
    super.key,
    required this.image,
    required this.text,
    required this.index,
  });

  final String image;
  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Center(
            child: Image.asset(
              image,
              width: MediaQuery.of(context).size.width * 0.75,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            text,
            style: textSemiBold.copyWith(
              color: const Color(0xFF141414),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
