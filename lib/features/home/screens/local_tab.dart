import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_search_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class LocalTab extends StatelessWidget {
  const LocalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      physics: const ClampingScrollPhysics(),
      children: [
        const HomeSearchWidget(
          isLocal: true,
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: ExpansionTile(
              iconColor: const Color.fromRGBO(250, 173, 2, 1),
              collapsedIconColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              title: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: Color.fromRGBO(250, 173, 2, 1),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Things To Know',
                    style: textSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ],
              ),
              children: const [
                _ThingItem('Meter starts from your pickup place.'),
                _ThingItem(
                    'Travel time will begin 5 minutes after the vehicle arrives.'),
                _ThingItem(
                    'Waiting charges are free for the first 15 minutes.'),
                _ThingItem(
                    'Waiting charges ₹1.66 per minute after the free waiting period.'),
                _ThingItem('Night charges (10 PM to 6 AM) are applicable.'),
                _ThingItem('Applicable only within city limits.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ThingItem extends StatelessWidget {
  final String text;

  const _ThingItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: Color.fromRGBO(250, 173, 2, 1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: textMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                height: 1.45,
                color: const Color.fromRGBO(85, 85, 85, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
