import 'package:flutter/foundation.dart';

import '../models/media_item.dart';
import '../services/local_storage_service.dart';

class WatchlistProvider extends ChangeNotifier {
  WatchlistProvider(this._storage);

  final LocalStorageService _storage;

  final Map<String, MediaItem> _items = {};

  List<MediaItem> get items => _items.values.toList(growable: false);

  Future<void> load() async {
    final keys = await _storage.watchlistKeys;
    _items.clear();
    // Full media objects are saved separately so the watchlist remains usable
    // offline for previously saved items.
    for (final key in keys) {
      final data = await _storageItem(key);
      if (data != null) {
        _items[key] = data;
      }
    }
    notifyListeners();
  }

  Future<MediaItem?> _storageItem(String key) async {
    final raw = await _storageRaw(key);
    if (raw == null) return null;
    try {
      final parts = raw.split('|||');
      if (parts.length < 9) return null;
      return MediaItem(
        id: int.tryParse(parts[0]) ?? 0,
        type: parts[1] == 'tv' ? MediaType.tv : MediaType.movie,
        title: parts[2],
        overview: parts[3],
        posterPath: parts[4].isEmpty ? null : parts[4],
        backdropPath: parts[5].isEmpty ? null : parts[5],
        rating: double.tryParse(parts[6]) ?? 0,
        releaseDate: parts[7],
        genreIds: parts[8]
            .split(',')
            .where((e) => e.isNotEmpty)
            .map(int.parse)
            .toList(),
        popularity: parts.length > 9 ? double.tryParse(parts[9]) ?? 0 : 0,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> _storageRaw(String key) async {
    // Stored through a dedicated JSON-like string key using the same
    // SharedPreferences backend exposed by LocalStorageService.
    return await _storage.getCustomString('watch_item_$key');
  }

  bool contains(MediaItem item) => _items.containsKey(item.watchlistKey);

  Future<void> toggle(MediaItem item) async {
    final key = item.watchlistKey;
    if (_items.containsKey(key)) {
      _items.remove(key);
      await _storage.removeCustomString('watch_item_$key');
    } else {
      _items[key] = item;
      final encoded = [
        item.id,
        item.type.name,
        item.title,
        item.overview,
        item.posterPath ?? '',
        item.backdropPath ?? '',
        item.rating,
        item.releaseDate,
        item.genreIds.join(','),
        item.popularity,
      ].join('|||');
      await _storage.setCustomString('watch_item_$key', encoded);
    }

    await _storage.saveWatchlistKeys(_items.keys.toList());
    notifyListeners();
  }

  Future<void> remove(MediaItem item) async {
    final key = item.watchlistKey;
    _items.remove(key);
    await _storage.removeCustomString('watch_item_$key');
    await _storage.saveWatchlistKeys(_items.keys.toList());
    notifyListeners();
  }
}
