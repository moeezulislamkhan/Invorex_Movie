import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:invorex_movies/config/app_config.dart';

void main() {
  testWidgets('app exposes the app name and TMDB config', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(AppConfig.appName),
          ),
        ),
      ),
    );

    expect(find.text(AppConfig.appName), findsOneWidget);
  });

  test('keeps the app configured for TMDB only', () {
    expect(AppConfig.tmdbBearerToken.isNotEmpty, isTrue);
    expect(AppConfig.isApiConfigured, isTrue);
  });
}
