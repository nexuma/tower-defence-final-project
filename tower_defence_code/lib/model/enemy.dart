/// Shared data for one kind of enemy (AD-6).
class EnemyDefinition {
  const EnemyDefinition({
    required this.key,
    required this.name,
    required this.maxHealth,
    required this.speed,
    required this.radius,
  });

  /// Stable ID.
  final String key;

  /// Display name.
  final String name;

  /// Health when spawned.
  final double maxHealth;

  /// Cells per second along the path.
  final double speed;

  /// In cells: the size of the hitbox (AD-10).
  final double radius;
}

/// One enemy on the board.
///
/// Its position is not stored: it is worked out from [distanceTravelled]
/// with `GameMap.positionAt`.
class Enemy {
  Enemy({
    required this.id,
    required this.definitionKey,
    required this.health,
    this.distanceTravelled = 0,
  });

  /// Incrementing integer issued by the engine.
  final int id;

  /// Which [EnemyDefinition] this enemy is.
  final String definitionKey;

  /// Current health; the enemy dies at 0 or below.
  double health;

  /// Cells walked along the path from its start.
  double distanceTravelled;
}
