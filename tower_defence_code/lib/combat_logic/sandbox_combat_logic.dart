import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';

import 'combat_logic.dart';
import 'combat_types.dart';

/// Combat logic loaded at runtime: a Dart script run by `dart_eval` (FR-M2).
///
/// This is the only file that imports `dart_eval` (AD-12). The script is
/// compiled once, when this object is created, and then called on every
/// [decideShots].
///
/// Data crosses the boundary as flat lists of numbers (AD-17):
///   towers:  id, x, y, range, baseDamage, damageMultiplier   (6 per tower)
///   enemies: id, x, y, distanceTravelled, health              (5 per enemy)
///   result:  towerId, targetEnemyId, damage                   (3 per shot)
///
/// Known limitation: dart_eval has no time limit, so a script that never
/// returns freezes the game. Exceptions and malformed results are thrown to
/// the caller, which can fall back (see `FallbackCombatLogic`).
class SandboxCombatLogic implements CombatLogic {
  /// Compiles [source]. Throws if the script does not compile.
  SandboxCombatLogic(String source) {
    final program = Compiler().compile({
      _package: {'main.dart': source},
    });
    _runtime = Runtime.ofProgram(program);
  }

  static const _package = 'combat_script';
  static const _library = 'package:$_package/main.dart';
  static const _function = 'decideShots';

  late final Runtime _runtime;

  @override
  List<ShotDecision> decideShots(CombatRequest request) {
    final towers = <double>[
      for (final t in request.readyTowers) ...[
        t.id.toDouble(),
        t.x,
        t.y,
        t.range,
        t.baseDamage,
        t.damageMultiplier,
      ],
    ];
    final enemies = <double>[
      for (final e in request.enemies) ...[
        e.id.toDouble(),
        e.x,
        e.y,
        e.distanceTravelled,
        e.health,
      ],
    ];

    final result = _runtime.executeLib(_library, _function, [
      _wrap(towers),
      _wrap(enemies),
    ]);
    return _readDecisions(result);
  }

  static $List<$Value> _wrap(List<double> numbers) =>
      $List.wrap([for (final n in numbers) $double(n)]);

  /// Turns the script's flat result back into [ShotDecision]s. Throws a
  /// [FormatException] if it is not a list of numbers in groups of 3.
  static List<ShotDecision> _readDecisions(Object? result) {
    final raw = result is $Value ? result.$value : result;
    if (raw is! List) {
      throw FormatException('The script returned $raw instead of a list.');
    }
    final numbers = [for (final item in raw) _readNumber(item)];
    if (numbers.length % 3 != 0) {
      throw FormatException(
        'The script returned ${numbers.length} numbers; '
        'expected groups of 3.',
      );
    }
    return [
      for (var i = 0; i < numbers.length; i += 3)
        ShotDecision(
          towerId: _readId(numbers[i]),
          targetEnemyId: _readId(numbers[i + 1]),
          damage: numbers[i + 2].toDouble(),
        ),
    ];
  }

  static num _readNumber(Object? item) {
    final value = item is $Value ? item.$value : item;
    if (value is! num) {
      throw FormatException('The script returned $value instead of a number.');
    }
    return value;
  }

  static int _readId(num value) {
    if (value != value.roundToDouble()) {
      throw FormatException('The script returned $value as an ID.');
    }
    return value.toInt();
  }
}
