import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defence_code/model/cell.dart';
import 'package:tower_defence_code/model/game_map.dart';
import 'package:tower_defence_code/model/position.dart';

void main() {
  // An L-shaped path: right along row 1 from x=0 to x=3, then down to y=3.
  //   . . . . .
  //   S x x x .
  //   . . . x .
  //   . . . E .
  final map = GameMap(
    width: 5,
    height: 4,
    path: const [Cell(0, 1), Cell(3, 1), Cell(3, 3)],
  );

  group('isOnPath', () {
    test('is true for waypoints and the cells between them', () {
      expect(map.isOnPath(const Cell(0, 1)), isTrue);
      expect(map.isOnPath(const Cell(2, 1)), isTrue);
      expect(map.isOnPath(const Cell(3, 2)), isTrue);
      expect(map.isOnPath(const Cell(3, 3)), isTrue);
    });

    test('is false for cells off the path', () {
      expect(map.isOnPath(const Cell(0, 0)), isFalse);
      expect(map.isOnPath(const Cell(4, 1)), isFalse);
    });
  });

  test('pathLength adds up the segments', () {
    expect(map.pathLength, 5);
  });

  group('positionAt', () {
    test('0 is the centre of the start cell', () {
      expect(map.positionAt(0), const Position(0.5, 1.5));
    });

    test('a point part-way along the first segment', () {
      expect(map.positionAt(1.5), const Position(2.0, 1.5));
    });

    test('the corner', () {
      expect(map.positionAt(3), const Position(3.5, 1.5));
    });

    test('a point after the corner', () {
      expect(map.positionAt(4), const Position(3.5, 2.5));
    });

    test('beyond the end stays at the end, below 0 stays at the start', () {
      expect(map.positionAt(99), const Position(3.5, 3.5));
      expect(map.positionAt(-1), const Position(0.5, 1.5));
    });
  });

  group('invalid paths are rejected', () {
    test('a diagonal step', () {
      expect(
        () =>
            GameMap(width: 5, height: 5, path: const [Cell(0, 0), Cell(2, 2)]),
        throwsArgumentError,
      );
    });

    test('a waypoint outside the map', () {
      expect(
        () =>
            GameMap(width: 3, height: 3, path: const [Cell(0, 0), Cell(5, 0)]),
        throwsArgumentError,
      );
    });

    test('an empty path', () {
      expect(
        () => GameMap(width: 3, height: 3, path: const []),
        throwsArgumentError,
      );
    });
  });
}
