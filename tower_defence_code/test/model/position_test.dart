import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defence_code/model/cell.dart';
import 'package:tower_defence_code/model/position.dart';

void main() {
  test('distanceTo gives the straight-line distance', () {
    expect(const Position(0, 0).distanceTo(const Position(3, 4)), 5);
  });

  test('centreOf is half a cell in from the corner', () {
    expect(Position.centreOf(const Cell(2, 3)), const Position(2.5, 3.5));
  });
}
