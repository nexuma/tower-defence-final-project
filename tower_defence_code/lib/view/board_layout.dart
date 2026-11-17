import 'dart:math' as math;

import 'package:flame/components.dart';

import '../model/cell.dart';
import '../model/position.dart';

/// Converts between the model's cells and screen pixels. Pixels exist only in
/// the view; the model only knows cells.
///
/// The board is scaled to fit the screen below a strip of [hudHeight] pixels,
/// keeping cells square, and is centred in the space that is left.
class BoardLayout {
  BoardLayout({required this.columns, required this.rows, this.hudHeight = 40});

  final int columns;
  final int rows;
  final double hudHeight;

  /// Size of one cell in pixels.
  double cellSize = 1;

  /// Pixel position of the board's top-left corner.
  Vector2 origin = Vector2.zero();

  /// Recalculates [cellSize] and [origin] for a screen of [screenSize].
  void resize(Vector2 screenSize) {
    final available = Vector2(screenSize.x, screenSize.y - hudHeight);
    cellSize = math.max(1, math.min(available.x / columns, available.y / rows));
    origin = Vector2(
      (screenSize.x - cellSize * columns) / 2,
      hudHeight + (available.y - cellSize * rows) / 2,
    );
  }

  /// The pixel position of [position], which is in cells.
  Vector2 toPixels(Position position) => Vector2(
    origin.x + position.x * cellSize,
    origin.y + position.y * cellSize,
  );

  /// A distance in cells, in pixels.
  double toPixelLength(double cells) => cells * cellSize;

  /// The cell under [pixel], or null if the pixel is not on the board.
  Cell? cellAt(Vector2 pixel) {
    final x = ((pixel.x - origin.x) / cellSize).floor();
    final y = ((pixel.y - origin.y) / cellSize).floor();
    if (x < 0 || x >= columns || y < 0 || y >= rows) return null;
    return Cell(x, y);
  }
}
