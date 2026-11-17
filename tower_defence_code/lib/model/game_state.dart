import 'cell.dart';
import 'enemy.dart';
import 'game_map.dart';
import 'projectile.dart';
import 'tower.dart';
import 'wave.dart';

/// Whether the game is still running, and how it ended.
enum GameStatus {
  /// Waves are still being played.
  playing,

  /// Every wave was cleared with lives remaining.
  won,

  /// Lives reached 0.
  lost,
}

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
    this.maxTowers = 5,
  });

  final GameMap map;

  /// The player loses when this reaches 0.
  int lives;

  /// Definitions by key (AD-6).
  final Map<String, TowerDefinition> towerDefinitions;
  final Map<String, ProjectileDefinition> projectileDefinitions;
  final Map<String, EnemyDefinition> enemyDefinitions;

  /// How many towers may be on the board at once (FR-M1).
  final int maxTowers;

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

  /// How many waves have been started. The wave in play is
  /// `waves[wavesStarted - 1]`.
  int wavesStarted = 0;

  /// True from the moment a wave is started until it is fully spawned and
  /// every enemy in it is gone.
  bool waveInProgress = false;

  /// Which [SpawnGroup] of the current wave is spawning.
  int spawnGroupIndex = 0;

  /// How many enemies of that group have been spawned so far.
  int spawnedInGroup = 0;

  /// Seconds until the next enemy is spawned.
  double timeUntilNextSpawn = 0;

  /// Set by the engine when the game ends.
  GameStatus status = GameStatus.playing;
}
