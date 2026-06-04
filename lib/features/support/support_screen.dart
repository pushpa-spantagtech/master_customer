import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/support/widgets/contact_us_view.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({super.key});

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late int currentPage;
  String data = '';

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
    data =
        '${Get.find<ConfigController>().config!.termsAndConditions?.shortDescription ?? ''}'
        '\n${Get.find<ConfigController>().config!.termsAndConditions?.longDescription ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyWidget(
        appBar: AppBarWidget(
          title: 'do_you_need_help'.tr,
          centerTitle: true,
          showBackButton: true,
          toolbarHeight: 65,
          backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
        ),
        body: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(children: [
            Text(
              'help_support'.tr,
              style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: const Color.fromRGBO(20, 20, 20, 1)),
            ),
            const ContactUsView(),
          ]),
        ),
      ),
    );
  }
}
