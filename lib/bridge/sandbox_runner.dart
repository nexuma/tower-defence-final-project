import 'package:dart_eval/dart_eval.dart';
import 'package:flutter/services.dart';

import 'bridge_models.dart';

class SandboxEvaluationException implements Exception {
  const SandboxEvaluationException(this.message);

  final String message;

  @override
  String toString() => 'SandboxEvaluationException: $message';
}

class DamageSandbox {
  DamageSandbox(this._script);

  static Future<DamageSandbox> fromAsset([
    String assetPath = 'assets/scripts/damage.dart',
  ]) async {
    final script = await rootBundle.loadString(assetPath);
    return DamageSandbox(script);
  }

  final String _script;

  DamageInstruction evaluate(CombatState state) {
    if (!isFiniteState(state) || state.enemyHealth < 0) {
      throw const SandboxEvaluationException('Invalid combat state');
    }

    try {
      final result = eval(
        _script,
        function: 'calculateDamage',
        args: state.toSandboxArguments(),
      );
      return DamageInstruction.fromSandboxResult(result);
    } on FormatException catch (error) {
      throw SandboxEvaluationException(error.message);
    } catch (error) {
      throw SandboxEvaluationException('Evaluation failed: $error');
    }
  }
}
