import 'package:flutter_test/flutter_test.dart';

import 'package:invorex_movies/main.dart';

void main() {
  testWidgets('Invorex Movies app boots', (tester) async {
    await tester.pumpWidget(const InvorexMoviesApp());
    expect(find.text('Invorex Movies'), findsOneWidget);
  });
}
