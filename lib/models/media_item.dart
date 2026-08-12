enum MediaType { movie, tv }

class MediaItem {
  const MediaItem({
    required this.id,
    required this.type,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.rating,
    required this.releaseDate,
    required this.genreIds,
    this.popularity = 0,
    this.muxVideoId,
  });

  final int id;
  final MediaType type;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double rating;
  final String releaseDate;
  final List<int> genreIds;
  final double popularity;
  final String? muxVideoId;

  factory MediaItem.fromJson(
    Map<String, dynamic> json, {
    MediaType? forcedType,
  }) {
    final type = forcedType ??
        (json['media_type'] == 'tv' ? MediaType.tv : MediaType.movie);

    return MediaItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: type,
      title: (json['title'] ?? json['name'] ?? 'Untitled').toString(),
      overview: (json['overview'] ?? '').toString(),
      posterPath: json['poster_path']?.toString(),
      backdropPath: json['backdrop_path']?.toString(),
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0,
      releaseDate:
          (json['release_date'] ?? json['first_air_date'] ?? '').toString(),
      genreIds: (json['genre_ids'] as List?)
              ?.whereType<num>()
              .map((e) => e.toInt())
              .toList() ??
          const [],
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0,
    );
  }

  String get year =>
      releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '—';

  String get typeLabel => type == MediaType.movie ? 'Movie' : 'Series';

  String get watchlistKey => '${type.name}_$id';
}
