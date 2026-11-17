import 'dart:math' as math;

import 'package:flame/game.dart';

import '../engine/game_engine.dart';
import 'board_layout.dart';
import 'input_handler.dart';
import 'view_sync.dart';

/// The Flame game: runs the engine once per frame and holds the two view
/// parts, [InputHandler] and [ViewSync].
class TowerDefenceGame extends FlameGame {
  TowerDefenceGame({required this.engine})
    : layout = BoardLayout(
        columns: engine.state.map.width,
        rows: engine.state.map.height,
      );

  final GameEngine engine;
  final BoardLayout layout;
  late final InputHandler input;

  /// The longest step the engine is given in one frame, in seconds. After a
  /// pause (for example a dragged window) the game slows down instead of
  /// jumping ahead. The engine-timing question is still open.
  static const maxStep = 0.1;

  @override
  Future<void> onLoad() async {
    input = InputHandler(engine: engine, layout: layout);
    add(input);
    add(ViewSync(state: engine.state, layout: layout, input: input));
  }

  @override
  void onGameResize(Vector2 size) {
    layout.resize(size);
    super.onGameResize(size);
  }

  @override
  void update(double dt) {
    engine.tick(math.min(dt, maxStep));
    super.update(dt);
  }
}
