import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/episode.dart';
import '../models/media_details.dart';
import '../models/media_item.dart';
import '../providers/watchlist_provider.dart';
import '../services/tmdb_api_service.dart';
import '../utils/formatters.dart';
import '../widgets/backdrop_image.dart';
import '../widgets/error_state.dart';
import '../widgets/horizontal_media_list.dart';
import '../widgets/poster_image.dart';
import 'watch_screen.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.item});

  static const routeName = '/details';

  final MediaItem item;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Future<MediaDetails> future;
  int selectedSeason = 1;
  Future<List<Episode>>? episodesFuture;

  @override
  void initState() {
    super.initState();
    future = context.read<TmdbApiService>().getDetails(
          widget.item.id,
          widget.item.type,
        );
  }

  void _loadEpisodes(int season) {
    setState(() {
      selectedSeason = season;
      episodesFuture = context.read<TmdbApiService>().getSeason(
            widget.item.id,
            season,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MediaDetails>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(
              message: snapshot.error.toString().replaceFirst('ApiException: ', ''),
              onRetry: () => setState(() {
                future = context.read<TmdbApiService>().getDetails(
                      widget.item.id,
                      widget.item.type,
                    );
              }),
            );
          }

          final details = snapshot.data!;
          return _DetailsBody(
            details: details,
            selectedSeason: selectedSeason,
            episodesFuture: episodesFuture,
            onSeasonSelected: _loadEpisodes,
          );
        },
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({
    required this.details,
    required this.selectedSeason,
    required this.episodesFuture,
    required this.onSeasonSelected,
  });

  final MediaDetails details;
  final int selectedSeason;
  final Future<List<Episode>>? episodesFuture;
  final ValueChanged<int> onSeasonSelected;

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<WatchlistProvider>();
    final saved = watchlist.contains(details);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 430,
            child: Stack(
              children: [
                BackdropImage(
                  path: details.backdropPath ?? details.posterPath,
                  height: 430,
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  left: 14,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Hero(
                        tag: 'poster_${details.watchlistKey}',
                        child: PosterImage(
                          path: details.posterPath,
                          width: 115,
                          height: 170,
                          borderRadius: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          details.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 27,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _meta(context, Icons.star_rounded, details.rating.toStringAsFixed(1)),
                  _meta(context, Icons.calendar_month_outlined, details.year),
                  _meta(
                    context,
                    Icons.category_outlined,
                    details.typeLabel,
                  ),
                  if (details.runtime != null)
                    _meta(
                      context,
                      Icons.schedule_rounded,
                      formatRuntime(details.runtime),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: details.genres
                    .map(
                      (genre) => Chip(
                        label: Text(genre),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                details.overview.isEmpty
                    ? 'No overview is available for this title.'
                    : details.overview,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  height: 1.55,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WatchScreen(
                                title: details.title,
                                videoId: details.muxVideoId,
                                trailerKey: details.trailerKey,
                              ),
                            ),
                          ),
                      icon: const Icon(Icons.play_circle_filled_rounded),
                      label: const Text('Watch Now'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (details.trailerKey != null && details.trailerKey!.isNotEmpty)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WatchScreen(
                                  title: details.title,
                                  trailerKey: details.trailerKey,
                                ),
                              ),
                            ),
                        icon: const Icon(Icons.movie_filter_rounded),
                        label: const Text('Trailer'),
                      ),
                    ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    onPressed: () => watchlist.toggle(details),
                    icon: Icon(
                      saved
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                    ),
                  ),
                ],
              ),
              if (details.cast.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text(
                  'Cast',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  details.cast.join(' • '),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],
              if (details.type == MediaType.tv) ...[
                const SizedBox(height: 30),
                Text(
                  'Episodes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                _SeasonSelector(
                  count: details.numberOfSeasons ?? 1,
                  selected: selectedSeason,
                  onSelected: onSeasonSelected,
                ),
                const SizedBox(height: 12),
                _EpisodeList(
                  future: episodesFuture ??
                      Future.value(const <Episode>[]),
                  showPrompt: episodesFuture == null,
                ),
              ],
              if (details.similar.isNotEmpty) ...[
                const SizedBox(height: 26),
                Text(
                  'You May Also Like',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                HorizontalMediaList(items: details.similar, height: 270, showNavArrows: true),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _meta(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.54)),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}

class _SeasonSelector extends StatelessWidget {
  const _SeasonSelector({
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  final int count;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final season = index + 1;
          return ChoiceChip(
            label: Text('Season $season'),
            selected: season == selected,
            onSelected: (_) => onSelected(season),
          );
        },
      ),
    );
  }
}

class _EpisodeList extends StatelessWidget {
  const _EpisodeList({
    required this.future,
    required this.showPrompt,
  });

  final Future<List<Episode>> future;
  final bool showPrompt;

  @override
  Widget build(BuildContext context) {
    if (showPrompt) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Select a season above to load episodes.',
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.54)),
        ),
      );
    }

    return FutureBuilder<List<Episode>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Text(
            snapshot.error.toString().replaceFirst('ApiException: ', ''),
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.54)),
          );
        }

        final episodes = snapshot.data ?? [];
        if (episodes.isEmpty) {
          return Text(
            'No episodes available for this season.',
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.54)),
          );
        }

        return Column(
          children: episodes
              .map(
                (episode) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: PosterImage(
                      path: episode.stillPath,
                      width: 110,
                      height: 70,
                      borderRadius: 12,
                    ),
                    title: Text(
                      '${episode.episodeNumber}. ${episode.name}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      episode.overview.isEmpty
                          ? 'No episode description.'
                          : episode.overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: episode.runtime == null
                        ? null
                        : Text(formatRuntime(episode.runtime)),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
