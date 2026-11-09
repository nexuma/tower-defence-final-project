# Game Architecture

## AI-use disclaimer

This document was written with the assistance of artificial intelligence, from
architecture decisions made by the author during design sessions. The
reasoning for each decision is also recorded by the author in the
[decision log](decision-log.md), which remains the authoritative source.

## Purpose

This document describes how the tower-defence game is structured, which part
owns which responsibility, and why. It answers issue
[#19](https://github.com/nexuma/tower-defence-final-project/issues/19) and
should be updated whenever an architecture decision is added or changed.

The game is built from scratch in `tower_defence_code/`. The `prototype`
branch was a proof of concept that has already been demonstrated. It is
retired and its code is not reused; only its findings carry forward.

## Structure

```text
            ┌──────────────────── Flame (view) ────────────────────┐
  taps ───► │  InputHandler: "tap at pixel" → "place tower at (4,2)" │
            │  ViewSync: reads the model every frame → updates sprites│
            └───────┬───────────────────────────────▲──────────────┘
                    │ commands                       │ reads (pull)
                    ▼                                │
            ┌──────────────┐       changes       ┌───┴───┐
            │  GameEngine  │ ──────────────────► │ Model │  plain Dart data
            │  rules, tick │                     └───────┘
            └──────┬───────┘
                   │ CombatLogic interface
          ┌────────┴─────────┐
   SandboxCombatLogic   NativeCombatLogic
     (dart_eval)        (tests and baseline)
```

| Part | Responsibility | Must never |
| --- | --- | --- |
| **Model** | Holds the game state as plain Dart data: grid, towers, enemies, gold, score, wave. | Contain game rules, or depend on Flame or `dart_eval`. |
| **GameEngine** | Owns the game tick, applies rules (for example the FR-M1 placement limit), changes the model, and is the only part that calls combat logic. | Depend on Flame or know which `CombatLogic` implementation it is using. |
| **CombatLogic** | Interface: combat state in, result out. `SandboxCombatLogic` runs dynamically loaded code through `dart_eval`; `NativeCombatLogic` is plain Dart. | Change the model directly; it returns a result for the engine to apply. |
| **InputHandler** (Flame) | Turns player input into commands for the engine. | Decide whether a command is allowed, or change the model. |
| **ViewSync** (Flame) | Reads the model every frame and updates the Flame components to match. | Change the model. |

## Architecture decisions

| # | Decision | Alternatives considered | Reasoning |
| --- | --- | --- | --- |
| AD-1 | Game state lives in a plain Dart model; Flame only displays it. | State stored inside Flame components (the usual Flame style). | Every requirement (FR-M1 to FR-C2) is about state, rules or events rather than drawing. Rules can be unit-tested without starting Flame. The FR-M2 combat state is already plain data, so extracting it is simple. Graphics can change without touching the model. |
| AD-2 | The model and the engine are separate. The engine reaches combat logic only through a `CombatLogic` interface. | The model calls the `dart_eval` sandbox directly. | The model stays dependency-free. The engine can be tested without `dart_eval`. A native implementation gives a baseline for comparing dynamically loaded logic (performance, correctness) and a fallback if a loaded module fails. |
| AD-3 | Flame passes input to the engine as commands; the view never changes the model. | The view changes the model directly, or the reader also handles input. | There is one place where rules are applied, so FR-M1 cannot be bypassed from the UI. Telemetry (FR-S2) and logging (FR-C2) can observe commands in one place. |
| AD-4 | `ViewSync` pulls: it reads the model every frame. | Push: the model announces changes and the view reacts. | Flame redraws the whole screen every frame, so change notifications would save no drawing work. Most state (enemy positions) changes every tick, so push would flood the view with messages. The view is rebuilt from the model each frame, so it cannot drift out of sync, and the engine never needs to know the view exists. Costs: the model is read even when nothing changed, and `ViewSync` needs stable IDs to match model objects to components. Discrete events that must not be missed (telemetry, score, logs) are still pushed as events: pull for what is displayed, push for what is counted. Pull alone does not stop frame stalls when the engine is slow (see open questions). |
| AD-5 | The state-to-view reader is called `ViewSync`, and input is a separate `InputHandler`. | "Presenter" (implies it also handles input), "Renderer" (clashes with Flame's `render()`). | The name shows that it is one-way. |
| AD-6 | Towers and projectiles use the **Type Object** pattern: shared data lives in `TowerDefinition` and `ProjectileDefinition`, and each placed `Tower` refers to its definition by a string key. | One Dart subclass per tower type (`FireTower extends Tower`). | New tower and projectile types are data, so they can be loaded at runtime or created by merging (FR-C1) without a new build. Behaviour that differs between types belongs in `CombatLogic`, which can itself be loaded dynamically. A key rather than an object reference keeps the model easy to serialise for the sandbox (FR-M2), telemetry (FR-S2) and logs (FR-C2). Upgrades can later be expressed as switching a tower to another definition. Reference: R. Nystrom, *Game Programming Patterns*, "Type Object". |
| AD-7 | A tower's location is stored in one central map from tower ID to grid cell. There is no inventory: a tower only exists once it is placed. | Location on the tower; location in the grid; both. | One source of truth, so a tower cannot be recorded in two places. "Is this cell occupied?" (FR-M1) is answered from the same map. Only grid cells are supported for now; incubator slots (FR-C1) are added when that requirement starts. |
| AD-8 | Tower IDs are incrementing integers issued by the engine. | Random UUIDs. | Readable in logs and deterministic between runs, which keeps tests repeatable and makes replaying a wave possible. UUIDs are only needed once towers are shared between players. |
| AD-9 | Shots use a **delayed hit**. Firing creates a `PendingShot` in the model with a countdown; the engine resolves it at impact. The view animates the projectile from that countdown. | Instant hit (damage applied on firing, animation only); fully simulated travelling projectiles. | What the player sees matches what happens: damage lands when the projectile arrives. The view's animation progress (`1 − timeUntilImpact / flightTime`) uses the same number as the engine, so the two cannot drift. No projectile physics is needed in the model. |
| AD-10 | At impact, a shot lands on its target's current position, or on the last known position if the target has died. An enemy is hit when the projectile's hit circle overlaps the enemy's hitbox. `hitsAll` decides whether one enemy (the target, or else the nearest) or every overlapping enemy is hit. | Shots disappear when their target dies; exact-point hits. | Shots are never silently lost: an arrow can still hit an enemy that moved into the spot, and a boulder still splashes. Hit detection is done by the engine (circle overlap), not by Flame's collision system. This replaces the earlier note that collision would remain native in Flame. |
| AD-11 | Shot damage is the projectile's base damage multiplied by the tower's `damageMultiplier`, worked out when the shot is fired. | Damage on the tower only; damage on the projectile only; adding instead of multiplying. | The same projectile keeps its character from any tower, while stronger towers scale it. Multiplying keeps the proportions between projectiles, which makes balancing easier. Fixing the damage when the shot is fired means later upgrades or effects do not change shots already in the air. |

## Domain model

All distances are in **grid cells** (decimals allowed) and all times in
**seconds**. Pixels exist only in the view.

### Tower

```text
TowerDefinition        one per kind of tower ("fire", "catapult", ...)
  key                  stable ID, used by telemetry and the view's sprite lookup
  name                 display name shown in the tower selector
  range                cells; enemies within this distance can be targeted
  cooldown             seconds between shots
  damageMultiplier     multiplies the projectile's base damage
  projectileKey        which ProjectileDefinition it fires

ProjectileDefinition   one per kind of projectile ("arrow", "boulder", ...)
  key                  stable ID
  damage               base damage per hit
  hitRadius            cells; size of the hit circle at impact
  hitsAll              false: one enemy is hit; true: every overlapping enemy
  flightTime           seconds from firing to impact (fixed)

Tower                  one per placed tower (its location is in the central map, AD-7)
  id                   incrementing integer (AD-8)
  definitionKey        which TowerDefinition it is
  timeUntilNextShot    seconds; counts down during play

PendingShot            one per projectile in the air (AD-9)
  towerId              who fired it: animation start point, telemetry
  projectileKey        what it is: hit rule and animation
  targetEnemyId        the enemy it is aimed at
  damage               worked out when fired (AD-11)
  timeUntilImpact      seconds; resolved when it reaches 0
  lastKnownTargetPosition  updated every tick while the target is alive (AD-10)
```

The tower selector shows a definition's name, range, projectile and damage per
second. Damage per second is calculated for display
(`projectile damage × damageMultiplier ÷ cooldown`) rather than stored.

**Needed from later steps:** enemies need an `id`, a position in cells and a
hitbox `radius` (AD-10).

**Deliberately left out for now:** genetics and unique towers, gold and tower
cost, inventory, upgrades, status effects (slow, poison), dodging. The design
leaves room for each of these.

## Open architecture questions

- **Engine timing.** Dart runs the engine and Flame on one thread, so a slow
  `engine.tick()` or sandbox call delays the frame even with pull-based
  rendering. To decide: should the engine tick at a fixed rate separate from
  the frame rate, and should sandbox calls have a time budget or run off the
  main thread?
- **Sandbox call frequency** (Meeting 6): every frame, every attack cooldown,
  or once per batch? Should it receive all enemies or only those in range?
  Should enemy information be passed one enemy at a time or all together?
  This will be answered by testing the new `CombatLogic` implementation.
- **Events.** FR-S1, FR-S2 and FR-C2 need a record of what happened (enemy
  defeated, tower placed, game ended). To decide: how does the engine publish
  these events, and who listens?

## Next design steps

1. Domain model: tower ✅; still to do: enemy, cell and grid, wave, game state
   ([#11](https://github.com/nexuma/tower-defence-final-project/issues/11),
   [#12](https://github.com/nexuma/tower-defence-final-project/issues/12)).
2. First rule: the signature and behaviour of tower placement, FR-M1
   ([#1](https://github.com/nexuma/tower-defence-final-project/issues/1)).
3. Events and listeners (FR-S1, FR-S2, FR-C2).
4. The Flame layer: `InputHandler` and `ViewSync`
   ([#8](https://github.com/nexuma/tower-defence-final-project/issues/8),
   [#13](https://github.com/nexuma/tower-defence-final-project/issues/13)).
5. The `CombatLogic` sandbox boundary (FR-M2,
   [#2](https://github.com/nexuma/tower-defence-final-project/issues/2),
   [#9](https://github.com/nexuma/tower-defence-final-project/issues/9)).
6. The folder structure, which follows from the steps above
   ([#10](https://github.com/nexuma/tower-defence-final-project/issues/10)).
