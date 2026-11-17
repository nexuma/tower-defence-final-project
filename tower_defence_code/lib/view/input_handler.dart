import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../engine/game_engine.dart';
import 'board_layout.dart';

/// Turns player input into commands for the engine (AD-3, AD-5).
///
/// It never decides whether a command is allowed: the engine does, and the
/// result is kept in [lastMessage] so the HUD can show it.
class InputHandler extends PositionComponent with TapCallbacks {
  InputHandler({required this.engine, required this.layout});

  final GameEngine engine;
  final BoardLayout layout;

  /// The tower kind placed on tap. Only one kind exists for now; the tower
  /// selector will set this later.
  String selectedTowerKey = 'archer';

  /// Feedback for the player about the last command, or null.
  String? lastMessage;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size; // catch taps anywhere on the screen
  }

  @override
  void onTapDown(TapDownEvent event) {
    final cell = layout.cellAt(event.localPosition);
    if (cell == null) return;
    final result = engine.placeTower(selectedTowerKey, cell);
    lastMessage = switch (result) {
      PlacementResult.placed => null,
      PlacementResult.gameOver => 'The game is over',
      PlacementResult.unknownTower => 'Unknown tower',
      PlacementResult.outsideBoard => null,
      PlacementResult.onPath => 'Towers cannot go on the path',
      PlacementResult.occupied => 'That cell already has a tower',
      PlacementResult.tooManyTowers =>
        'At most ${engine.state.maxTowers} towers',
    };
  }

  /// Command from the "Next wave" button.
  void startNextWave() {
    lastMessage = engine.startNextWave() ? null : 'Finish this wave first';
  }
}
