import 'package:flutter_test/flutter_test.dart';

import 'package:tower_defence_code/main.dart';

void main() {
  testWidgets('Text is Displayed Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TowerDefenceApp());

    expect(find.text('Tower Defence'), findsOneWidget);

  });
}
