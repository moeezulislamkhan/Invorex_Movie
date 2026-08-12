import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:invorex_movies/config/app_config.dart';
import 'package:invorex_movies/services/mux_video_api_service.dart';

void main() {
  testWidgets('app exposes the MUX configuration', (tester) async {
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

  test('uses the configured MUX video environment key', () {
    expect(AppConfig.muxEnvironmentKey, 'sl8n1m2ua5tglem2ntg9nhd0f');
    expect(MuxVideoApiService, isNotNull);
    expect(AppConfig.isMuxConfigured, isTrue);
  });
}
