import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defence_code/combat_logic/native_combat_logic.dart';
import 'package:tower_defence_code/engine/game_engine.dart';
import 'package:tower_defence_code/engine/game_event.dart';
import 'package:tower_defence_code/model/cell.dart';
import 'package:tower_defence_code/model/enemy.dart';
import 'package:tower_defence_code/model/game_map.dart';
import 'package:tower_defence_code/model/game_state.dart';
import 'package:tower_defence_code/model/projectile.dart';
import 'package:tower_defence_code/model/tower.dart';
import 'package:tower_defence_code/model/wave.dart';

// Path along row 0, 10 cells long; towers go in row 1.
// Both enemy kinds have 10 health, so one arrow (damage 10) defeats them.
const grunt = EnemyDefinition(
  key: 'grunt',
  name: 'Grunt',
  maxHealth: 10,
  speed: 1,
  radius: 0.3,
  scoreValue: 10,
);
const brute = EnemyDefinition(
  key: 'brute',
  name: 'Brute',
  maxHealth: 10,
  speed: 1,
  radius: 0.3,
  scoreValue: 50,
);

GameState newState({List<Wave> waves = const [], int lives = 3}) => GameState(
  map: GameMap(width: 11, height: 2, path: const [Cell(0, 0), Cell(10, 0)]),
  lives: lives,
  towerDefinitions: const {
    'archer': TowerDefinition(
      key: 'archer',
      name: 'Archer',
      range: 2,
      cooldown: 1,
      damageMultiplier: 1,
      projectileKey: 'arrow',
    ),
  },
  projectileDefinitions: const {
    'arrow': ProjectileDefinition(
      key: 'arrow',
      damage: 10,
      hitRadius: 0.1,
      hitsAll: false,
      flightTime: 0.5,
    ),
  },
  enemyDefinitions: const {'grunt': grunt, 'brute': brute},
  waves: waves,
);

/// An engine that records every event it publishes in [events].
(GameEngine, List<GameEvent>) recordingEngine(GameState state) {
  final engine = GameEngine(
    state: state,
    combatLogic: const NativeCombatLogic(),
  );
  final events = <GameEvent>[];
  engine.addListener(events.add);
  return (engine, events);
}

void putEnemy(GameState state, int id, String key, double distance) {
  state.enemies[id] = Enemy(
    id: id,
    definitionKey: key,
    health: 10,
    distanceTravelled: distance,
  );
}

void main() {
  group('FR-S1 score', () {
    test('each enemy type adds its own value when defeated', () {
      final state = newState();
      final (engine, _) = recordingEngine(state);
      engine.placeTower('archer', const Cell(3, 1));
      putEnemy(state, 1, 'grunt', 3);
      engine.tick(0); // fire
      engine.tick(0.5); // land
      expect(state.score, 10);

      putEnemy(state, 2, 'brute', 3.5);
      engine.tick(1); // cooldown over, fire
      engine.tick(0.5); // land
      expect(state.score, 60);
    });

    test('an enemy reaching the base gives no points', () {
      final state = newState();
      final (engine, _) = recordingEngine(state);
      putEnemy(state, 1, 'brute', 9.5);
      engine.tick(1);
      expect(state.score, 0);
    });
  });

  group('events', () {
    test('placing a tower publishes TowerPlaced', () {
      final state = newState();
      final (engine, events) = recordingEngine(state);
      engine.placeTower('archer', const Cell(3, 1));

      final event = events.single as TowerPlaced;
      expect(event.towerId, 1);
      expect(event.towerKey, 'archer');
      expect(event.cell, const Cell(3, 1));
    });

    test('a refused placement publishes PlacementRejected with the reason', () {
      final state = newState();
      final (engine, events) = recordingEngine(state);
      engine.placeTower('archer', const Cell(3, 0)); // on the path

      final event = events.single as PlacementRejected;
      expect(event.reason, PlacementResult.onPath);
      expect(state.towers, isEmpty);
    });

    test('a defeat publishes EnemyDefeated with the tower and the points', () {
      final state = newState();
      final (engine, events) = recordingEngine(state);
      engine.placeTower('archer', const Cell(3, 1));
      putEnemy(state, 7, 'brute', 3);
      engine.tick(0);
      engine.tick(0.5);

      final event = events.whereType<EnemyDefeated>().single;
      expect(event.enemyId, 7);
      expect(event.enemyKey, 'brute');
      expect(event.towerId, 1);
      expect(event.scoreValue, 50);
    });

    test('reaching the base publishes EnemyReachedBase', () {
      final state = newState(lives: 3);
      final (engine, events) = recordingEngine(state);
      putEnemy(state, 1, 'grunt', 9.5);
      engine.tick(1);

      final event = events.single as EnemyReachedBase;
      expect(event.enemyId, 1);
      expect(event.livesLeft, 2);
    });

    test('a wave publishes started, spawned and cleared in order', () {
      final state = newState(
        waves: const [
          Wave([SpawnGroup(enemyKey: 'grunt', count: 1, secondsBetween: 1)]),
          Wave([SpawnGroup(enemyKey: 'grunt', count: 1, secondsBetween: 1)]),
        ],
      );
      final (engine, events) = recordingEngine(state);
      engine.startNextWave();
      engine.tick(0);
      state.enemies.clear(); // pretend it was defeated
      engine.tick(0);

      expect(events[0], isA<WaveStarted>());
      expect((events[0] as WaveStarted).waveNumber, 1);
      expect(events[1], isA<EnemySpawned>());
      expect(events[2], isA<WaveCleared>());
      expect(events, hasLength(3)); // not won yet: one wave left
      expect(state.wavesCleared, 1);
    });

    test('winning publishes GameEnded once, with the victory metrics', () {
      final state = newState(
        lives: 3,
        waves: const [
          Wave([SpawnGroup(enemyKey: 'grunt', count: 1, secondsBetween: 1)]),
        ],
      );
      final (engine, events) = recordingEngine(state);
      engine.startNextWave();
      engine.tick(0);
      state.enemies.clear();
      engine.tick(0);
      engine.tick(1); // the game is over: nothing more happens

      final ended = events.whereType<GameEnded>().single;
      expect(ended.status, GameStatus.won);
      expect(ended.livesLeft, 3);
      expect(ended.wavesCleared, 1);
    });

    test('losing publishes GameEnded with status lost', () {
      final state = newState(lives: 1);
      final (engine, events) = recordingEngine(state);
      putEnemy(state, 1, 'grunt', 9.5);
      engine.tick(1);

      final ended = events.whereType<GameEnded>().single;
      expect(ended.status, GameStatus.lost);
      expect(ended.livesLeft, 0);
    });

    test('a removed listener gets no more events', () {
      final state = newState();
      final engine = GameEngine(
        state: state,
        combatLogic: const NativeCombatLogic(),
      );
      final events = <GameEvent>[];
      engine.addListener(events.add);
      engine.removeListener(events.add);
      engine.placeTower('archer', const Cell(3, 1));
      expect(events, isEmpty);
    });
  });
}
