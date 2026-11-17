import '../combat_logic/combat_logic.dart';
import '../combat_logic/combat_types.dart';
import '../model/enemy.dart';
import '../model/game_state.dart';
import '../model/position.dart';
import '../model/projectile.dart';

/// Applies the game rules and is the only part that changes the [GameState]
/// (AD-1, AD-2).
///
/// It does not know whether [CombatLogic] is native or sandboxed: the
/// implementation is passed in by `main.dart` (AD-12).
class GameEngine {
  GameEngine({required this.state, required this.combatLogic});

  final GameState state;
  final CombatLogic combatLogic;

  int _nextEnemyId = 1;

  /// Command: start spawning the next wave.
  ///
  /// Returns false, and changes nothing, if the game is over, a wave is
  /// already in progress, or every wave has been started.
  bool startNextWave() {
    if (state.status != GameStatus.playing ||
        state.waveInProgress ||
        state.wavesStarted >= state.waves.length) {
      return false;
    }
    state.wavesStarted++;
    state.waveInProgress = true;
    state.spawnGroupIndex = 0;
    state.spawnedInGroup = 0;
    state.timeUntilNextSpawn = 0;
    return true;
  }

  /// Advances the game by [dt] seconds. Does nothing once the game is over.
  void tick(double dt) {
    if (state.status != GameStatus.playing) return;
    _spawnEnemies(dt);
    _moveEnemies(dt);
    _updateShots(dt);
    _fireTowers(dt);
    _checkEnd();
  }

  // --- 1. Spawn ---------------------------------------------------------------

  bool get _currentWaveFullySpawned =>
      state.spawnGroupIndex >=
      state.waves[state.wavesStarted - 1].groups.length;

  void _spawnEnemies(double dt) {
    if (!state.waveInProgress) return;
    final groups = state.waves[state.wavesStarted - 1].groups;
    state.timeUntilNextSpawn -= dt;
    while (state.spawnGroupIndex < groups.length &&
        state.timeUntilNextSpawn <= 0) {
      final group = groups[state.spawnGroupIndex];
      if (state.spawnedInGroup < group.count) {
        final definition = state.enemyDefinitions[group.enemyKey]!;
        final enemy = Enemy(
          id: _nextEnemyId++,
          definitionKey: definition.key,
          health: definition.maxHealth,
        );
        state.enemies[enemy.id] = enemy;
        state.spawnedInGroup++;
        state.timeUntilNextSpawn += group.secondsBetween;
      }
      if (state.spawnedInGroup >= group.count) {
        state.spawnGroupIndex++;
        state.spawnedInGroup = 0;
      }
    }
  }

  // --- 2. Move ----------------------------------------------------------------

  void _moveEnemies(double dt) {
    for (final enemy in state.enemies.values.toList()) {
      final definition = state.enemyDefinitions[enemy.definitionKey]!;
      enemy.distanceTravelled += definition.speed * dt;
      if (enemy.distanceTravelled >= state.map.pathLength) {
        state.enemies.remove(enemy.id);
        state.lives--;
      }
    }
  }

  // --- 3. Shots ---------------------------------------------------------------

  void _updateShots(double dt) {
    final landed = <PendingShot>[];
    for (final shot in state.shots) {
      final target = state.enemies[shot.targetEnemyId];
      if (target != null) {
        shot.lastKnownTargetPosition = _positionOf(target);
      }
      shot.timeUntilImpact -= dt;
      if (shot.timeUntilImpact <= 0) landed.add(shot);
    }
    for (final shot in landed) {
      state.shots.remove(shot);
      _resolveImpact(shot);
    }
  }

  /// AD-10: hit circle at the last known target position; enemies whose
  /// hitbox overlaps it can be hit.
  void _resolveImpact(PendingShot shot) {
    final projectile = state.projectileDefinitions[shot.projectileKey]!;
    final impact = shot.lastKnownTargetPosition;

    final overlapping = <Enemy>[];
    for (final enemy in state.enemies.values) {
      final radius = state.enemyDefinitions[enemy.definitionKey]!.radius;
      if (_positionOf(enemy).distanceTo(impact) <=
          projectile.hitRadius + radius) {
        overlapping.add(enemy);
      }
    }
    if (overlapping.isEmpty) return;

    final List<Enemy> hit;
    if (projectile.hitsAll) {
      hit = overlapping;
    } else {
      final target = state.enemies[shot.targetEnemyId];
      hit = [
        target != null && overlapping.contains(target)
            ? target
            : _nearestTo(impact, overlapping),
      ];
    }

    for (final enemy in hit) {
      enemy.health -= shot.damage;
      if (enemy.health <= 0) state.enemies.remove(enemy.id);
    }
  }

  Enemy _nearestTo(Position point, List<Enemy> enemies) {
    var nearest = enemies.first;
    for (final enemy in enemies.skip(1)) {
      if (_positionOf(enemy).distanceTo(point) <
          _positionOf(nearest).distanceTo(point)) {
        nearest = enemy;
      }
    }
    return nearest;
  }

  // --- 4. Towers --------------------------------------------------------------

  void _fireTowers(double dt) {
    final readyTowers = <CombatTower>[];
    for (final tower in state.towers.values) {
      if (tower.timeUntilNextShot > 0) {
        tower.timeUntilNextShot -= dt;
        if (tower.timeUntilNextShot < 0) tower.timeUntilNextShot = 0;
      }
      if (tower.timeUntilNextShot <= 0) {
        final definition = state.towerDefinitions[tower.definitionKey]!;
        final projectile =
            state.projectileDefinitions[definition.projectileKey]!;
        final position = _positionOfTower(tower.id);
        readyTowers.add(
          CombatTower(
            id: tower.id,
            x: position.x,
            y: position.y,
            range: definition.range,
            baseDamage: projectile.damage,
            damageMultiplier: definition.damageMultiplier,
          ),
        );
      }
    }
    if (readyTowers.isEmpty || state.enemies.isEmpty) return;

    final enemies = [
      for (final enemy in state.enemies.values)
        _toCombatEnemy(enemy, _positionOf(enemy)),
    ];
    final decisions = combatLogic.decideShots(
      CombatRequest(readyTowers: readyTowers, enemies: enemies),
    );
    _applyDecisions(decisions, readyTowers);
  }

  /// Checks every decision before applying it, so faulty combat logic cannot
  /// break the rules. Invalid decisions are ignored.
  void _applyDecisions(
    List<ShotDecision> decisions,
    List<CombatTower> readyTowers,
  ) {
    final ready = {for (final tower in readyTowers) tower.id: tower};
    for (final decision in decisions) {
      final combatTower = ready.remove(decision.towerId); // one shot per tower
      final target = state.enemies[decision.targetEnemyId];
      if (combatTower == null ||
          target == null ||
          !decision.damage.isFinite ||
          decision.damage < 0) {
        continue;
      }
      final targetPosition = _positionOf(target);
      final towerPosition = Position(combatTower.x, combatTower.y);
      if (towerPosition.distanceTo(targetPosition) > combatTower.range) {
        continue;
      }

      final tower = state.towers[decision.towerId]!;
      final definition = state.towerDefinitions[tower.definitionKey]!;
      final projectile = state.projectileDefinitions[definition.projectileKey]!;
      state.shots.add(
        PendingShot(
          towerId: tower.id,
          projectileKey: projectile.key,
          targetEnemyId: target.id,
          damage: decision.damage,
          timeUntilImpact: projectile.flightTime,
          lastKnownTargetPosition: targetPosition,
        ),
      );
      tower.timeUntilNextShot = definition.cooldown;
    }
  }

  // --- 5. End -----------------------------------------------------------------

  void _checkEnd() {
    if (state.lives <= 0) {
      state.lives = 0;
      state.status = GameStatus.lost;
      return;
    }
    if (state.waveInProgress &&
        _currentWaveFullySpawned &&
        state.enemies.isEmpty) {
      state.waveInProgress = false;
      if (state.wavesStarted >= state.waves.length) {
        state.status = GameStatus.won;
      }
    }
  }

  // --- Helpers ----------------------------------------------------------------

  Position _positionOf(Enemy enemy) =>
      state.map.positionAt(enemy.distanceTravelled);

  Position _positionOfTower(int towerId) =>
      Position.centreOf(state.towerCells[towerId]!);

  CombatEnemy _toCombatEnemy(Enemy enemy, Position position) => CombatEnemy(
    id: enemy.id,
    x: position.x,
    y: position.y,
    distanceTravelled: enemy.distanceTravelled,
    health: enemy.health,
  );
}
