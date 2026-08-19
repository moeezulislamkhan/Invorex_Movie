import 'package:flutter/material.dart';

import '../models/media_item.dart';
import 'media_card.dart';

class HorizontalMediaList extends StatefulWidget {
  const HorizontalMediaList({
    super.key,
    required this.items,
    this.height = 265,
    this.itemWidth,
    this.showNavArrows = false,
  });

  final List<MediaItem> items;
  final double height;
  final double? itemWidth;
  final bool showNavArrows;

  @override
  State<HorizontalMediaList> createState() => _HorizontalMediaListState();
}

class _HorizontalMediaListState extends State<HorizontalMediaList> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollBy(double offset) {
    final target = (_controller.offset + offset).clamp(
      0.0,
      _controller.position.hasContentDimensions
          ? _controller.position.maxScrollExtent
          : double.infinity,
    );
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(builder: (context, constraints) {
      final availableWidth = constraints.maxWidth;
      final padding = 40.0; // symmetric horizontal padding
      final separator = 12.0;

      // Determine a sensible item width based on available space and optional override
      double computedItemWidth = widget.itemWidth ?? 140;
      // If on narrow screen, scale down item width to fit more comfortably
      if (availableWidth < 400) {
        computedItemWidth = (availableWidth - padding) / 2.2;
      } else if (availableWidth < 600) {
        computedItemWidth = (availableWidth - padding) / 3.2;
      }
      computedItemWidth = computedItemWidth.clamp(100.0, 260.0);

      final visibleCount = (availableWidth - padding) ~/ (computedItemWidth + separator);
      final scrollAmount = (computedItemWidth + separator) * (visibleCount > 0 ? visibleCount : 1);

      Widget list = SizedBox(
        height: widget.height,
        child: ListView.separated(
          controller: _controller,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(width: separator),
          itemBuilder: (_, index) => SizedBox(
            width: computedItemWidth,
            child: MediaCard(item: items[index], width: computedItemWidth),
          ),
        ),
      );

      if (!widget.showNavArrows) return list;

      return Stack(
        alignment: Alignment.center,
        children: [
          list,
          Positioned(
            left: 4,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _scrollBy(-scrollAmount),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_left_rounded),
              ),
            ),
          ),
          Positioned(
            right: 4,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _scrollBy(scrollAmount),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          ),
        ],
      );
    });
  }
}
