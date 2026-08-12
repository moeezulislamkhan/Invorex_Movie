import 'package:flutter/material.dart';

import '../config/app_config.dart';
import 'network_image_view.dart';

class BackdropImage extends StatelessWidget {
  const BackdropImage({
    super.key,
    required this.path,
    required this.height,
    this.child,
  });

  final String? path;
  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final url = path == null
        ? null
        : '${AppConfig.imageBaseUrl}${AppConfig.backdropSize}$path';

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetworkImageView(
            url: url,
            placeholderIcon: Icons.image_outlined,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.35),
                  const Color(0xFF08090C),
                ],
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
