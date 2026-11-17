import 'combat_logic.dart';
import 'combat_types.dart';

/// Uses [primary] until it fails once, then [fallback] for the rest of the
/// game (AD-2). The engine does not notice the switch.
class FallbackCombatLogic implements CombatLogic {
  FallbackCombatLogic({required this.primary, required this.fallback});

  final CombatLogic primary;
  final CombatLogic fallback;

  /// Why [primary] failed, or null while it is still in use.
  String? failureReason;

  bool get usingFallback => failureReason != null;

  @override
  List<ShotDecision> decideShots(CombatRequest request) {
    if (!usingFallback) {
      try {
        return primary.decideShots(request);
      } catch (error) {
        failureReason = '$error';
      }
    }
    return fallback.decideShots(request);
  }
}
