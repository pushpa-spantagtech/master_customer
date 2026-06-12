import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_search_widget.dart';

class OutstationTab extends StatelessWidget {
  const OutstationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Padding(
          padding: EdgeInsets.all(16),
          child: HomeSearchWidget(
            isOutstation: true,
          ),
        ),
      ],
    );
  }
}
