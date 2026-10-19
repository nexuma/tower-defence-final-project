int calculateDamage(
  double towerX,
  double towerY,
  double enemyX,
  double enemyY,
  int enemyHealth,
) {
  final dx = towerX - enemyX;
  final dy = towerY - enemyY;
  final distanceSquared = dx * dx + dy * dy;
  if (enemyHealth <= 0 || distanceSquared > 2500) {
    return 0;
  }
  return 10;
}
