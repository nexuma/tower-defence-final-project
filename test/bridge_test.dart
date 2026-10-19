import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defence/bridge/bridge_models.dart';
import 'package:tower_defence/bridge/sandbox_runner.dart';
import 'package:tower_defence/game/tower_defence_game.dart';
import 'package:tower_defence/main.dart';

void main() {
  const script = '''
int calculateDamage(
  double towerX,
  double towerY,
  double enemyX,
  double enemyY,
  int enemyHealth,
) {
  final dx = towerX - enemyX;
  final dy = towerY - enemyY;
  final distanceSquared = dx * dx + dy * dy;
  if (enemyHealth <= 0 || distanceSquared > 2500) {
    return 0;
  }
  return 10;
}
''';
  final sandbox = DamageSandbox(script);

  test('returns damage for an in-range living enemy', () {
    final instruction = sandbox.evaluate(
      const CombatState(
        towerX: 0,
        towerY: 0,
        enemyX: 10,
        enemyY: 10,
        enemyHealth: 100,
      ),
    );

    expect(instruction.damage, 10);
  });

  test('returns no damage for an out-of-range enemy', () {
    final instruction = sandbox.evaluate(
      const CombatState(
        towerX: 0,
        towerY: 0,
        enemyX: 100,
        enemyY: 100,
        enemyHealth: 100,
      ),
    );

    expect(instruction.damage, 0);
  });

  test('rejects invalid combat state before evaluation', () {
    expect(
      () => sandbox.evaluate(
        const CombatState(
          towerX: double.nan,
          towerY: 0,
          enemyX: 0,
          enemyY: 0,
          enemyHealth: 100,
        ),
      ),
      throwsA(isA<SandboxEvaluationException>()),
    );
  });

  test('enemy advances toward the tower and stops at firing range', () {
    final enemy = EnemyComponent(position: Vector2(0, 0), health: 100);
    final towerPosition = Vector2(100, 0);

    enemy.advanceToward(towerPosition, dt: 1, speed: 80, stopDistance: 50);
    expect(enemy.position.x, 50);

    enemy.advanceToward(towerPosition, dt: 1, speed: 80, stopDistance: 50);
    expect(enemy.position.x, 50);
  });

  testWidgets('loads the damage module from the bundled asset', (tester) async {
    final assetSandbox = await DamageSandbox.fromAsset();
    final instruction = assetSandbox.evaluate(
      const CombatState(
        towerX: 0,
        towerY: 0,
        enemyX: 10,
        enemyY: 10,
        enemyHealth: 100,
      ),
    );

    expect(instruction.damage, 10);
  });

  testWidgets('renders the Flame game widget', (tester) async {
    await tester.pumpWidget(const TowerDefenceApp());
    await tester.pump();
    expect(
      find.byWidgetPredicate((widget) => widget is GameWidget),
      findsOneWidget,
    );
  });
}
