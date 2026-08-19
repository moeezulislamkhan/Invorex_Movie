import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A resilient image widget used by [PosterImage] and [BackdropImage].
///
/// Why this exists:
/// Plain `Image.network` with an `errorBuilder` fails *silently* — you just
/// get a gray box with no idea whether the poster path was missing, the
/// request timed out, or the CDN domain (image.tmdb.org) is unreachable
/// (e.g. blocked by a network/ISP) while the JSON API domain
/// (api.themoviedb.org) still works fine. This widget:
///   1. Logs the real error to the debug console so it's diagnosable.
///   2. Lets the user tap to retry a failed load instead of being stuck.
///   3. Shows a clearly different icon for "no image available" vs
///      "failed to load" so the two cases aren't confused.
class NetworkImageView extends StatefulWidget {
  const NetworkImageView({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.backgroundColor = const Color(0xFF14161C),
    this.placeholderIcon = Icons.movie_outlined,
  });

  final String? url;
  final BoxFit fit;
  final Color backgroundColor;
  final IconData placeholderIcon;

  @override
  State<NetworkImageView> createState() => _NetworkImageViewState();
}

class _NetworkImageViewState extends State<NetworkImageView> {
  // Bumping this forces Image.network to re-attempt the request.
  int _retryToken = 0;
  bool _failed = false;

  void _retry() {
    setState(() {
      _failed = false;
      _retryToken++;
    });
  }

  @override
  void didUpdateWidget(covariant NetworkImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _failed = false;
      _retryToken++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.url;

    if (url == null || url.isEmpty) {
      return SizedBox.expand(
        child: Container(
          color: widget.backgroundColor,
          alignment: Alignment.center,
          child: Icon(widget.placeholderIcon, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
        ),
      );
    }

    if (_failed) {
      return SizedBox.expand(
        child: Container(
          color: widget.backgroundColor,
          alignment: Alignment.center,
          child: InkWell(
            onTap: _retry,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), size: 22),
                const SizedBox(height: 4),
                Text(
                  'Tap to retry',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ClipRect(
      child: SizedBox.expand(
        child: Image.network(
          // Adding the retry token as a harmless query param forces a fresh
          // network attempt instead of returning the same failed image future.
          _retryToken == 0 ? url : '$url?retry=$_retryToken',
          key: ValueKey('${url}_$_retryToken'),
          fit: widget.fit,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox.expand(
              child: Container(
                color: widget.backgroundColor,
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
        // Logs to the debug console (visible via `flutter run` or
        // `adb logcat`) so you can tell a blocked/unreachable CDN apart
        // from a genuinely missing image. This does NOT show in release
        // builds' UI, only in your terminal while debugging.
        if (kDebugMode) {
          debugPrint('[NetworkImageView] Failed to load: $url\n  -> $error');
        }
        // Schedule the failure state after this build completes.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_failed) setState(() => _failed = true);
        });
            return SizedBox.expand(
              child: Container(
                color: widget.backgroundColor,
                alignment: Alignment.center,
                child: Icon(Icons.broken_image_outlined, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
              ),
            );
      },
        ),
      ),
    );
  }
}
