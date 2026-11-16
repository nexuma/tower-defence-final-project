import 'cell.dart';
import 'enemy.dart';
import 'game_map.dart';
import 'projectile.dart';
import 'tower.dart';
import 'wave.dart';

/// Everything that describes a game in progress, as plain data.
///
/// The model holds no rules: only the engine changes it (AD-1, AD-2).
class GameState {
  GameState({
    required this.map,
    required this.lives,
    required this.towerDefinitions,
    required this.projectileDefinitions,
    required this.enemyDefinitions,
    required this.waves,
  });

  final GameMap map;

  /// The player loses when this reaches 0.
  int lives;

  /// Definitions by key (AD-6).
  final Map<String, TowerDefinition> towerDefinitions;
  final Map<String, ProjectileDefinition> projectileDefinitions;
  final Map<String, EnemyDefinition> enemyDefinitions;

  /// Placed towers by ID.
  final Map<int, Tower> towers = {};

  /// Where each tower is: the single source of truth for location (AD-7).
  final Map<int, Cell> towerCells = {};

  /// Enemies on the board by ID.
  final Map<int, Enemy> enemies = {};

  /// Projectiles in the air (AD-9).
  final List<PendingShot> shots = [];

  /// The waves of this game, in order.
  final List<Wave> waves;

  /// Index into [waves] of the wave being played.
  int currentWaveIndex = 0;
}
