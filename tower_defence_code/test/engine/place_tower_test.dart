import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defence_code/combat_logic/native_combat_logic.dart';
import 'package:tower_defence_code/engine/game_engine.dart';
import 'package:tower_defence_code/model/cell.dart';
import 'package:tower_defence_code/model/game_map.dart';
import 'package:tower_defence_code/model/game_state.dart';
import 'package:tower_defence_code/model/tower.dart';

// A 6 × 3 board with the path along row 0. Row 1 and row 2 are free.
const archer = TowerDefinition(
  key: 'archer',
  name: 'Archer',
  range: 2,
  cooldown: 1,
  damageMultiplier: 1,
  projectileKey: 'arrow',
);

GameState newState() => GameState(
  map: GameMap(width: 6, height: 3, path: const [Cell(0, 0), Cell(5, 0)]),
  lives: 3,
  towerDefinitions: const {'archer': archer},
  projectileDefinitions: const {},
  enemyDefinitions: const {},
  waves: const [],
);

GameEngine newEngine(GameState state) =>
    GameEngine(state: state, combatLogic: const NativeCombatLogic());

void main() {
  // FR-M1, criterion 1
  test('with fewer than five towers, a valid cell gets the tower', () {
    final state = newState();
    final result = newEngine(state).placeTower('archer', const Cell(2, 1));

    expect(result, PlacementResult.placed);
    expect(state.towers, hasLength(1));
    final id = state.towers.keys.single;
    expect(state.towers[id]!.definitionKey, 'archer');
    expect(state.towerCells[id], const Cell(2, 1));
  });

  test('towers get incrementing IDs (AD-8)', () {
    final state = newState();
    final engine = newEngine(state);
    engine.placeTower('archer', const Cell(0, 1));
    engine.placeTower('archer', const Cell(1, 1));
    expect(state.towers.keys, [1, 2]);
  });

  // FR-M1, criterion 2
  test('a sixth tower is rejected and the count stays five', () {
    final state = newState();
    final engine = newEngine(state);
    for (var x = 0; x < 5; x++) {
      expect(engine.placeTower('archer', Cell(x, 1)), PlacementResult.placed);
    }

    final result = engine.placeTower('archer', const Cell(0, 2));
    expect(result, PlacementResult.tooManyTowers);
    expect(state.towers, hasLength(5));
  });

  // FR-M1, criterion 3
  group('an invalid or occupied cell is rejected and nothing moves', () {
    test('occupied', () {
      final state = newState();
      final engine = newEngine(state)..placeTower('archer', const Cell(2, 1));

      final result = engine.placeTower('archer', const Cell(2, 1));
      expect(result, PlacementResult.occupied);
      expect(state.towers, hasLength(1));
      expect(state.towerCells[1], const Cell(2, 1));
    });

    test('on the path', () {
      final state = newState();
      final result = newEngine(state).placeTower('archer', const Cell(3, 0));
      expect(result, PlacementResult.onPath);
      expect(state.towers, isEmpty);
    });

    test('outside the board', () {
      final state = newState();
      final engine = newEngine(state);
      expect(
        engine.placeTower('archer', const Cell(6, 1)),
        PlacementResult.outsideBoard,
      );
      expect(
        engine.placeTower('archer', const Cell(-1, 1)),
        PlacementResult.outsideBoard,
      );
      expect(state.towers, isEmpty);
    });
  });

  test('an unknown tower kind is rejected', () {
    final state = newState();
    final result = newEngine(state).placeTower('laser', const Cell(2, 1));
    expect(result, PlacementResult.unknownTower);
    expect(state.towers, isEmpty);
  });

  test('no towers can be placed once the game is over', () {
    final state = newState()..status = GameStatus.lost;
    final result = newEngine(state).placeTower('archer', const Cell(2, 1));
    expect(result, PlacementResult.gameOver);
    expect(state.towers, isEmpty);
  });
}
