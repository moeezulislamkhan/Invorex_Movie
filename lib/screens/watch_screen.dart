import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WatchScreen extends StatelessWidget {
  const WatchScreen({
    super.key,
    required this.title,
    required this.trailerKey,
  });

  final String title;
  final String trailerKey;

  Future<void> _openTrailer(BuildContext context) async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=$trailerKey');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the trailer link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbnail = 'https://img.youtube.com/vi/$trailerKey/hqdefault.jpg';

    return Scaffold(
      appBar: AppBar(title: const Text('Watch Trailer')),
      body: Padding(
        padding: const EdgeInsets.all(20),
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
                    Image.network(thumbnail, fit: BoxFit.cover),
                    Container(color: Colors.black38),
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
              title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'This button opens the trailer from its legal external video source. '
              'Invorex Movies does not host or distribute copyrighted movie files.',
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6), height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openTrailer(context),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open Official Trailer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
