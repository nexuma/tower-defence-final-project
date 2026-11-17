import 'combat_types.dart';

/// Decides which enemy each ready tower shoots, and for how much damage.
///
/// The engine calls this once per tick, and only on ticks where at least one
/// tower is ready. It must not change anything: it only returns decisions.
/// The engine checks every decision before applying it, so a faulty
/// implementation cannot break the rules.
abstract interface class CombatLogic {
  /// Returns at most one decision per ready tower. Towers left out do not
  /// fire this tick.
  List<ShotDecision> decideShots(CombatRequest request);
}
