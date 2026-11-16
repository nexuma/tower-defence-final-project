import 'cell.dart';
import 'position.dart';

/// The board: its size and the path that enemies walk along.
///
/// The path is given as waypoint cells from start to end. Two consecutive
/// waypoints must be in the same row or column, so the path is made of
/// straight horizontal and vertical segments. Enemies walk through the
/// centres of the cells.
class GameMap {
  GameMap({required this.width, required this.height, required this.path})
    : _pathCells = _cellsAlong(path),
      pathLength = _lengthOf(path) {
    for (final cell in path) {
      if (!contains(cell)) {
        throw ArgumentError('Waypoint $cell is outside the map.');
      }
    }
  }

  final int width;
  final int height;

  /// Waypoint cells, from start to end.
  final List<Cell> path;

  /// Length of the path in cells, from the first to the last waypoint centre.
  /// An enemy has reached the end when its distance travelled is at least this.
  final double pathLength;

  /// Every cell the path passes through, not only the waypoints.
  final Set<Cell> _pathCells;

  bool contains(Cell cell) =>
      cell.x >= 0 && cell.x < width && cell.y >= 0 && cell.y < height;

  /// Whether the path passes through [cell]. Towers cannot be placed there.
  bool isOnPath(Cell cell) => _pathCells.contains(cell);

  /// Where an enemy is after walking [distance] cells along the path.
  /// Distances below 0 or beyond [pathLength] give the start or end.
  Position positionAt(double distance) {
    var remaining = distance;
    for (var i = 0; i < path.length - 1; i++) {
      final from = Position.centreOf(path[i]);
      final to = Position.centreOf(path[i + 1]);
      final segment = from.distanceTo(to);
      if (remaining <= segment) {
        if (remaining <= 0) return from;
        final t = remaining / segment;
        return Position(
          from.x + (to.x - from.x) * t,
          from.y + (to.y - from.y) * t,
        );
      }
      remaining -= segment;
    }
    return Position.centreOf(path.last);
  }

  static Set<Cell> _cellsAlong(List<Cell> path) {
    if (path.isEmpty) {
      throw ArgumentError('The path needs at least one waypoint.');
    }
    final cells = <Cell>{path.first};
    for (var i = 0; i < path.length - 1; i++) {
      final from = path[i];
      final to = path[i + 1];
      if (from.x != to.x && from.y != to.y) {
        throw ArgumentError(
          'Waypoints $from and $to are not in the same row or column.',
        );
      }
      final stepX = (to.x - from.x).sign;
      final stepY = (to.y - from.y).sign;
      var current = from;
      while (current != to) {
        current = Cell(current.x + stepX, current.y + stepY);
        cells.add(current);
      }
    }
    return cells;
  }

  static double _lengthOf(List<Cell> path) {
    var length = 0.0;
    for (var i = 0; i < path.length - 1; i++) {
      length +=
          (path[i + 1].x - path[i].x).abs() + (path[i + 1].y - path[i].y).abs();
    }
    return length;
  }
}
