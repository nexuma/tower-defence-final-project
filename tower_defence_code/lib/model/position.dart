import 'dart:math' as math;

import 'cell.dart';

/// A point on the board, measured in cells (decimals allowed).
///
/// The centre of [Cell] (x, y) is at Position(x + 0.5, y + 0.5).
class Position {
  const Position(this.x, this.y);

  /// The centre of [cell].
  Position.centreOf(Cell cell) : x = cell.x + 0.5, y = cell.y + 0.5;

  final double x;
  final double y;

  double distanceTo(Position other) {
    final dx = other.x - x;
    final dy = other.y - y;
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  bool operator ==(Object other) =>
      other is Position && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Position($x, $y)';
}
