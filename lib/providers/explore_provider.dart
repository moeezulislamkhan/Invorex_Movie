import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/media_item.dart';
import '../services/tmdb_api_service.dart';

enum ExploreCategory { movies, tv, trending, popular, topRated, upcoming }

class ExploreProvider extends ChangeNotifier {
  ExploreProvider(this._api);

  final TmdbApiService _api;
  Timer? _debounce;

  ExploreCategory category = ExploreCategory.trending;
  String query = '';
  bool loading = false;
  String? error;
  List<MediaItem> results = [];

  Future<void> setCategory(ExploreCategory value) async {
    category = value;
    query = '';
    await load();
  }

  void setQuery(String value) {
    query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (query.trim().isEmpty) {
        load();
      } else {
        search();
      }
    });
    notifyListeners();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      switch (category) {
        case ExploreCategory.movies:
          results = await _api.popularMovies();
          break;
        case ExploreCategory.tv:
          results = await _api.popularTv();
          break;
        case ExploreCategory.trending:
          results = await _api.trending();
          break;
        case ExploreCategory.popular:
          results = [
            ...await _api.popularMovies(),
            ...await _api.popularTv(),
          ];
          break;
        case ExploreCategory.topRated:
          results = await _api.topRatedMovies();
          break;
        case ExploreCategory.upcoming:
          results = await _api.upcomingMovies();
          break;
      }
    } catch (e) {
      error = e.toString().replaceFirst('ApiException: ', '');
      results = [];
    }

    loading = false;
    notifyListeners();
  }

  Future<void> search() async {
    if (query.trim().isEmpty) {
      return load();
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      results = await _api.searchMulti(query.trim());
    } catch (e) {
      error = e.toString().replaceFirst('ApiException: ', '');
      results = [];
    }

    loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
