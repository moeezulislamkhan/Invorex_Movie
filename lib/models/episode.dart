class Episode {
  const Episode({
    required this.id,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.name,
    required this.overview,
    required this.stillPath,
    required this.runtime,
    required this.airDate,
  });

  final int id;
  final int episodeNumber;
  final int seasonNumber;
  final String name;
  final String overview;
  final String? stillPath;
  final int? runtime;
  final String airDate;

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: (json['id'] as num?)?.toInt() ?? 0,
      episodeNumber: (json['episode_number'] as num?)?.toInt() ?? 0,
      seasonNumber: (json['season_number'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? 'Untitled Episode').toString(),
      overview: (json['overview'] ?? '').toString(),
      stillPath: json['still_path']?.toString(),
      runtime: (json['runtime'] as num?)?.toInt(),
      airDate: (json['air_date'] ?? '').toString(),
    );
  }
}
