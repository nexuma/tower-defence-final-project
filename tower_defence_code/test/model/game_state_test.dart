import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defence_code/model/cell.dart';
import 'package:tower_defence_code/model/game_map.dart';
import 'package:tower_defence_code/model/game_state.dart';

void main() {
  test('a new game is playing, with no wave started and an empty board', () {
    final state = GameState(
      map: GameMap(width: 3, height: 1, path: const [Cell(0, 0), Cell(2, 0)]),
      lives: 10,
      towerDefinitions: const {},
      projectileDefinitions: const {},
      enemyDefinitions: const {},
      waves: const [],
    );

    expect(state.status, GameStatus.playing);
    expect(state.lives, 10);
    expect(state.wavesStarted, 0);
    expect(state.waveInProgress, isFalse);
    expect(state.towers, isEmpty);
    expect(state.towerCells, isEmpty);
    expect(state.enemies, isEmpty);
    expect(state.shots, isEmpty);
  });
}
