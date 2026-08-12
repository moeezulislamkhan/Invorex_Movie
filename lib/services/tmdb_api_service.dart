import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/episode.dart';
import '../models/media_details.dart';
import '../models/media_item.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TmdbApiService {
  TmdbApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${AppConfig.tmdbBearerToken}',
        'Accept': 'application/json',
      };

  Future<dynamic> _get(
    String path, {
    Map<String, String> query = const {},
  }) async {
    if (!AppConfig.isApiConfigured) {
      throw ApiException(
        'TMDB is not configured. Add your Bearer token in '
        'lib/config/app_config.dart.',
      );
    }

    final uri = Uri.parse('${AppConfig.tmdbBaseUrl}$path').replace(
      queryParameters: {
        'language': 'en-US',
        ...query,
      },
    );

    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'The movie service returned ${response.statusCode}.',
        );
      }

      return jsonDecode(response.body);
    } on TimeoutException {
      throw ApiException(
        'The request took too long. Please check your network and try again.',
      );
    } on FormatException {
      throw ApiException('The server returned invalid data.');
    } on http.ClientException {
      throw ApiException(
        'Could not connect to the movie service. Please try again.',
      );
    }
  }

  Future<List<MediaItem>> _list(
    String path, {
    MediaType? forcedType,
    Map<String, String> query = const {},
  }) async {
    final data = await _get(path, query: query) as Map<String, dynamic>;
    final results = (data['results'] as List?) ?? const [];
    return results
        .whereType<Map>()
        .map((item) => MediaItem.fromJson(
              Map<String, dynamic>.from(item),
              forcedType: forcedType,
            ))
        .where((item) => item.id != 0)
        .toList();
  }

  Future<List<MediaItem>> trending() async {
    return _list('/trending/all/week');
  }

  Future<List<MediaItem>> popularMovies() async {
    return _list('/movie/popular', forcedType: MediaType.movie);
  }

  Future<List<MediaItem>> popularTv() async {
    return _list('/tv/popular', forcedType: MediaType.tv);
  }

  Future<List<MediaItem>> topRatedMovies() async {
    return _list('/movie/top_rated', forcedType: MediaType.movie);
  }

  Future<List<MediaItem>> upcomingMovies() async {
    return _list('/movie/upcoming', forcedType: MediaType.movie);
  }

  Future<List<MediaItem>> searchMovies(String query) async {
    return _list(
      '/search/movie',
      forcedType: MediaType.movie,
      query: {'query': query},
    );
  }

  Future<List<MediaItem>> searchTv(String query) async {
    return _list(
      '/search/tv',
      forcedType: MediaType.tv,
      query: {'query': query},
    );
  }

  Future<List<MediaItem>> searchMulti(String query) async {
    final results = await _list('/search/multi', query: {'query': query});
    return results
        .where((item) => item.type == MediaType.movie || item.type == MediaType.tv)
        .toList();
  }

  Future<MediaDetails> getDetails(
    int id,
    MediaType type,
  ) async {
    final namespace = type == MediaType.movie ? 'movie' : 'tv';
    final data = await _get(
      '/$namespace/$id',
      query: {
        'append_to_response': 'credits,videos,similar',
      },
    ) as Map<String, dynamic>;

    return MediaDetails.fromJson(data, type: type);
  }

  Future<List<Episode>> getSeason(
    int seriesId,
    int seasonNumber,
  ) async {
    final data = await _get('/tv/$seriesId/season/$seasonNumber')
        as Map<String, dynamic>;
    final episodes = (data['episodes'] as List?) ?? const [];
    return episodes
        .whereType<Map>()
        .map((e) => Episode.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
