import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:ride_sharing_user_app/features/home/widgets/home_search_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

class OutstationTab extends StatefulWidget {
  const OutstationTab({super.key});

  @override
  State<OutstationTab> createState() => _OutstationTabState();
}

class _OutstationTabState extends State<OutstationTab> {
  @override
  void initState() {
    super.initState();
    Get.find<RideController>().getOutstationTariffs();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 96),
      children: const [
        // HomeSearchWidget(isOutstation: true),
        SizedBox(height: 16),
        _OutstationInfoCard(),
      ],
    );
  }
}

class _OutstationInfoCard extends StatelessWidget {
  const _OutstationInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
