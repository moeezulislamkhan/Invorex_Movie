class AppConfig {
  AppConfig._();

  static const String appName = 'Invorex Movies';

  static const String tmdbBearerToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhNTBhZDI1MTc5YWZlMDlhOThjMzJmNTMxNGFjYWFiMSIsIm5iZiI6MTc4NjM4Mjc1OC42MjQsInN1YiI6IjZhN2EwOWE2MTU0ZTAwMzM4YjkwZGNjMyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.U1rVs9VavKJrYWZfyACmrcBLiT8d5w0StskyQIP0LEs';
  static const String tmdbApiKey = 'a50ad25179afe09a98c32f5314acaab1';
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';

  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/';
  static const String posterSize = 'w500';
  static const String backdropSize = 'w1280';

  static bool get isApiConfigured =>
      tmdbBearerToken.trim().isNotEmpty &&
      !tmdbBearerToken.contains('PASTE_YOUR');
}
