import 'package:flutter/material.dart';

import 'tower_defence_game.dart';

/// Flutter buttons drawn on top of the game. They send commands through the
/// game's [InputHandler], like taps on the board.
class ControlsOverlay extends StatelessWidget {
  const ControlsOverlay({super.key, required this.game});

  /// The name the overlay is registered under in the GameWidget.
  static const id = 'controls';

  final TowerDefenceGame game;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: game.input.startNextWave,
          child: const Text('Next wave'),
        ),
      ),
    );
  }
}
