import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/mux_video_api_service.dart';
import 'video_player_screen.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({
    super.key,
    this.title,
    this.trailerKey,
    this.videoId,
  });

  final String? title;
  final String? trailerKey;
  final String? videoId;

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  String? _playbackUrl;
  bool _isLoadingMuxVideo = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // If we have a video ID, try to load the MUX video
    if (widget.videoId != null && widget.videoId!.isNotEmpty) {
      _loadMuxVideo();
    }
  }

  Future<void> _loadMuxVideo() async {
    setState(() {
      _isLoadingMuxVideo = true;
      _errorMessage = null;
    });

    try {
      final muxService = context.read<MuxVideoApiService>();
      final playbackUrl = await muxService.getPlaybackUrl(widget.videoId!);

      if (mounted) {
        setState(() {
          _playbackUrl = playbackUrl;
          _isLoadingMuxVideo = false;
        });

        // Navigate to video player screen
        if (_playbackUrl != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                videoUrl: _playbackUrl!,
                title: widget.title ?? 'Video Player',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMuxVideo = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

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
      body: _isLoadingMuxVideo
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading video...'),
                ],
              ),
            )
          : Padding(
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
                          color: Colors.red.withValues(alpha: 0.1),
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
                        widget.videoId != null
                            ? 'Click the play button to watch the video. This streams from MUX Video API.'
                            : 'This button opens the trailer from its legal external video source. Invorex Movies does not host or distribute copyrighted movie files.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (widget.videoId != null && widget.videoId!.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isLoadingMuxVideo ? null : _loadMuxVideo,
                          icon: _isLoadingMuxVideo
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.play_circle_filled_rounded),
                          label: Text(_isLoadingMuxVideo ? 'Loading...' : 'Play Video'),
                        ),
                      )
                    else if (widget.trailerKey != null && widget.trailerKey!.isNotEmpty)
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
                          label: const Text('Video Not Available'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

