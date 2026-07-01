import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_search_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class LocalTab extends StatelessWidget {
  const LocalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      physics: const ClampingScrollPhysics(),
      children: [
        const HomeSearchWidget(
          isLocal: true,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: const Color.fromRGBO(255, 239, 203, 1),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: ExpansionTile(
              iconColor: const Color.fromRGBO(250, 173, 2, 1),
              collapsedIconColor: const Color.fromRGBO(250, 173, 2, 1),
              shape: const Border(),
              collapsedShape: const Border(),
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Text(
                'Things To Know',
                style:
                    textSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
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
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(
              Icons.circle,
              size: 4,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: textMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
            ),
          ),
        ],
      ),
    );
  }
}
