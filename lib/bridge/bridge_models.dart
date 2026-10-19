class CombatState {
  const CombatState({
    required this.towerX,
    required this.towerY,
    required this.enemyX,
    required this.enemyY,
    required this.enemyHealth,
  });

  final double towerX;
  final double towerY;
  final double enemyX;
  final double enemyY;
  final int enemyHealth;

  List<Object> toSandboxArguments() => [
    towerX,
    towerY,
    enemyX,
    enemyY,
    enemyHealth,
  ];
}

class DamageInstruction {
  const DamageInstruction({required this.damage});

  final int damage;

  static DamageInstruction fromSandboxResult(Object? result) {
    if (result is! int || result < 0 || result > 100) {
      throw const FormatException('Sandbox returned an invalid damage value');
    }
    return DamageInstruction(damage: result);
  }
}

double distanceSquared(CombatState state) {
  final dx = state.towerX - state.enemyX;
  final dy = state.towerY - state.enemyY;
  return dx * dx + dy * dy;
}

bool isFiniteState(CombatState state) {
  return [
    state.towerX,
    state.towerY,
    state.enemyX,
    state.enemyY,
  ].every((value) => value.isFinite);
}
