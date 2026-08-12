import 'package:flutter/foundation.dart';

import '../models/media_item.dart';
import '../services/tmdb_api_service.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider(this._api);

  final TmdbApiService _api;

  bool loading = true;
  String? error;

  List<MediaItem> trending = [];
  List<MediaItem> popularMovies = [];
  List<MediaItem> popularTv = [];
  List<MediaItem> topRated = [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.trending(),
        _api.popularMovies(),
        _api.popularTv(),
        _api.topRatedMovies(),
      ]);

      trending = results[0];
      popularMovies = results[1];
      popularTv = results[2];
      topRated = results[3];
      loading = false;
    } catch (e) {
      loading = false;
      error = e.toString().replaceFirst('ApiException: ', '');
    }

    notifyListeners();
  }
}
