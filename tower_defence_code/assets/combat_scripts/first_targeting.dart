// Combat logic script, run by dart_eval (SandboxCombatLogic).
//
// Targeting: "first", the enemy in range that is furthest along the path.
// Damage: base damage × the tower's multiplier.
//
// Input (flat lists of numbers, AD-17):
//   towers:  6 numbers per ready tower: id, x, y, range, baseDamage, multiplier
//   enemies: 5 numbers per enemy:       id, x, y, distanceTravelled, health
// Output:
//   3 numbers per shot: towerId, targetEnemyId, damage

List<double> decideShots(List<double> towers, List<double> enemies) {
  final shots = <double>[];
  for (var t = 0; t < towers.length; t += 6) {
    final x = towers[t + 1];
    final y = towers[t + 2];
    final range = towers[t + 3];
    var best = -1;
    for (var e = 0; e < enemies.length; e += 5) {
      final dx = enemies[e + 1] - x;
      final dy = enemies[e + 2] - y;
      final inRange = dx * dx + dy * dy <= range * range;
      if (inRange && (best < 0 || enemies[e + 3] > enemies[best + 3])) {
        best = e;
      }
    }
    if (best >= 0) {
      shots.add(towers[t]);
      shots.add(enemies[best]);
      shots.add(towers[t + 4] * towers[t + 5]);
    }
  }
  return shots;
}
