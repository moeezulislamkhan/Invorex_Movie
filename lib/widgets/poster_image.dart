import 'package:flutter/material.dart';

import '../config/app_config.dart';
import 'network_image_view.dart';

class PosterImage extends StatelessWidget {
  const PosterImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.borderRadius = 16,
  });

  final String? path;
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = path == null
        ? null
        : '${AppConfig.imageBaseUrl}${AppConfig.posterSize}$path';

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: NetworkImageView(
          url: url,
          placeholderIcon: Icons.movie_outlined,
        ),
      ),
    );
  }
}
