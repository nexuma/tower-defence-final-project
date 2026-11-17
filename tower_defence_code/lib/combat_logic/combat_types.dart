// The data that crosses the CombatLogic boundary (AD-13).
//
// These types are CombatLogic's own: they do not import the model. The engine
// translates the model into a [CombatRequest] and applies the returned
// [ShotDecision]s. Positions are in cells.

/// A tower that is ready to fire.
class CombatTower {
  const CombatTower({
    required this.id,
    required this.x,
    required this.y,
    required this.range,
    required this.baseDamage,
    required this.damageMultiplier,
  });

  final int id;
  final double x;
  final double y;

  /// In cells.
  final double range;

  /// The damage of the projectile this tower fires.
  final double baseDamage;

  /// The tower's multiplier (AD-11).
  final double damageMultiplier;
}

/// An enemy on the board.
class CombatEnemy {
  const CombatEnemy({
    required this.id,
    required this.x,
    required this.y,
    required this.distanceTravelled,
    required this.health,
  });

  final int id;
  final double x;
  final double y;

  /// Cells walked along the path; larger means closer to the base.
  final double distanceTravelled;

  final double health;
}

/// Everything CombatLogic gets in one call.
class CombatRequest {
  const CombatRequest({required this.readyTowers, required this.enemies});

  /// Only the towers that can fire this tick.
  final List<CombatTower> readyTowers;

  /// Every enemy on the board.
  final List<CombatEnemy> enemies;
}

/// "Tower [towerId] fires at enemy [targetEnemyId] for [damage]."
class ShotDecision {
  const ShotDecision({
    required this.towerId,
    required this.targetEnemyId,
    required this.damage,
  });

  final int towerId;
  final int targetEnemyId;
  final double damage;
}
