import '../model/cell.dart';
import '../model/enemy.dart';
import '../model/game_map.dart';
import '../model/game_state.dart';
import '../model/projectile.dart';
import '../model/tower.dart';
import '../model/wave.dart';

/// The data for the first playable level: one map, one tower kind, two enemy
/// kinds and three waves. Everything here is plain data (AD-6).
GameState firstLevel() => GameState(
  map: GameMap(
    width: 12,
    height: 8,
    path: const [
      Cell(0, 1),
      Cell(4, 1),
      Cell(4, 5),
      Cell(8, 5),
      Cell(8, 2),
      Cell(11, 2),
    ],
  ),
  lives: 10,
  towerDefinitions: const {
    'archer': TowerDefinition(
      key: 'archer',
      name: 'Archer',
      range: 2.5,
      cooldown: 0.8,
      damageMultiplier: 1,
      projectileKey: 'arrow',
    ),
  },
  projectileDefinitions: const {
    'arrow': ProjectileDefinition(
      key: 'arrow',
      damage: 10,
      hitRadius: 0.2,
      hitsAll: false,
      flightTime: 0.3,
    ),
  },
  enemyDefinitions: const {
    'grunt': EnemyDefinition(
      key: 'grunt',
      name: 'Grunt',
      maxHealth: 30,
      speed: 1.2,
      radius: 0.3,
      scoreValue: 10,
    ),
    'brute': EnemyDefinition(
      key: 'brute',
      name: 'Brute',
      maxHealth: 90,
      speed: 0.8,
      radius: 0.4,
      scoreValue: 50,
    ),
  },
  waves: const [
    Wave([SpawnGroup(enemyKey: 'grunt', count: 5, secondsBetween: 1.5)]),
    Wave([SpawnGroup(enemyKey: 'grunt', count: 10, secondsBetween: 1)]),
    Wave([
      SpawnGroup(enemyKey: 'grunt', count: 8, secondsBetween: 0.8),
      SpawnGroup(enemyKey: 'brute', count: 3, secondsBetween: 2),
    ]),
  ],
);
