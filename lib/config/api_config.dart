/// Central configuration for Invorex Movies APIs.
///
/// Keep secrets out of UI/screens. For a university prototype this is fine,
/// but for production move secrets to a secure backend/environment system.
class ApiConfig {
  ApiConfig._();

  // TMDB API Read Access Token (Bearer token) retained for metadata endpoints.
  static const String tmdbBearerToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhNTBhZDI1MTc5YWZlMDlhOThjMzJmNTMxNGFjYWFiMSIsIm5iZiI6MTc4NjM4Mjc1OC42MjQsInN1YiI6IjZhN2EwOWE2MTU0ZTAwMzM4YjkwZGNjMyIsInNjb3BlcyI6WyJhcGxfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.U1rVs9VavKJrYWZfyACmrcBLiT8d5w0StskyQIP0LEs';

  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';

  // Pakistan region for provider lookups where supported.
  static const String region = 'PK';

  static bool get hasTmdbToken =>
      tmdbBearerToken.trim().isNotEmpty &&
      !tmdbBearerToken.contains('PASTE_YOUR');
}
