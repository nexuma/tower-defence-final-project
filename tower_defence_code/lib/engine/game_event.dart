import '../model/cell.dart';
import '../model/game_state.dart';
import 'game_engine.dart';

/// Something that happened in the game, published by the engine to its
/// listeners. Used for what must be counted rather than displayed: score,
/// telemetry (FR-S2) and the local log (FR-C2). See AD-4 and AD-19.
///
/// The class is sealed, so a `switch` over a [GameEvent] must handle every
/// kind of event.
sealed class GameEvent {
  const GameEvent();
}

/// The player placed a tower (FR-M1, FR-S2).
class TowerPlaced extends GameEvent {
  const TowerPlaced({
    required this.towerId,
    required this.towerKey,
    required this.cell,
  });

  final int towerId;
  final String towerKey;
  final Cell cell;
}

/// The player tried to place a tower and the engine refused (FR-C2).
class PlacementRejected extends GameEvent {
  const PlacementRejected({
    required this.towerKey,
    required this.cell,
    required this.reason,
  });

  final String towerKey;
  final Cell cell;
  final PlacementResult reason;
}

/// A wave started. [waveNumber] starts at 1.
class WaveStarted extends GameEvent {
  const WaveStarted({required this.waveNumber});

  final int waveNumber;
}

/// Every enemy of a wave was spawned and is gone. [waveNumber] starts at 1.
class WaveCleared extends GameEvent {
  const WaveCleared({required this.waveNumber});

  final int waveNumber;
}

class EnemySpawned extends GameEvent {
  const EnemySpawned({required this.enemyId, required this.enemyKey});

  final int enemyId;
  final String enemyKey;
}

/// A tower's shot defeated an enemy (FR-S1).
class EnemyDefeated extends GameEvent {
  const EnemyDefeated({
    required this.enemyId,
    required this.enemyKey,
    required this.towerId,
    required this.scoreValue,
  });

  final int enemyId;
  final String enemyKey;

  /// The tower whose shot defeated it.
  final int towerId;

  /// The points added to the score.
  final int scoreValue;
}

/// An enemy reached the base and cost a life.
class EnemyReachedBase extends GameEvent {
  const EnemyReachedBase({
    required this.enemyId,
    required this.enemyKey,
    required this.livesLeft,
  });

  final int enemyId;
  final String enemyKey;
  final int livesLeft;
}

/// The game was won or lost (FR-C2 victory metrics).
class GameEnded extends GameEvent {
  const GameEnded({
    required this.status,
    required this.score,
    required this.livesLeft,
    required this.wavesCleared,
  });

  final GameStatus status;
  final int score;
  final int livesLeft;
  final int wavesCleared;
}
