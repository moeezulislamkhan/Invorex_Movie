import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/media_item.dart';
import '../providers/explore_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/poster_image.dart';
import '../widgets/shimmer_placeholder.dart';
import 'details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExploreProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: searchController,
              onChanged: provider.setQuery,
              decoration: InputDecoration(
                hintText: 'Search movies or series...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          provider.setQuery('');
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              children: [
                _chip(provider, 'Movies', ExploreCategory.movies),
                _chip(provider, 'TV Series', ExploreCategory.tv),
                _chip(provider, 'Trending', ExploreCategory.trending),
                _chip(provider, 'Popular', ExploreCategory.popular),
                _chip(provider, 'Top Rated', ExploreCategory.topRated),
                _chip(provider, 'Upcoming', ExploreCategory.upcoming),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: provider.loading
                  ? const ShimmerPlaceholder(height: 500)
                  : provider.error != null
                      ? ErrorState(
                          message: provider.error!,
                          onRetry: provider.load,
                        )
                      : provider.results.isEmpty
                          ? const EmptyState(
                              title: 'No results found',
                              message:
                                  'Try another title or switch to a different category.',
                            )
                          : _ResultGrid(items: provider.results),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    ExploreProvider provider,
    String label,
    ExploreCategory category,
  ) {
    final selected = provider.category == category && provider.query.isEmpty;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => provider.setCategory(category),
      ),
    );
  }
}

class _ResultGrid extends StatelessWidget {
  const _ResultGrid({required this.items});

  final List<MediaItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 190,
        mainAxisExtent: 280,
        crossAxisSpacing: 14,
        mainAxisSpacing: 18,
      ),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            DetailsScreen.routeName,
            arguments: item,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PosterImage(
                  path: item.posterPath,
                  width: double.infinity,
                  borderRadius: 18,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC857)),
                  const SizedBox(width: 3),
                  Text(item.rating.toStringAsFixed(1)),
                  const SizedBox(width: 8),
                  Text(item.year, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
