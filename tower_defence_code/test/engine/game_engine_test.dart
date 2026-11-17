import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defence_code/combat_logic/combat_logic.dart';
import 'package:tower_defence_code/combat_logic/combat_types.dart';
import 'package:tower_defence_code/combat_logic/native_combat_logic.dart';
import 'package:tower_defence_code/engine/game_engine.dart';
import 'package:tower_defence_code/model/cell.dart';
import 'package:tower_defence_code/model/enemy.dart';
import 'package:tower_defence_code/model/game_map.dart';
import 'package:tower_defence_code/model/game_state.dart';
import 'package:tower_defence_code/model/projectile.dart';
import 'package:tower_defence_code/model/tower.dart';
import 'package:tower_defence_code/model/wave.dart';

// A straight path along row 0, 10 cells long:
//   S . . . . . . . . . E      enemies walk from x=0.5 to x=10.5
//   . . . T . . . . . . .      a tower at (3, 1) when placed
const slowEnemy = EnemyDefinition(
  key: 'slow',
  name: 'Slow',
  maxHealth: 20,
  speed: 1,
  radius: 0.3,
);
const arrow = ProjectileDefinition(
  key: 'arrow',
  damage: 10,
  hitRadius: 0.1,
  hitsAll: false,
  flightTime: 0.5,
);
const boulder = ProjectileDefinition(
  key: 'boulder',
  damage: 10,
  hitRadius: 1,
  hitsAll: true,
  flightTime: 0.5,
);
const archer = TowerDefinition(
  key: 'archer',
  name: 'Archer',
  range: 2,
  cooldown: 1,
  damageMultiplier: 1,
  projectileKey: 'arrow',
);
const catapult = TowerDefinition(
  key: 'catapult',
  name: 'Catapult',
  range: 2,
  cooldown: 1,
  damageMultiplier: 1,
  projectileKey: 'boulder',
);

GameState newState({List<Wave> waves = const [], int lives = 3}) => GameState(
  map: GameMap(width: 11, height: 2, path: const [Cell(0, 0), Cell(10, 0)]),
  lives: lives,
  towerDefinitions: const {'archer': archer, 'catapult': catapult},
  projectileDefinitions: const {'arrow': arrow, 'boulder': boulder},
  enemyDefinitions: const {'slow': slowEnemy},
  waves: waves,
);

GameEngine newEngine(GameState state, [CombatLogic? logic]) =>
    GameEngine(state: state, combatLogic: logic ?? const NativeCombatLogic());

/// Places a tower directly in the model (placeTower comes with FR-M1).
void putTower(GameState state, int id, String key, Cell cell) {
  state.towers[id] = Tower(id: id, definitionKey: key);
  state.towerCells[id] = cell;
}

/// Puts an enemy directly in the model at [distance] along the path.
Enemy putEnemy(GameState state, int id, double distance, {double? health}) {
  final enemy = Enemy(
    id: id,
    definitionKey: 'slow',
    health: health ?? slowEnemy.maxHealth,
    distanceTravelled: distance,
  );
  state.enemies[id] = enemy;
  return enemy;
}

const oneWave = [
  Wave([SpawnGroup(enemyKey: 'slow', count: 3, secondsBetween: 2)]),
];

/// Records every request and returns fixed decisions.
class FakeCombatLogic implements CombatLogic {
  FakeCombatLogic(this.decisions);

  final List<ShotDecision> decisions;
  final requests = <CombatRequest>[];

  @override
  List<ShotDecision> decideShots(CombatRequest request) {
    requests.add(request);
    return decisions;
  }
}

void main() {
  group('waves and spawning', () {
    test('nothing spawns until a wave is started', () {
      final state = newState(waves: oneWave);
      newEngine(state).tick(5);
      expect(state.enemies, isEmpty);
    });

    test('a group spawns one enemy every secondsBetween', () {
      final state = newState(waves: oneWave);
      final engine = newEngine(state);
      expect(engine.startNextWave(), isTrue);

      engine.tick(0.1);
      expect(state.enemies, hasLength(1));
      engine.tick(1.8); // t = 1.9
      expect(state.enemies, hasLength(1));
      engine.tick(0.2); // t = 2.1
      expect(state.enemies, hasLength(2));
      engine.tick(2); // t = 4.1
      expect(state.enemies, hasLength(3));
      engine.tick(2);
      expect(state.enemies, hasLength(3)); // the group is finished
    });

    test('a new enemy has full health and starts at distance 0', () {
      final state = newState(waves: oneWave);
      final engine = newEngine(state)..startNextWave();
      engine.tick(0);
      final enemy = state.enemies.values.single;
      expect(enemy.health, slowEnemy.maxHealth);
      expect(enemy.distanceTravelled, 0);
    });

    test('a wave cannot be started while one is in progress', () {
      final state = newState(waves: [...oneWave, ...oneWave]);
      final engine = newEngine(state);
      expect(engine.startNextWave(), isTrue);
      expect(engine.startNextWave(), isFalse);
      expect(state.wavesStarted, 1);
    });

    test('no wave can be started once all have been started', () {
      final state = newState(waves: const []);
      expect(newEngine(state).startNextWave(), isFalse);
    });
  });

  group('movement and the base', () {
    test('enemies move speed × dt along the path', () {
      final state = newState();
      final enemy = putEnemy(state, 1, 0);
      newEngine(state).tick(2.5);
      expect(enemy.distanceTravelled, 2.5);
    });

    test('an enemy reaching the end is removed and costs one life', () {
      final state = newState(lives: 3);
      putEnemy(state, 1, 9.5);
      newEngine(state).tick(1);
      expect(state.enemies, isEmpty);
      expect(state.lives, 2);
    });
  });

  group('towers and shots', () {
    test('a ready tower fires at an enemy in range', () {
      final state = newState();
      putTower(state, 1, 'archer', const Cell(3, 1));
      putEnemy(state, 1, 3);
      newEngine(state).tick(0);

      final shot = state.shots.single;
      expect(shot.towerId, 1);
      expect(shot.targetEnemyId, 1);
      expect(shot.damage, 10);
      expect(shot.timeUntilImpact, arrow.flightTime);
      expect(state.towers[1]!.timeUntilNextShot, archer.cooldown);
    });

    test('a tower does not fire at an enemy out of range', () {
      final state = newState();
      putTower(state, 1, 'archer', const Cell(3, 1));
      putEnemy(state, 1, 8);
      newEngine(state).tick(0);
      expect(state.shots, isEmpty);
      expect(state.towers[1]!.timeUntilNextShot, 0); // still ready
    });

    test('a tower fires again only after its cooldown', () {
      final state = newState();
      putTower(state, 1, 'archer', const Cell(3, 1));
      putEnemy(state, 1, 3, health: 1000);
      final engine = newEngine(state);

      engine.tick(0);
      expect(state.shots, hasLength(1));
      engine.tick(0.4);
      expect(state.shots, hasLength(1));
      engine.tick(0.4); // first shot lands at 0.5; still on cooldown
      expect(state.shots, isEmpty);
      engine.tick(0.3); // cooldown over at 1.0
      expect(state.shots, hasLength(1));
    });

    test('a shot deals its damage when it lands, not when fired', () {
      final state = newState();
      putTower(state, 1, 'archer', const Cell(3, 1));
      final enemy = putEnemy(state, 1, 3);
      final engine = newEngine(state);

      engine.tick(0);
      expect(enemy.health, 20);
      engine.tick(0.5);
      expect(enemy.health, 10);
    });

    test('an enemy at 0 health or below is removed', () {
      final state = newState();
      putTower(state, 1, 'archer', const Cell(3, 1));
      putEnemy(state, 1, 3, health: 10);
      final engine = newEngine(state);
      engine.tick(0);
      engine.tick(0.5);
      expect(state.enemies, isEmpty);
    });

    test('if the target died, the shot hits an enemy at its last position', () {
      final state = newState();
      putTower(state, 1, 'archer', const Cell(3, 1));
      putEnemy(state, 1, 3);
      final engine = newEngine(state);
      engine.tick(0); // shot aimed at enemy 1 at distance 3

      state.enemies.remove(1); // enemy 1 dies before the shot lands
      // Enemy 2 is half a cell behind; after moving 0.5 cells it stands
      // exactly where enemy 1 was last seen.
      final other = putEnemy(state, 2, 2.5);
      engine.tick(0.5);
      expect(other.health, 10);
    });

    test('a hitsAll projectile damages every overlapping enemy', () {
      final state = newState();
      putTower(state, 1, 'catapult', const Cell(3, 1));
      final a = putEnemy(state, 1, 3);
      final b = putEnemy(state, 2, 2.5);
      final far = putEnemy(state, 3, 0);
      final engine = newEngine(state);

      engine.tick(0); // targets a (furthest along, in range)
      engine.tick(0.5);
      expect(a.health, 10);
      expect(b.health, 10);
      expect(far.health, 20);
    });
  });

  group('the engine checks CombatLogic decisions', () {
    test('combat logic is not called when no tower is ready', () {
      final state = newState();
      putEnemy(state, 1, 3);
      final fake = FakeCombatLogic(const []);
      newEngine(state, fake).tick(0);
      expect(fake.requests, isEmpty);
    });

    test('one call covers all ready towers and all enemies', () {
      final state = newState();
      putTower(state, 1, 'archer', const Cell(3, 1));
      putTower(state, 2, 'archer', const Cell(6, 1));
      putEnemy(state, 1, 3);
      putEnemy(state, 2, 7);
      final fake = FakeCombatLogic(const []);
      newEngine(state, fake).tick(0);
      expect(fake.requests, hasLength(1));
      expect(fake.requests.single.readyTowers, hasLength(2));
      expect(fake.requests.single.enemies, hasLength(2));
    });

    test('invalid decisions are ignored', () {
      final state = newState();
      putTower(state, 1, 'archer', const Cell(3, 1));
      putEnemy(state, 1, 3);
      putEnemy(state, 2, 9); // out of range
      final fake = FakeCombatLogic(const [
        ShotDecision(towerId: 99, targetEnemyId: 1, damage: 5), // no tower
        ShotDecision(towerId: 1, targetEnemyId: 99, damage: 5), // no enemy
        ShotDecision(towerId: 1, targetEnemyId: 2, damage: 5), // out of range
        ShotDecision(towerId: 1, targetEnemyId: 1, damage: -5), // negative
      ]);
      newEngine(state, fake).tick(0);
      expect(state.shots, isEmpty);
    });

    test('a tower fires at most once per tick', () {
      final state = newState();
      putTower(state, 1, 'archer', const Cell(3, 1));
      putEnemy(state, 1, 3);
      final fake = FakeCombatLogic(const [
        ShotDecision(towerId: 1, targetEnemyId: 1, damage: 5),
        ShotDecision(towerId: 1, targetEnemyId: 1, damage: 5),
      ]);
      newEngine(state, fake).tick(0);
      expect(state.shots, hasLength(1));
    });
  });

  group('end of the game', () {
    test('the game is lost when lives reach 0, and then stops', () {
      final state = newState(lives: 1);
      putEnemy(state, 1, 9.5); // reaches the base this tick
      final other = putEnemy(state, 2, 0);
      final engine = newEngine(state);
      engine.tick(1);
      expect(state.status, GameStatus.lost);
      expect(state.lives, 0);

      engine.tick(1);
      expect(other.distanceTravelled, 1); // did not move again
    });

    test('clearing a wave waits for the next startNextWave', () {
      const singleEnemyWave = Wave([
        SpawnGroup(enemyKey: 'slow', count: 1, secondsBetween: 1),
      ]);
      final state = newState(waves: const [singleEnemyWave, singleEnemyWave]);
      final engine = newEngine(state)..startNextWave();
      engine.tick(0);
      state.enemies.clear(); // pretend the towers killed it
      engine.tick(0);

      expect(state.waveInProgress, isFalse);
      expect(state.status, GameStatus.playing);
      engine.tick(5);
      expect(state.enemies, isEmpty); // nothing spawns on its own
      expect(engine.startNextWave(), isTrue);
    });

    test('the game is won when the last wave is cleared with lives left', () {
      final state = newState(
        lives: 10,
        waves: const [
          Wave([SpawnGroup(enemyKey: 'slow', count: 1, secondsBetween: 1)]),
        ],
      );
      final engine = newEngine(state)..startNextWave();
      engine.tick(0);
      state.enemies.clear();
      engine.tick(0);
      expect(state.status, GameStatus.won);
    });
  });
}
