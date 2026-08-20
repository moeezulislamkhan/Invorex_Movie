import 'media_item.dart';

class MediaDetails extends MediaItem {
  MediaDetails({
    required super.id,
    required super.type,
    required super.title,
    required super.overview,
    required super.posterPath,
    required super.backdropPath,
    required super.rating,
    required super.releaseDate,
    required super.genreIds,
    super.popularity,
    this.runtime,
    this.genres = const [],
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.cast = const [],
    this.similar = const [],
    this.trailerKey,
  });

  final int? runtime;
  final List<String> genres;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final List<String> cast;
  final List<MediaItem> similar;
  final String? trailerKey;

  factory MediaDetails.fromJson(
    Map<String, dynamic> json, {
    required MediaType type,
  }) {
    final similarJson = ((json['similar']?['results'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => MediaItem.fromJson(
              Map<String, dynamic>.from(e),
              forcedType: type,
            ))
        .toList();

    final credits = ((json['credits']?['cast'] as List?) ?? const [])
        .whereType<Map>()
        .take(10)
        .map((e) => (e['name'] ?? '').toString())
        .where((e) => e.isNotEmpty)
        .toList();

    final videos = ((json['videos']?['results'] as List?) ?? const [])
        .whereType<Map>()
        .toList();

    String? trailerKey;
    for (final video in videos) {
      if (video['site'] == 'YouTube' &&
          video['type'] == 'Trailer' &&
          video['key'] is String) {
        trailerKey = video['key'] as String;
        break;
      }
    }

    final base = MediaItem.fromJson(json, forcedType: type);

    return MediaDetails(
      id: base.id,
      type: base.type,
      title: base.title,
      overview: base.overview,
      posterPath: base.posterPath,
      backdropPath: base.backdropPath,
      rating: base.rating,
      releaseDate: base.releaseDate,
      genreIds: base.genreIds,
      popularity: base.popularity,
      runtime: (json['runtime'] as num?)?.toInt(),
      genres: ((json['genres'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => (e['name'] ?? '').toString())
          .where((e) => e.isNotEmpty)
          .toList(),
      numberOfSeasons: (json['number_of_seasons'] as num?)?.toInt(),
      numberOfEpisodes: (json['number_of_episodes'] as num?)?.toInt(),
      cast: credits,
      similar: similarJson,
      trailerKey: trailerKey,
    );
  }
}
