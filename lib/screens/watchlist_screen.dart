import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/watchlist_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/poster_image.dart';
import 'details_screen.dart';
import 'explore_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<WatchlistProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Watchlist',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: watchlist.items.isEmpty
          ? EmptyState(
              title: 'Your watchlist is empty',
              message: 'Save movies and series here to find them later.',
              buttonLabel: 'Explore Movies',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExploreScreen()),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              itemCount: watchlist.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = watchlist.items[index];
                return Dismissible(
                  key: ValueKey(item.watchlistKey),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.delete_outline_rounded),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => watchlist.remove(item),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: PosterImage(
                        path: item.posterPath,
                        width: 68,
                        height: 92,
                        borderRadius: 12,
                      ),
                      title: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 15,
                              color: Color(0xFFFFC857),
                            ),
                            const SizedBox(width: 4),
                            Text(item.rating.toStringAsFixed(1)),
                            const SizedBox(width: 10),
                            Text(item.year),
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () => watchlist.remove(item),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        DetailsScreen.routeName,
                        arguments: item,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
