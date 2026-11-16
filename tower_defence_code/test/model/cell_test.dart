import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defence_code/model/cell.dart';

void main() {
  test('cells with the same coordinates are equal', () {
    expect(const Cell(2, 3), const Cell(2, 3));
    expect(const Cell(2, 3), isNot(const Cell(3, 2)));
  });

  test('a cell can be used as a set or map key', () {
    final cells = <Cell>{}
      ..add(Cell(1, 1))
      ..add(Cell(1, 1));
    expect(cells.length, 1);
  });
}
