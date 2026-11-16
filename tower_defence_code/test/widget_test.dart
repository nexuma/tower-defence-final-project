import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:tower_defence_code/main.dart';

void main() {
  testWidgets('app shows the Tower Defence game', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TowerDefenceApp());

    expect(find.byType(GameWidget<TowerDefenceGame>), findsOneWidget);
  });
}
