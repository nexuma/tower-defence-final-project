import 'position.dart';

/// Shared data for one kind of projectile, such as "arrow" or "boulder" (AD-6).
class ProjectileDefinition {
  const ProjectileDefinition({
    required this.key,
    required this.damage,
    required this.hitRadius,
    required this.hitsAll,
    required this.flightTime,
  });

  /// Stable ID.
  final String key;

  /// Base damage per hit, before the tower's multiplier (AD-11).
  final double damage;

  /// In cells: the size of the hit circle at impact (AD-10).
  final double hitRadius;

  /// false: one enemy is hit; true: every overlapping enemy is hit.
  final bool hitsAll;

  /// Seconds from firing to impact (fixed).
  final double flightTime;
}

/// One projectile in the air (AD-9).
class PendingShot {
  PendingShot({
    required this.towerId,
    required this.projectileKey,
    required this.targetEnemyId,
    required this.damage,
    required this.timeUntilImpact,
    required this.lastKnownTargetPosition,
  });

  /// Who fired it: the animation's start point, and telemetry.
  final int towerId;

  /// What it is: the hit rule and the animation.
  final String projectileKey;

  /// The enemy it is aimed at.
  final int targetEnemyId;

  /// Worked out when fired (AD-11).
  final double damage;

  /// Seconds; the shot is resolved when this reaches 0.
  double timeUntilImpact;

  /// Updated every tick while the target is alive (AD-10).
  Position lastKnownTargetPosition;
}
