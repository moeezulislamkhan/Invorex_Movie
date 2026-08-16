import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/media_item.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../services/tmdb_api_service.dart';
import '../widgets/backdrop_image.dart';
import '../widgets/error_state.dart';
import '../widgets/horizontal_media_list.dart';
import '../widgets/section_header.dart';
import '../widgets/shimmer_placeholder.dart';
import 'details_screen.dart';
import 'explore_screen.dart';
import 'watch_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TmdbApiService _api = TmdbApiService();

  Timer? _searchDebounce;

  bool _isSearching = false;
  bool _searchLoading = false;
  String? _searchError;
  List<MediaItem> _searchResults = [];

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    final query = value.trim();

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchLoading = false;
        _searchError = null;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () => _performSearch(query),
    );
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
      _searchLoading = true;
      _searchError = null;
    });

    try {
      final results = await _api.searchMulti(query);

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _searchLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _searchResults = [];
        _searchLoading = false;
        _searchError =
            e.toString().replaceFirst('ApiException: ', '');
      });
    }
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();

    setState(() {
      _isSearching = false;
      _searchLoading = false;
      _searchError = null;
      _searchResults = [];
    });
  }

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
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // HOME SEARCH
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search movies, series...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: _clearSearch,
                                  icon: const Icon(
                                    Icons.close_rounded,
                                  ),
                                )
                              : Container(
                                  margin: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.16),
                                    borderRadius:
                                        BorderRadius.circular(11),
                                  ),
                                  child: const Icon(
                                    Icons.tune_rounded,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =========================
              // SEARCH RESULTS
              // =========================

              if (_isSearching)
                SliverToBoxAdapter(
                  child: _buildSearchSection(context),
                )

              // =========================
              // NORMAL HOME CONTENT
              // =========================

              else if (home.loading)
                const SliverToBoxAdapter(
                  child: ShimmerPlaceholder(height: 300),
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
                SliverToBoxAdapter(
                  child: _FeaturedCarousel(
                    items: home.trending.take(5).toList(),
                  ),
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
                  child: HorizontalMediaList(
                    items: home.trending,
                    showNavArrows: true,
                  ),
                ),

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

  Widget _buildSearchSection(BuildContext context) {
    if (_searchLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 30),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_searchError != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _searchError!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final query = _searchController.text.trim();

                if (query.isNotEmpty) {
                  _performSearch(query);
                }
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 45, 20, 20),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 55,
            ),
            SizedBox(height: 14),
            Text(
              'No movies or series found.',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Try searching with a different title.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Results',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_searchResults.length} results for "${_searchController.text.trim()}"',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 18),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _searchResults.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 18,
              childAspectRatio: 0.63,
            ),
            itemBuilder: (context, index) {
              final item = _searchResults[index];

              return _SearchResultCard(item: item);
            },
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.item,
  });

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          DetailsScreen.routeName,
          arguments: item,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropImage(
                path: item.posterPath,
                height: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFC857),
                size: 16,
              ),
              const SizedBox(width: 3),
              Text(
                item.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.typeLabel,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturedCarousel extends StatefulWidget {
  const _FeaturedCarousel({
    required this.items,
  });

  final List<MediaItem> items;

  @override
  State<_FeaturedCarousel> createState() =>
      _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  final controller = PageController(
    viewportFraction: 0.88,
  );

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
                  path: item.backdropPath ?? item.posterPath,
                  height: 330,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
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
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
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
                                  Text(
                                    item.rating
                                        .toStringAsFixed(1),
                                  ),
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
                                        onPressed: () =>
                                            Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                WatchScreen(
                                              title: item.title,
                                              videoId:
                                                  item.muxVideoId,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons
                                              .play_circle_filled_rounded,
                                          size: 18,
                                        ),
                                        label:
                                            const Text('Watch'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            Navigator.pushNamed(
                                          context,
                                          DetailsScreen.routeName,
                                          arguments: item,
                                        ),
                                        child: const Text(
                                          'Details',
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