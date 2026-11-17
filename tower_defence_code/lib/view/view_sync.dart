import 'dart:ui' hide TextStyle;

import 'package:flame/components.dart';
import 'package:flame/text.dart';

import '../model/cell.dart';
import '../model/game_state.dart';
import '../model/position.dart';
import 'board_layout.dart';
import 'input_handler.dart';

/// Reads the model every frame and draws it (AD-4, AD-5). It never changes
/// the model.
///
/// For now everything is drawn as simple shapes straight from the model, so
/// no components need to be matched to model IDs. Sprites come later.
class ViewSync extends Component {
  ViewSync({required this.state, required this.layout, required this.input});

  final GameState state;
  final BoardLayout layout;
  final InputHandler input;

  static final _grass = Paint()..color = const Color(0xFF3B6E3B);
  static final _gridLine = Paint()
    ..color = const Color(0x33000000)
    ..style = PaintingStyle.stroke;
  static final _pathPaint = Paint()..color = const Color(0xFFC9A66B);
  static final _basePaint = Paint()..color = const Color(0xFF8E3B3B);
  static final _towerPaint = Paint()..color = const Color(0xFF2F5D9E);
  static final _rangePaint = Paint()
    ..color = const Color(0x55FFFFFF)
    ..style = PaintingStyle.stroke;
  static final _enemyPaint = Paint()..color = const Color(0xFFD94A4A);
  static final _healthBack = Paint()..color = const Color(0xFF000000);
  static final _healthFront = Paint()..color = const Color(0xFF55E055);
  static final _shotPaint = Paint()..color = const Color(0xFFFFE066);
  static final _hudText = TextPaint(
    style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 18),
  );
  static final _bigText = TextPaint(
    style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 48),
  );

  @override
  void render(Canvas canvas) {
    _drawBoard(canvas);
    _drawTowers(canvas);
    _drawEnemies(canvas);
    _drawShots(canvas);
    _drawHud(canvas);
  }

  Rect _cellRect(int x, int y) => Rect.fromLTWH(
    layout.origin.x + x * layout.cellSize,
    layout.origin.y + y * layout.cellSize,
    layout.cellSize,
    layout.cellSize,
  );

  Offset _offset(Position position) => layout.toPixels(position).toOffset();

  void _drawBoard(Canvas canvas) {
    final map = state.map;
    for (var x = 0; x < map.width; x++) {
      for (var y = 0; y < map.height; y++) {
        final rect = _cellRect(x, y);
        canvas.drawRect(rect, map.isOnPath(Cell(x, y)) ? _pathPaint : _grass);
        canvas.drawRect(rect, _gridLine);
      }
    }
    final base = map.path.last;
    canvas.drawRect(_cellRect(base.x, base.y).deflate(4), _basePaint);
  }

  void _drawTowers(Canvas canvas) {
    for (final entry in state.towerCells.entries) {
      final tower = state.towers[entry.key]!;
      final definition = state.towerDefinitions[tower.definitionKey]!;
      final centre = _offset(Position.centreOf(entry.value));
      canvas.drawCircle(
        centre,
        layout.toPixelLength(definition.range),
        _rangePaint,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: centre,
          width: layout.cellSize * 0.7,
          height: layout.cellSize * 0.7,
        ),
        _towerPaint,
      );
    }
  }

  void _drawEnemies(Canvas canvas) {
    for (final enemy in state.enemies.values) {
      final definition = state.enemyDefinitions[enemy.definitionKey]!;
      final centre = _offset(state.map.positionAt(enemy.distanceTravelled));
      final radius = layout.toPixelLength(definition.radius);
      canvas.drawCircle(centre, radius, _enemyPaint);

      final barWidth = radius * 2;
      final barTop = centre.dy - radius - 8;
      final health = (enemy.health / definition.maxHealth).clamp(0.0, 1.0);
      canvas.drawRect(
        Rect.fromLTWH(centre.dx - radius, barTop, barWidth, 4),
        _healthBack,
      );
      canvas.drawRect(
        Rect.fromLTWH(centre.dx - radius, barTop, barWidth * health, 4),
        _healthFront,
      );
    }
  }

  /// AD-9: the projectile is drawn part-way between the tower and its target,
  /// using the same countdown as the engine.
  void _drawShots(Canvas canvas) {
    for (final shot in state.shots) {
      final cell = state.towerCells[shot.towerId];
      if (cell == null) continue;
      final flightTime =
          state.projectileDefinitions[shot.projectileKey]!.flightTime;
      final progress = (1 - shot.timeUntilImpact / flightTime).clamp(0.0, 1.0);
      final from = Position.centreOf(cell);
      final to = shot.lastKnownTargetPosition;
      final now = Position(
        from.x + (to.x - from.x) * progress,
        from.y + (to.y - from.y) * progress,
      );
      canvas.drawCircle(_offset(now), layout.cellSize * 0.1, _shotPaint);
    }
  }

  void _drawHud(Canvas canvas) {
    final waveText = '${state.wavesStarted} / ${state.waves.length}';
    final towersText = '${state.towers.length} / ${state.maxTowers}';
    var text = 'Lives ${state.lives}    Wave $waveText    Towers $towersText';
    final message = input.lastMessage;
    if (message != null) text += '    $message';
    _hudText.render(canvas, text, Vector2(12, 10));

    final ending = switch (state.status) {
      GameStatus.playing => null,
      GameStatus.won => 'You win!',
      GameStatus.lost => 'Game over',
    };
    if (ending != null) {
      final centre =
          layout.origin +
          Vector2(
            layout.cellSize * state.map.width / 2,
            layout.cellSize * state.map.height / 2,
          );
      _bigText.render(canvas, ending, centre, anchor: Anchor.center);
    }
  }
}
