import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defence_code/content/first_level.dart';

void main() {
  test('every key in the first level refers to an existing definition', () {
    final state = firstLevel();
    for (final tower in state.towerDefinitions.values) {
      expect(state.projectileDefinitions, contains(tower.projectileKey));
    }
    for (final wave in state.waves) {
      for (final group in wave.groups) {
        expect(state.enemyDefinitions, contains(group.enemyKey));
      }
    }
  });
}
