import 'dart:math' as math;

import 'combat_logic.dart';
import 'combat_types.dart';

/// Combat logic in plain Dart: the baseline and fallback (AD-2).
///
/// Targeting is "first": the enemy in range that is furthest along the path.
/// Damage is base damage × the tower's multiplier (AD-11).
class NativeCombatLogic implements CombatLogic {
  const NativeCombatLogic();

  @override
  List<ShotDecision> decideShots(CombatRequest request) {
    final decisions = <ShotDecision>[];
    for (final tower in request.readyTowers) {
      CombatEnemy? target;
      for (final enemy in request.enemies) {
        final inRange = _distance(tower, enemy) <= tower.range;
        if (inRange &&
            (target == null ||
                enemy.distanceTravelled > target.distanceTravelled)) {
          target = enemy;
        }
      }
      if (target != null) {
        decisions.add(
          ShotDecision(
            towerId: tower.id,
            targetEnemyId: target.id,
            damage: tower.baseDamage * tower.damageMultiplier,
          ),
        );
      }
    }
    return decisions;
  }

  static double _distance(CombatTower tower, CombatEnemy enemy) {
    final dx = enemy.x - tower.x;
    final dy = enemy.y - tower.y;
    return math.sqrt(dx * dx + dy * dy);
  }
}
