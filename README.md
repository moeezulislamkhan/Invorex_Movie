# Invorex Movies

A Flutter + Material 3 university project for movie/TV discovery.

## Final architecture

- **TMDB**: discovery, metadata, posters/backdrops, ratings, genres, cast, search, similar content and trailers.
- **Watchmode**: (removed) the app uses TMDB only for metadata and trailers.
- **Local storage**: mock authentication state and watchlist.
- **Flutter UI**: Home, Explore, Details, Watchlist, Profile and legal trailer/provider navigation.

## API setup

The app uses the TMDB API for all discovery, metadata, posters, backdrops, cast, genres, and trailer information.

Do not commit real production secrets to a public repository.

Pakistan is configured as:

```dart
static const String region = 'PK';
```

Provider availability depends on the API's current coverage and your account/plan.

## Run

```bash
flutter pub get
flutter run
```

## Important

Invorex Movies does not download, host, or provide pirated copyrighted movie files. Trailer playback and "Where to Watch" should use legal/authorized sources.
