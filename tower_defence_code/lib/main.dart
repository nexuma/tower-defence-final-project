import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'combat_logic/native_combat_logic.dart';
import 'content/first_level.dart';
import 'engine/game_engine.dart';
import 'view/controls_overlay.dart';
import 'view/tower_defence_game.dart';

void main() {
  runApp(const TowerDefenceApp());
}

/// The composition root (AD-12): builds the parts and connects them.
TowerDefenceGame createGame() => TowerDefenceGame(
  engine: GameEngine(
    state: firstLevel(),
    combatLogic: const NativeCombatLogic(),
  ),
);

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
