// Combat logic script, run by dart_eval (SandboxCombatLogic).
//
// Targeting: "strongest", the enemy in range with the most health.
// Damage: base damage × the tower's multiplier.
//
// Input and output: see first_targeting.dart.

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
      if (inRange && (best < 0 || enemies[e + 4] > enemies[best + 4])) {
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
