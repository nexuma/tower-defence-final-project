import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defence_code/combat_logic/combat_types.dart';
import 'package:tower_defence_code/combat_logic/native_combat_logic.dart';

void main() {
  const logic = NativeCombatLogic();
  const tower = CombatTower(
    id: 1,
    x: 0,
    y: 0,
    range: 3,
    baseDamage: 10,
    damageMultiplier: 1.5,
  );

  CombatEnemy enemy(int id, double x, double distance) =>
      CombatEnemy(id: id, x: x, y: 0, distanceTravelled: distance, health: 100);

  test('targets the enemy in range that is furthest along the path', () {
    final decisions = logic.decideShots(
      CombatRequest(
        readyTowers: const [tower],
        enemies: [enemy(1, 1, 5), enemy(2, 2, 8), enemy(3, 9, 20)],
      ),
    );
    expect(decisions, hasLength(1));
    expect(decisions.single.targetEnemyId, 2); // 3 is further but out of range
  });

  test('damage is base damage times the multiplier (AD-11)', () {
    final decisions = logic.decideShots(
      CombatRequest(readyTowers: const [tower], enemies: [enemy(1, 1, 0)]),
    );
    expect(decisions.single.damage, 15);
  });

  test('no decision when no enemy is in range', () {
    final decisions = logic.decideShots(
      CombatRequest(readyTowers: const [tower], enemies: [enemy(1, 5, 0)]),
    );
    expect(decisions, isEmpty);
  });
}
