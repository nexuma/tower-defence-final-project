/// A number of enemies of one kind, spawned one after another.
class SpawnGroup {
  const SpawnGroup({
    required this.enemyKey,
    required this.count,
    required this.secondsBetween,
  });

  /// Which `EnemyDefinition` to spawn.
  final String enemyKey;

  /// How many enemies to spawn.
  final int count;

  /// Seconds between two spawns.
  final double secondsBetween;
}

/// One wave: its groups are spawned in order.
class Wave {
  const Wave(this.groups);

  final List<SpawnGroup> groups;
}
