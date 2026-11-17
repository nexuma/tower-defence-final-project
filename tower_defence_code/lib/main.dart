import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'combat_logic/fallback_combat_logic.dart';
import 'combat_logic/native_combat_logic.dart';
import 'combat_logic/sandbox_combat_logic.dart';
import 'content/first_level.dart';
import 'engine/game_engine.dart';
import 'view/combat_controls.dart';
import 'view/controls_overlay.dart';
import 'view/tower_defence_game.dart';

void main() {
  runApp(const TowerDefenceApp());
}

/// The combat scripts in `assets/combat_scripts/`, in button order.
const combatScripts = ['first_targeting', 'strongest_targeting'];

/// The composition root (AD-12): builds the parts and connects them.
TowerDefenceGame createGame() {
  final engine = GameEngine(
    state: firstLevel(),
    combatLogic: const NativeCombatLogic(),
  );

  var scriptName = 'none';
  FallbackCombatLogic? sandboxed;
  String? loadError;

  // Loads a script from the assets, compiles it, and swaps it into the
  // running engine. If anything fails, the engine uses the native logic.
  // Later only the line that reads the text changes, to read a downloaded file.
  Future<void> load(String name) async {
    scriptName = name;
    try {
      final source = await rootBundle.loadString(
        'assets/combat_scripts/$name.dart',
      );
      final logic = FallbackCombatLogic(
        primary: SandboxCombatLogic(source),
        fallback: const NativeCombatLogic(),
      );
      engine.combatLogic = logic;
      sandboxed = logic;
      loadError = null;
    } catch (error) {
      engine.combatLogic = const NativeCombatLogic();
      sandboxed = null;
      loadError = '$error';
    }
  }

  String status() {
    final error = loadError;
    if (error != null) {
      return 'native ($scriptName did not load: ${_short(error)})';
    }
    final logic = sandboxed;
    if (logic == null) return 'native';
    final failure = logic.failureReason;
    if (failure != null) {
      return 'native ($scriptName failed: ${_short(failure)})';
    }
    return '$scriptName (sandbox)';
  }

  return TowerDefenceGame(
    engine: engine,
    combatControls: CombatControls(
      scriptNames: combatScripts,
      load: load,
      status: status,
    ),
  );
}

String _short(String text) {
  final firstLine = text.split('\n').first;
  return firstLine.length <= 80
      ? firstLine
      : '${firstLine.substring(0, 80)}...';
}

class TowerDefenceApp extends StatelessWidget {
  const TowerDefenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tower Defence',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: GameWidget<TowerDefenceGame>.controlled(
        gameFactory: createGame,
        overlayBuilderMap: {
          ControlsOverlay.id: (context, game) => ControlsOverlay(game: game),
        },
        initialActiveOverlays: const [ControlsOverlay.id],
      ),
    );
  }
}
