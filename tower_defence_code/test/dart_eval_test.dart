import 'package:dart_eval/dart_eval.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dart_eval executes code', () {
    final testAdd = eval('2 + 3');
    expect(testAdd, 5);
  });
  test('dart_eval executes a full function', () {
    final testAdd = eval('int main() { return 6 + 3; }');
    expect(testAdd, 9);
  });
}
