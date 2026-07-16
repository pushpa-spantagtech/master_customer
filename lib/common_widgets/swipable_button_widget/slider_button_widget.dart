import 'dart:async';

import 'package:flutter/material.dart';

class SliderButton extends StatefulWidget {
  final Widget? child;
  final double radius;
  final double height;
  final double width;
  final double buttonSize;

  final Color backgroundColor;
  final Color baseColor;
  final Color highlightedColor;
  final Color buttonColor;

  final Text? label;
  final Alignment alignLabel;
  final BoxShadow boxShadow;
  final Widget icon;
  final Function action;

  final bool shimmer;
  final bool dismissible;
  final bool vibrationFlag;
  final double dismissThresholds;
  final bool disable;
  final bool isLtr;

  const SliderButton({
    super.key,
    required this.action,
    this.radius = 18,
    this.boxShadow = const BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
    this.child,
    this.isLtr = true,
    this.vibrationFlag = false,
    this.shimmer = false,
    this.height = 56,
    this.buttonSize = 46,
    this.width = 250,
    this.alignLabel = Alignment.center,
    this.backgroundColor = const Color(0xFFFFF5F5),
    this.baseColor = const Color(0xFFE71921),
    this.buttonColor = Colors.white,
    this.highlightedColor = Colors.white,
    this.label,
    this.icon = const Icon(
      Icons.chevron_right_rounded,
      color: Color(0xFFE71921),
      size: 24,
    ),
    this.dismissible = false,
    this.dismissThresholds = 0.82,
    this.disable = false,
  })  : assert(buttonSize <= height),
        assert(dismissThresholds > 0 && dismissThresholds <= 1);

  @override
  State<SliderButton> createState() => SliderButtonState();
}

class SliderButtonState extends State<SliderButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<double>? _animation;

  double _offset = 0;
  double _maxOffset = 0;
  bool _busy = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        if (!mounted || _animation == null) return;
        setState(() => _offset = _animation!.value);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _animateTo(double target) async {
    _controller.stop();

    _animation = Tween<double>(
      begin: _offset,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _busy = true;
    await _controller.forward(from: 0);
    _busy = false;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (widget.disable || _busy || _completed || _maxOffset <= 0) return;

    final delta = widget.isLtr ? details.delta.dx : -details.delta.dx;

    setState(() {
      _offset = (_offset + delta).clamp(0.0, _maxOffset);
    });
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    if (widget.disable || _busy || _completed || _maxOffset <= 0) return;

    final progress = _offset / _maxOffset;

    if (progress < widget.dismissThresholds) {
      await _animateTo(0);
      return;
    }

    await _animateTo(_maxOffset);

    if (mounted) {
      setState(() => _completed = true);
    }

    final result = widget.action();
    if (result is Future) {
      await result;
    }

    if (!mounted || widget.dismissible) return;

    await Future<void>.delayed(const Duration(milliseconds: 120));
    setState(() => _completed = false);
    await _animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    if (_completed && widget.dismissible) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : widget.width;

        final effectiveWidth = widget.width.isFinite
            ? widget.width.clamp(0.0, availableWidth)
            : availableWidth;

        const outerPadding = 5.0;

        _maxOffset = (effectiveWidth - widget.buttonSize - (outerPadding * 2))
            .clamp(0.0, double.infinity);

        final progress =
            _maxOffset == 0 ? 0.0 : (_offset / _maxOffset).clamp(0.0, 1.0);

        final thumbLeft = widget.isLtr
            ? outerPadding + _offset
            : effectiveWidth - widget.buttonSize - outerPadding - _offset;

        return SizedBox(
          width: effectiveWidth,
          height: widget.height,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: widget.disable
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.radius),
                border: Border.all(
                  color: widget.disable
                      ? Theme.of(context).dividerColor.withValues(alpha: 0.24)
                      : widget.baseColor.withValues(alpha: 0.16),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.radius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: widget.isLtr
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: widget.baseColor.withValues(alpha: 0.10),
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 120),
                        opacity: (1 - progress).clamp(0.0, 1.0),
                        child: Align(
                          alignment: widget.alignLabel,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: widget.buttonSize + 18,
                            ),
                            child: DefaultTextStyle.merge(
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                              ),
                              child: widget.label ??
                                  Text(
                                    'slide_to_continue',
                                    style: TextStyle(
                                      color: widget.baseColor,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: thumbLeft,
                      top: outerPadding,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragUpdate:
                            widget.disable ? null : _onDragUpdate,
                        onHorizontalDragEnd: widget.disable ? null : _onDragEnd,
                        child: Container(
                          width: widget.buttonSize,
                          height: widget.buttonSize,
                          decoration: BoxDecoration(
                            color: widget.disable
                                ? Theme.of(context).disabledColor
                                : widget.buttonColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: widget.disable
                                  ? Colors.transparent
                                  : const Color(0xFFE5E7EB),
                            ),
                            boxShadow:
                                widget.disable ? null : [widget.boxShadow],
                          ),
                          alignment: Alignment.center,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 140),
                            child: progress >= widget.dismissThresholds
                                ? Icon(
                                    Icons.check_rounded,
                                    key: const ValueKey('done'),
                                    color: widget.baseColor,
                                    size: 23,
                                  )
                                : KeyedSubtree(
                                    key: const ValueKey('arrow'),
                                    child: widget.child ?? widget.icon,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
