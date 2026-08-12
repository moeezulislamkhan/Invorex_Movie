import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/media_item.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/backdrop_image.dart';
import '../widgets/error_state.dart';
import '../widgets/horizontal_media_list.dart';
import '../widgets/section_header.dart';
import '../widgets/shimmer_placeholder.dart';
import 'details_screen.dart';
import 'explore_screen.dart';
import 'watch_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final home = context.watch<HomeProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: home.load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${auth.name} 👋',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'What do you want to watch today?',
                        style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
                      ),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ExploreScreen(),
                            ),
                          );
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search movies, series...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: Container(
                                margin: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: const Icon(Icons.tune_rounded),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (home.loading)
                const SliverToBoxAdapter(child: ShimmerPlaceholder(height: 300))
              else if (home.error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorState(
                    message: home.error!,
                    onRetry: home.load,
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: _FeaturedCarousel(items: home.trending.take(5).toList()),
                ),
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Trending Now',
                    actionLabel: 'See All',
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ExploreScreen(),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: HorizontalMediaList(items: home.trending, showNavArrows: true),
                ),
                SliverToBoxAdapter(
                  child: SectionHeader(title: 'Popular Movies'),
                ),
                SliverToBoxAdapter(
                  child: HorizontalMediaList(items: home.popularMovies, showNavArrows: true),
                ),
                SliverToBoxAdapter(
                  child: SectionHeader(title: 'Popular Series'),
                ),
                SliverToBoxAdapter(
                  child: HorizontalMediaList(items: home.popularTv, showNavArrows: true),
                ),
                SliverToBoxAdapter(
                  child: SectionHeader(title: 'Top Rated'),
                ),
                SliverToBoxAdapter(
                  child: HorizontalMediaList(items: home.topRated, showNavArrows: true),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedCarousel extends StatefulWidget {
  const _FeaturedCarousel({required this.items});

  final List<MediaItem> items;

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  final controller = PageController(viewportFraction: 0.88);

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 330,
      child: PageView.builder(
        controller: controller,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return Padding(
            padding: const EdgeInsets.only(left: 20, right: 6, top: 20),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                DetailsScreen.routeName,
                arguments: item,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: BackdropImage(
                  path: item.backdropPath ?? item.posterPath,
                  height: 330,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'TRENDING',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 27,
                                  height: 1.05,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFFC857),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(item.rating.toStringAsFixed(1)),
                                  const SizedBox(width: 10),
                                  Text(item.year),
                                  const SizedBox(width: 10),
                                  Text(item.typeLabel),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 40,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => WatchScreen(
                                              title: item.title,
                                              videoId: item.muxVideoId,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(Icons.play_circle_filled_rounded, size: 18),
                                        label: const Text('Watch'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pushNamed(
                                          context,
                                          DetailsScreen.routeName,
                                          arguments: item,
                                        ),
                                        child: const Text('Details'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
