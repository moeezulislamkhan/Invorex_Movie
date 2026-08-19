import 'dart:async';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ======================================================
  // ROTATING SUBTITLES
  // ======================================================

  Timer? _subtitleTimer;

  int _subtitleIndex = 0;

  final List<String> _subtitles = [
    'Discover stories worth watching tonight.',
    'Find your next favorite movie.',
    'Every story deserves your attention.',
    'Your next movie night starts here.',
    'Great movies make moments unforgettable.',
    'Find something perfect for your mood.',
    'Tonight deserves a story worth remembering.',
    'Explore movies beyond the ordinary.',
    'Good stories are always worth discovering.',
    'Find something new to enjoy.',
    'Every movie brings a different journey.',
    'Discover entertainment made for you.',
    'Your next great story awaits.',
    'Make tonight better with movies.',
    'Find a story that stays.',
    'Explore something exciting today.',
    'Some movies become lasting memories.',
    'Every mood deserves the right movie.',
    'Discover your next memorable experience.',
    'There is always something worth watching.',
    'Find movies that match your mood.',
    'Let a great story surprise you.',
    'Your next favorite could be here.',
    'Take a break and enjoy.',
    'Discover stories you have missed.',
    'Good movies make evenings feel better.',
    'Find something worth watching tonight.',
    'Every screen holds another adventure.',
    'Explore stories made for movie lovers.',
    'Your perfect movie might await.',
    'Discover something different this evening.',
    'Great stories never truly get old.',
    'Find your next movie obsession.',
    'Make your free time memorable.',
    'Every movie has something special.',
    'Discover moments worth sharing together.',
    'Find entertainment for every kind mood.',
    'Tonight could use a great story.',
    'Explore movies everyone loves talking about.',
    'Find something that fits tonight.',
    'Stories can change the whole mood.',
    'Discover movies beyond your usual choices.',
    'Your next adventure starts here.',
    'Find a movie worth remembering.',
    'Enjoy stories that bring people together.',
    'Discover something worth coming back to.',
    'Every night needs a good movie.',
    'Find your next cinematic favorite.',
    'More stories, more choices, more discovery.',
  ];

  @override
  void initState() {
    super.initState();

    // Change quote every 30 minutes.
    _subtitleTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) {
        if (!mounted) return;

        setState(() {
          // After the last quote, start again
          // from the first quote.
          _subtitleIndex =
              (_subtitleIndex + 1) % _subtitles.length;
        });
      },
    );
  }

  @override
  void dispose() {
    _subtitleTimer?.cancel();
    super.dispose();
  }

  // ======================================================
  // BUILD HOME SCREEN
  // ======================================================

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
              // ======================================================
              // HEADER
              // ======================================================

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    8,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Salam, ${auth.name} 👋',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // ==================================================
                      // ROTATING QUOTE
                      // ==================================================

                      AnimatedSwitcher(
                        duration: const Duration(
                          milliseconds: 500,
                        ),
                        transitionBuilder:
                            (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          _subtitles[_subtitleIndex],
                          key: ValueKey(_subtitleIndex),
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ======================================================
              // HOME CONTENT
              // ======================================================

              if (home.loading)
                const SliverToBoxAdapter(
                  child: ShimmerPlaceholder(
                    height: 300,
                  ),
                )
              else if (home.error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorState(
                    message: home.error!,
                    onRetry: home.load,
                  ),
                )
              else ...[
                // ======================================================
                // FEATURED CAROUSEL
                // ======================================================

                SliverToBoxAdapter(
                  child: _FeaturedCarousel(
                    items: home.trending.take(5).toList(),
                  ),
                ),

                // ======================================================
                // TRENDING NOW
                // ======================================================

                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Trending Now',
                    actionLabel: 'See All',
                    onAction: () =>
                        Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const ExploreScreen(),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: HorizontalMediaList(
                    items: home.trending,
                    showNavArrows: true,
                  ),
                ),

                // ======================================================
                // POPULAR MOVIES
                // ======================================================

                const SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Popular Movies',
                  ),
                ),

                SliverToBoxAdapter(
                  child: HorizontalMediaList(
                    items: home.popularMovies,
                    showNavArrows: true,
                  ),
                ),

                // ======================================================
                // POPULAR SERIES
                // ======================================================

                const SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Popular Series',
                  ),
                ),

                SliverToBoxAdapter(
                  child: HorizontalMediaList(
                    items: home.popularTv,
                    showNavArrows: true,
                  ),
                ),

                // ======================================================
                // TOP RATED
                // ======================================================

                const SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Top Rated',
                  ),
                ),

                SliverToBoxAdapter(
                  child: HorizontalMediaList(
                    items: home.topRated,
                    showNavArrows: true,
                  ),
                ),

                // ======================================================
                // BOTTOM SPACING
                // ======================================================

                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// FEATURED CAROUSEL
// ======================================================

class _FeaturedCarousel extends StatefulWidget {
  const _FeaturedCarousel({
    required this.items,
  });

  final List<MediaItem> items;

  @override
  State<_FeaturedCarousel> createState() =>
      _FeaturedCarouselState();
}

class _FeaturedCarouselState
    extends State<_FeaturedCarousel> {
  final PageController controller = PageController(
    viewportFraction: 0.88,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 330,
      child: PageView.builder(
        controller: controller,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];

          return Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 6,
              top: 20,
            ),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                DetailsScreen.routeName,
                arguments: item,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: BackdropImage(
                  path: item.backdropPath ??
                      item.posterPath,
                  height: 330,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // ==================================================
                      // MOVIE INFORMATION
                      // ==================================================

                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            20,
                            20,
                            20,
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.end,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // ==================================================
                              // TRENDING LABEL
                              // ==================================================

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  borderRadius:
                                      BorderRadius.circular(8),
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

                              // ==================================================
                              // MOVIE TITLE
                              // WHITE IN BOTH LIGHT + DARK MODE
                              // ==================================================

                              Text(
                                item.title,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  height: 1.05,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // ==================================================
                              // RATING / YEAR / TYPE
                              // WHITE IN BOTH LIGHT + DARK MODE
                              // ==================================================

                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFFC857),
                                    size: 18,
                                  ),

                                  const SizedBox(width: 4),

                                  Text(
                                    item.rating
                                        .toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Text(
                                    item.year,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Flexible(
                                    child: Text(
                                      item.typeLabel,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // ==================================================
                              // DETAILS BUTTON
                              // ==================================================

                              SizedBox(
                                height: 40,
                                width: 120,
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.pushNamed(
                                    context,
                                    DetailsScreen.routeName,
                                    arguments: item,
                                  ),
                                  style: ButtonStyle(
                                    side: WidgetStateProperty
                                        .resolveWith<
                                            BorderSide>(
                                      (states) {
                                        if (states.contains(
                                          WidgetState.hovered,
                                        )) {
                                          return BorderSide(
                                            color: Theme.of(
                                                    context)
                                                .colorScheme
                                                .primary,
                                            width: 1.5,
                                          );
                                        }

                                        return BorderSide(
                                          color: Theme.of(
                                                  context)
                                              .colorScheme
                                              .outline
                                              .withValues(
                                                alpha: 0.7,
                                              ),
                                        );
                                      },
                                    ),
                                    backgroundColor:
                                        WidgetStateProperty
                                            .resolveWith<
                                                Color?>(
                                      (states) {
                                        if (states.contains(
                                          WidgetState.hovered,
                                        )) {
                                          return Theme.of(
                                                  context)
                                              .colorScheme
                                              .primary
                                              .withValues(
                                                alpha: 0.12,
                                              );
                                        }

                                        return null;
                                      },
                                    ),
                                    overlayColor:
                                        WidgetStateProperty.all(
                                      Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(
                                            alpha: 0.08,
                                          ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Details',
                                  ),
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