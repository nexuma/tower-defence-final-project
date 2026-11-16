/// A square on the grid, identified by whole-number coordinates.
///
/// Two cells are equal when their coordinates match, so a [Cell] can be used
/// as a map key or in a set.
class Cell {
  const Cell(this.x, this.y);

  final int x;
  final int y;

  @override
  bool operator ==(Object other) =>
      other is Cell && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Cell($x, $y)';
}
