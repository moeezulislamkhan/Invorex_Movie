import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../screens/details_screen.dart';
import '../screens/watch_screen.dart';
import 'poster_image.dart';

class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
    required this.item,
    this.width = 140,
  });

  final MediaItem item;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    DetailsScreen.routeName,
                    arguments: item,
                  ),
                  child: PosterImage(
                    path: item.posterPath,
                    width: width,
                    borderRadius: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 15, color: Color(0xFFFFC857)),
              const SizedBox(width: 3),
              Text(item.rating.toStringAsFixed(1)),
              const SizedBox(width: 8),
              Text(
                item.year,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
