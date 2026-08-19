import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({
    super.key,
    this.title,
    this.trailerKey,
  });

  final String? title;
  final String? trailerKey;

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  String? _errorMessage;

  Future<void> _openTrailer(BuildContext context) async {
    if (widget.trailerKey == null || widget.trailerKey!.isEmpty) {
      _showError('Trailer not available');
      return;
    }

    final uri = Uri.parse('https://www.youtube.com/watch?v=${widget.trailerKey}');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the trailer link.')),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thumbnail = widget.trailerKey != null
        ? 'https://img.youtube.com/vi/${widget.trailerKey}/hqdefault.jpg'
        : 'https://via.placeholder.com/1280x720?text=Video+Unavailable';

    return Scaffold(
      appBar: AppBar(title: const Text('Watch')),
      body: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              thumbnail,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.video_library, size: 60),
                                  ),
                                );
                              },
                            ),
                            Container(color: Colors.black38),
                            if (widget.trailerKey != null && widget.trailerKey!.isNotEmpty)
                              Center(
                                child: IconButton.filled(
                                  iconSize: 38,
                                  onPressed: () => _openTrailer(context),
                                  icon: const Icon(Icons.play_arrow_rounded),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      widget.title ?? 'Video Player',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else
                      Text(
                        widget.trailerKey != null && widget.trailerKey!.isNotEmpty
                            ? 'This button opens the trailer from its legal external video source. Invorex Movies does not host or distribute copyrighted movie files.'
                            : 'No official trailer is available for this title right now.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                          height: 1.5,
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (widget.trailerKey != null && widget.trailerKey!.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _openTrailer(context),
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: const Text('Open Official Trailer'),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.block),
                          label: const Text('Trailer Not Available'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

