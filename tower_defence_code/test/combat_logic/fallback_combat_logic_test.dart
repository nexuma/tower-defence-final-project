import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defence_code/combat_logic/combat_logic.dart';
import 'package:tower_defence_code/combat_logic/combat_types.dart';
import 'package:tower_defence_code/combat_logic/fallback_combat_logic.dart';

/// Returns one fixed decision, or throws if [fails] is set; counts calls.
class FakeLogic implements CombatLogic {
  FakeLogic(this.towerId, {this.fails = false});

  final int towerId;
  final bool fails;
  int calls = 0;

  @override
  List<ShotDecision> decideShots(CombatRequest request) {
    calls++;
    if (fails) throw StateError('script broke');
    return [ShotDecision(towerId: towerId, targetEnemyId: 1, damage: 1)];
  }
}

void main() {
  const request = CombatRequest(readyTowers: [], enemies: []);

  test('uses the primary logic while it works', () {
    final logic = FallbackCombatLogic(
      primary: FakeLogic(1),
      fallback: FakeLogic(2),
    );
    expect(logic.decideShots(request).single.towerId, 1);
    expect(logic.usingFallback, isFalse);
  });

  test('switches to the fallback when the primary throws', () {
    final logic = FallbackCombatLogic(
      primary: FakeLogic(1, fails: true),
      fallback: FakeLogic(2),
    );
    expect(logic.decideShots(request).single.towerId, 2);
    expect(logic.usingFallback, isTrue);
    expect(logic.failureReason, contains('script broke'));
  });

  test('after one failure the primary is not called again', () {
    final primary = FakeLogic(1, fails: true);
    final logic = FallbackCombatLogic(primary: primary, fallback: FakeLogic(2));
    logic.decideShots(request);
    logic.decideShots(request);
    expect(primary.calls, 1);
  });
}
