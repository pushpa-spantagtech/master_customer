import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/calender_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_shimmer.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/trip_item_view.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripScreen extends StatefulWidget {
  final bool fromProfile;

  const TripScreen({
    super.key,
    required this.fromProfile,
  });

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<TripController>().initData();
    Get.find<TripController>().getTripList(1);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BodyWidget(
        appBar: AppBarWidget(
          backgroundColor: const Color(0xFFFF0000),
          title: 'my_trips'.tr,
          toolbarHeight: 65,
          fontSize: 18,
          showBackButton: widget.fromProfile,
        ),
        body: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: GetBuilder<TripController>(
            builder: (tripController) {
              return Column(
                children: [
                  _TripHeader(
                    tripController: tripController,
                    onFilterTap: () {
                      _showFilterBottomSheet(
                        context,
                        tripController,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _TripList(
                    tripController: tripController,
                    scrollController: scrollController,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showFilterBottomSheet(
    BuildContext context,
    TripController tripController,
  ) async {
    final int? selectedIndex = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (bottomSheetContext) {
        return _TripFilterBottomSheet(
          selectedIndex: tripController.filterIndex,
          filterList: tripController.filterList,
        );
      },
    );

    if (!mounted || selectedIndex == null) {
      return;
    }

    final bool isCustomDate =
        selectedIndex == tripController.filterList.length - 1;

    if (isCustomDate) {
      await showDialog<void>(
        context: context,
        builder: (_) {
          return CalenderWidget(
            onChanged: (_) => Get.back(),
          );
        },
      );
      return;
    }

    tripController.updateShowCustomDateState(false);
    tripController.setFilterTypeName(selectedIndex);
  }
}

class _TripHeader extends StatelessWidget {
  final TripController tripController;
  final VoidCallback onFilterTap;

  const _TripHeader({
    required this.tripController,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'trip_history'.tr,
            style: textMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _FilterButton(
          label: _selectedFilterLabel(tripController),
          onTap: onFilterTap,
        ),
      ],
    );
  }

  String _selectedFilterLabel(TripController controller) {
    if (controller.showCustomDate &&
        controller.filterStartDate.isNotEmpty &&
        controller.filterEndDate.isNotEmpty) {
      return '${controller.filterStartDate} - ${controller.filterEndDate}';
    }

    final int safeIndex =
        controller.filterIndex.clamp(0, controller.filterList.length - 1);

    return _filterDisplayName(controller.filterList[safeIndex]);
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 108,
        minHeight: 42,
        maxWidth: 190,
      ),
      child: Material(
        color: Colors.white,
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(
            color: Color(0xFFE7E9EE),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.tune_rounded,
                  size: 17,
                  color: Color(0xFFFFB100),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xFF303744),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: Color(0xFF6F7787),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TripFilterBottomSheet extends StatelessWidget {
  final int selectedIndex;
  final List<String> filterList;

  const _TripFilterBottomSheet({
    required this.selectedIndex,
    required this.filterList,
  });

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        10,
        18,
        bottomPadding + 22,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC9C9),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6DE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.filter_list_rounded,
                  size: 19,
                  color: Color(0xFFFFB100),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Filter',
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(
            filterList.length,
            (index) {
              final bool isSelected = index == selectedIndex;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _FilterOptionTile(
                  title: _filterDisplayName(filterList[index]),
                  isSelected: isSelected,
                  onTap: () => Navigator.of(context).pop(index),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterOptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOptionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color selectedColor = Color(0xFFFFB100);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(
            minHeight: 48,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF7E5) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? selectedColor
                        : Theme.of(context).hintColor.withValues(alpha: 0.65),
                    width: 1.6,
                  ),
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: isSelected
                        ? selectedColor
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  size: 19,
                  color: selectedColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripList extends StatelessWidget {
  final TripController tripController;
  final ScrollController scrollController;

  const _TripList({
    required this.tripController,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (tripController.tripModel == null ||
        tripController.tripModel!.data == null) {
      return const Expanded(
        child: NotificationShimmer(),
      );
    }

    if (tripController.tripModel!.data!.isEmpty) {
      return const Expanded(
        child: NoDataWidget(title: 'no_trip_found'),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        controller: scrollController,
        child: PaginatedListWidget(
          scrollController: scrollController,
          totalSize: tripController.tripModel!.totalSize,
          offset: tripController.tripModel!.offset != null
              ? int.tryParse(
                  tripController.tripModel!.offset.toString(),
                )
              : null,
          onPaginate: (int? offset) async {
            if (offset != null) {
              await tripController.getTripList(offset);
            }
          },
          itemView: Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: ListView.builder(
              itemCount: tripController.tripModel!.data!.length,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return TripItemView(
                  tripDetails: tripController.tripModel!.data![index],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

String _filterDisplayName(String value) {
  switch (value) {
    case 'all_time':
      return 'All Time';
    case 'today':
      return 'Today';
    case 'previous_day':
      return 'Yesterday';
    case 'custom_date':
      return 'Custom';
    default:
      return value.tr;
  }
}
