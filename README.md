# Tower Defence Flame/dart_eval proof of concept

This is the Meeting 3 baseline for testing communication between a Flame game
loop and code evaluated by `dart_eval`.

For a detailed explanation of Flutter, the project structure, the Flame/sandbox
bridge, and physical-device testing, see the
[Development Guide](docs/DEVELOPMENT_GUIDE.md).

## Run

Install the Flutter stable SDK, then run:

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

The generated project targets Android and iOS. Git initialization and commits
are intentionally left to the project owner.

## Architecture

- `lib/game/tower_defence_game.dart` contains the Flame game and the static
  tower/dummy enemy components, straight-line enemy movement, firing range,
  and the on-screen event log.
- `lib/bridge/bridge_models.dart` contains the small value-only state and
  validated damage instruction crossing the bridge.
- `assets/scripts/damage.dart` contains the local dynamic module loaded at
  startup.
- `lib/bridge/sandbox_runner.dart` loads that module and evaluates it with
  `dart_eval`. Only primitive coordinates, health, and a validated integer
  instruction cross the boundary; Flame objects are never exposed.

The enemy starts to the left of the tower and moves in a straight line toward
it at 40 game units per second, stopping at the 50-unit firing radius. Every
500 ms the game builds a snapshot, evaluates the sandbox function, and applies
only a non-negative damage value in the range 0-100. Firing, range entry,
spawning, destruction, and sandbox errors appear in the bottom event log.
Invalid state or evaluation output is reported through `lastSandboxError` and
does not mutate the enemy.

This intentionally synchronous baseline is designed for later measurement of
evaluation time, allocation, and memory pressure. The module is currently
bundled as an asset to simulate downloaded code locally; replacing the asset
loader with a verified network loader is a later step. It is not yet a
complete tower defence game.
