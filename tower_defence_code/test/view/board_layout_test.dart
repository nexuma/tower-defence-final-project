import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defence_code/model/cell.dart';
import 'package:tower_defence_code/model/position.dart';
import 'package:tower_defence_code/view/board_layout.dart';

void main() {
  // A 4 × 2 board on a 400 × 240 screen with a 40-pixel HUD strip:
  // 400 / 4 = 100 and 200 / 2 = 100, so cells are 100 pixels and the board
  // fills the space exactly, starting just below the HUD.
  BoardLayout layout() =>
      BoardLayout(columns: 4, rows: 2, hudHeight: 40)
        ..resize(Vector2(400, 240));

  test('cells are square and fit the screen below the HUD', () {
    final l = layout();
    expect(l.cellSize, 100);
    expect(l.origin, Vector2(0, 40));
  });

  test('the board is centred when the screen is wider than it', () {
    final l = BoardLayout(columns: 4, rows: 2, hudHeight: 40)
      ..resize(Vector2(600, 240));
    expect(l.cellSize, 100);
    expect(l.origin, Vector2(100, 40));
  });

  test('toPixels converts a position in cells', () {
    expect(layout().toPixels(const Position(1.5, 0.5)), Vector2(150, 90));
  });

  test('cellAt finds the cell under a pixel', () {
    expect(layout().cellAt(Vector2(150, 90)), const Cell(1, 0));
    expect(layout().cellAt(Vector2(399, 239)), const Cell(3, 1));
  });

  test('cellAt is null off the board', () {
    expect(layout().cellAt(Vector2(150, 20)), isNull); // in the HUD strip
    expect(layout().cellAt(Vector2(-1, 100)), isNull);
  });

  test('cellAt and toPixels agree', () {
    final l = layout();
    const cell = Cell(2, 1);
    expect(l.cellAt(l.toPixels(Position.centreOf(cell))), cell);
  });
}
