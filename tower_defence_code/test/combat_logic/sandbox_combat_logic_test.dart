import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defence_code/combat_logic/combat_types.dart';
import 'package:tower_defence_code/combat_logic/native_combat_logic.dart';
import 'package:tower_defence_code/combat_logic/sandbox_combat_logic.dart';

String script(String name) =>
    File('assets/combat_scripts/$name.dart').readAsStringSync();

CombatTower tower(int id, double x, {double range = 3}) => CombatTower(
  id: id,
  x: x,
  y: 0,
  range: range,
  baseDamage: 10,
  damageMultiplier: 1.5,
);

CombatEnemy enemy(int id, double x, double distance, {double health = 50}) =>
    CombatEnemy(
      id: id,
      x: x,
      y: 0,
      distanceTravelled: distance,
      health: health,
    );

/// Decisions as plain values, so two lists can be compared with `expect`.
List<(int, int, double)> asRecords(List<ShotDecision> decisions) => [
  for (final d in decisions) (d.towerId, d.targetEnemyId, d.damage),
];

void main() {
  group(
    'first_targeting.dart gives the same decisions as NativeCombatLogic',
    () {
      final sandbox = SandboxCombatLogic(script('first_targeting'));
      const native = NativeCombatLogic();

      final requests = {
        'one tower, several enemies': CombatRequest(
          readyTowers: [tower(1, 0)],
          enemies: [enemy(1, 1, 5), enemy(2, 2, 8), enemy(3, 9, 20)],
        ),
        'two towers, different targets': CombatRequest(
          readyTowers: [tower(1, 0), tower(2, 10)],
          enemies: [enemy(1, 1, 5), enemy(2, 9, 2), enemy(3, 11, 3)],
        ),
        'no enemy in range': CombatRequest(
          readyTowers: [tower(1, 0, range: 1)],
          enemies: [enemy(1, 5, 0)],
        ),
        'no enemies at all': CombatRequest(
          readyTowers: [tower(1, 0)],
          enemies: const [],
        ),
      };

      for (final entry in requests.entries) {
        test(entry.key, () {
          expect(
            asRecords(sandbox.decideShots(entry.value)),
            asRecords(native.decideShots(entry.value)),
          );
        });
      }
    },
  );

  test('strongest_targeting.dart picks the enemy with the most health', () {
    final sandbox = SandboxCombatLogic(script('strongest_targeting'));
    final decisions = sandbox.decideShots(
      CombatRequest(
        readyTowers: [tower(1, 0)],
        enemies: [
          enemy(1, 1, 9, health: 20), // furthest along
          enemy(2, 2, 1, health: 80), // strongest
          enemy(3, 9, 0, health: 500), // out of range
        ],
      ),
    );
    expect(asRecords(decisions), [(1, 2, 15.0)]);
  });

  group('failures are reported as exceptions', () {
    final request = CombatRequest(
      readyTowers: [tower(1, 0)],
      enemies: [enemy(1, 1, 0)],
    );

    test('a script that does not compile', () {
      expect(
        () => SandboxCombatLogic('List<double> decideShots( {'),
        throwsA(anything),
      );
    });

    test('a script that throws', () {
      final sandbox = SandboxCombatLogic('''
        List<double> decideShots(List<double> towers, List<double> enemies) {
          throw Exception('broken');
        }
      ''');
      expect(() => sandbox.decideShots(request), throwsA(anything));
    });

    test('a result that is not in groups of 3', () {
      final sandbox = SandboxCombatLogic('''
        List<double> decideShots(List<double> towers, List<double> enemies) {
          return [1.0, 2.0];
        }
      ''');
      expect(() => sandbox.decideShots(request), throwsFormatException);
    });

    test('an ID that is not a whole number', () {
      final sandbox = SandboxCombatLogic('''
        List<double> decideShots(List<double> towers, List<double> enemies) {
          return [1.5, 1.0, 10.0];
        }
      ''');
      expect(() => sandbox.decideShots(request), throwsFormatException);
    });
  });
}
