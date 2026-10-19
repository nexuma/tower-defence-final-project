import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../bridge/bridge_models.dart';
import '../bridge/sandbox_runner.dart';

class TowerDefenceGame extends FlameGame {
  static const firingRange = 50.0;
  static const enemySpeed = 40.0;

  TowerDefenceGame({DamageSandbox? sandbox}) {
    _sandbox = sandbox;
  }

  DamageSandbox? _sandbox;
  late final TowerComponent tower;
  late final EnemyComponent enemy;
  double _attackTimer = 0;
  bool _enemyEnteredRange = false;
  final List<String> eventLog = [];
  String? lastSandboxError;

  @override
  Future<void> onLoad() async {
    _sandbox ??= await DamageSandbox.fromAsset();
    tower = TowerComponent(position: Vector2(160, 240));
    enemy = EnemyComponent(position: Vector2(40, 240), health: 100);
    await add(
      TowerRangeComponent(position: tower.position, radius: firingRange),
    );
    await add(tower);
    await add(enemy);
    _log('Enemy spawned');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (enemy.health > 0) {
      enemy.advanceToward(
        tower.position,
        dt: dt,
        speed: enemySpeed,
        stopDistance: firingRange,
      );
    }

    final distance = enemy.position.distanceTo(tower.position);
    if (!_enemyEnteredRange && distance <= firingRange) {
      _enemyEnteredRange = true;
      _log('Enemy entered firing range');
    }

    _attackTimer += dt;
    if (_attackTimer < 0.5 || enemy.health == 0) {
      return;
    }
    _attackTimer = 0;

    final state = CombatState(
      towerX: tower.position.x,
      towerY: tower.position.y,
      enemyX: enemy.position.x,
      enemyY: enemy.position.y,
      enemyHealth: enemy.health,
    );

    try {
      final instruction = _sandbox!.evaluate(state);
      if (instruction.damage > 0) {
        enemy.applyDamage(instruction.damage);
        _log('Tower fired: ${instruction.damage} damage');
        if (enemy.health == 0) {
          _log('Enemy destroyed');
        }
      }
      lastSandboxError = null;
    } on SandboxEvaluationException catch (error) {
      lastSandboxError = error.toString();
      _log('Sandbox error');
    }
  }

  void _log(String message) {
    eventLog.add(message);
    if (eventLog.length > 5) {
      eventLog.removeAt(0);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final logRect = Rect.fromLTWH(12, size.y - 132, size.x - 24, 120);
    canvas.drawRect(
      logRect,
      Paint()..color = Colors.black.withValues(alpha: 0.72),
    );

    final painter = TextPainter(
      text: TextSpan(
        text: 'EVENT LOG\n${eventLog.join('\n')}',
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: logRect.width - 16);
    painter.paint(canvas, logRect.topLeft + const Offset(8, 8));
  }
}

class TowerComponent extends PositionComponent {
  TowerComponent({required super.position})
    : super(size: Vector2.all(48), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), Paint()..color = Colors.blueAccent);
  }
}

class TowerRangeComponent extends PositionComponent {
  TowerRangeComponent({required super.position, required double radius})
    : _radius = radius,
      super(size: Vector2.all(radius * 2), anchor: Anchor.center);

  final double _radius;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      _radius,
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      _radius,
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}

class EnemyComponent extends PositionComponent {
  EnemyComponent({required super.position, required this.health})
    : super(size: Vector2.all(32), anchor: Anchor.center);

  int health;

  void advanceToward(
    Vector2 target, {
    required double dt,
    required double speed,
    required double stopDistance,
  }) {
    final direction = target - position;
    final distance = direction.length;
    if (distance <= stopDistance) {
      return;
    }

    final movement = (speed * dt)
        .clamp(0.0, distance - stopDistance)
        .toDouble();
    position += direction.normalized() * movement;
  }

  void applyDamage(int damage) {
    health = (health - damage).clamp(0, 100);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      Paint()..color = health == 0 ? Colors.grey : Colors.redAccent,
    );
  }
}
