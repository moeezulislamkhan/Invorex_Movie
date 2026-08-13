import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/app_config.dart';
import 'models/media_item.dart';
import 'providers/auth_provider.dart';
import 'providers/explore_provider.dart';
import 'providers/home_provider.dart';
import 'providers/watchlist_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/details_screen.dart';
import 'screens/splash_screen.dart';
import 'services/local_storage_service.dart';
import 'services/mux_video_api_service.dart';
import 'services/tmdb_api_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final storage = LocalStorageService();
  final auth = AuthProvider(storage);
  await auth.load();

  final api = TmdbApiService();
  final muxApi = MuxVideoApiService();

  final theme = ThemeProvider(storage);
  await theme.load();

  runApp(
    MultiProvider(
      providers: [
        Provider<LocalStorageService>.value(value: storage),
        Provider<TmdbApiService>.value(value: api),
        Provider<MuxVideoApiService>.value(value: muxApi),
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider<ThemeProvider>.value(value: theme),
        ChangeNotifierProvider(create: (_) => HomeProvider(api)),
        ChangeNotifierProvider(create: (_) => ExploreProvider(api)),
        ChangeNotifierProvider(create: (_) => WatchlistProvider(storage)),
      ],
      child: const InvorexMoviesApp(),
    ),
  );
}

class InvorexMoviesApp extends StatelessWidget {
  const InvorexMoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == DetailsScreen.routeName) {
          final item = settings.arguments;
          if (item is! MediaItem) {
            return null;
          }
          return MaterialPageRoute(
            builder: (_) => DetailsScreen(item: item),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
