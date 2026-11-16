/// Shared data for one kind of tower, such as "archer" or "catapult" (AD-6).
class TowerDefinition {
  const TowerDefinition({
    required this.key,
    required this.name,
    required this.range,
    required this.cooldown,
    required this.damageMultiplier,
    required this.projectileKey,
  });

  /// Stable ID, used by telemetry and by the view's sprite lookup.
  final String key;

  /// Display name shown in the tower selector.
  final String name;

  /// In cells: enemies within this distance can be targeted.
  final double range;

  /// Seconds between shots.
  final double cooldown;

  /// Multiplies the projectile's base damage (AD-11).
  final double damageMultiplier;

  /// Which [ProjectileDefinition] this tower fires.
  final String projectileKey;
}

/// One placed tower. Its location is stored in `GameState.towerCells` (AD-7).
class Tower {
  Tower({
    required this.id,
    required this.definitionKey,
    this.timeUntilNextShot = 0,
  });

  /// Incrementing integer issued by the engine (AD-8).
  final int id;

  /// Which [TowerDefinition] this tower is.
  final String definitionKey;

  /// Seconds; counts down during play. The tower can fire at 0.
  double timeUntilNextShot;
}
