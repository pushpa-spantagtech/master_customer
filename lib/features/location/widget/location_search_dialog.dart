import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/domain/models/prediction_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

class LocationSearchDialog extends StatefulWidget {
  final GoogleMapController? mapController;
  final LocationType type;

  const LocationSearchDialog({
    super.key,
    required this.mapController,
    required this.type,
  });

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;
  List<PredictionModel> _suggestions = <PredictionModel>[];
  bool _isLoading = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _onSearchChanged() {
    _debounce?.cancel();

    final String query = _searchController.text.trim();

    debugPrint('SEARCH FIELD TEXT: $query');

    if (query.length < 2) {
      _requestId++;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _suggestions = <PredictionModel>[];
        });
      }
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      debugPrint('DEBOUNCE COMPLETED: $query');
      _loadSuggestions(query);
    });
  }

  Future<void> _loadSuggestions(String query) async {
    final int currentRequestId = ++_requestId;

    debugPrint('LOAD SUGGESTIONS: $query');
    debugPrint('REQUEST ID: $currentRequestId');

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('CALLING LOCATION CONTROLLER...');

      final List<PredictionModel> result =
          await Get.find<LocationController>().searchLocation(
        context,
        query,
        fromMap: true,
        type: widget.type,
      );

      debugPrint('SEARCH COMPLETED');
      debugPrint('RESULT COUNT: ${result.length}');

      if (!mounted) {
        debugPrint('WIDGET NOT MOUNTED');
        return;
      }

      if (currentRequestId != _requestId) {
        debugPrint(
          'OLD REQUEST IGNORED: $currentRequestId, latest: $_requestId',
        );
        return;
      }

      setState(() {
        _suggestions = List<PredictionModel>.from(result);
        _isLoading = false;
      });

      debugPrint('SUGGESTIONS DISPLAY COUNT: ${_suggestions.length}');
    } catch (error, stackTrace) {
      debugPrint('LOCATION AUTOCOMPLETE ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted || currentRequestId != _requestId) {
        return;
      }

      setState(() {
        _suggestions = <PredictionModel>[];
        _isLoading = false;
      });
    }
  }

  Future<void> _selectSuggestion(PredictionModel suggestion) async {
    final String? placeId = suggestion.placeId;
    final String? description = suggestion.description;

    if (placeId == null ||
        placeId.trim().isEmpty ||
        description == null ||
        description.trim().isEmpty) {
      return;
    }

    _focusNode.unfocus();

    await Get.find<LocationController>().setLocation(
      placeId,
      description,
      widget.mapController,
      type: widget.type,
    );

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: Dimensions.paddingSizeSmall,
        left: Dimensions.paddingSizeSmall,
        right: Dimensions.paddingSizeSmall,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromRGBO(250, 173, 2, 1),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  cursorColor: const Color.fromRGBO(250, 173, 2, 1),
                  keyboardType: TextInputType.streetAddress,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    hintText: 'search_location'.tr,
                    hintStyle:
                        Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).disabledColor,
                            ),
                    suffixIcon: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Color.fromRGBO(250, 173, 2, 1),
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                ),
              ),
              if (_suggestions.isNotEmpty)
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 280),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 8,
                        spreadRadius: 1,
                        color: Color.fromRGBO(0, 0, 0, 0.18),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    itemBuilder: (context, index) {
                      final PredictionModel suggestion = _suggestions[index];

                      return InkWell(
                        onTap: () => _selectSuggestion(suggestion),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  color: Color.fromRGBO(250, 173, 2, 1),
                                ),
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeSmall,
                              ),
                              Expanded(
                                child: Text(
                                  suggestion.description ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                        fontSize: Dimensions.fontSizeDefault,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (!_isLoading &&
                  _searchController.text.trim().length >= 2 &&
                  _suggestions.isEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'No locations found',
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
