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

## Architecture decisions (9 November 2026)

| # | Decision | Alternatives considered | Reasoning |
| --- | --- | --- | --- |
| AD-1 | Game state lives in a plain Dart model; Flame only displays it. | State stored inside Flame components (the usual Flame style). | Every requirement (FR-M1 to FR-C2) is about state, rules or events rather than drawing. Rules can be unit-tested without starting Flame. The FR-M2 combat state is already plain data, so extracting it is simple. Graphics can change without touching the model. |
| AD-2 | The model and the engine are separate. The engine reaches combat logic only through a `CombatLogic` interface. | The model calls the `dart_eval` sandbox directly. | The model stays dependency-free. The engine can be tested without `dart_eval`. A native implementation gives a baseline for comparing dynamically loaded logic (performance, correctness) and a fallback if a loaded module fails. |
| AD-3 | Flame passes input to the engine as commands; the view never changes the model. | The view changes the model directly, or the reader also handles input. | There is one place where rules are applied, so FR-M1 cannot be bypassed from the UI. Telemetry (FR-S2) and logging (FR-C2) can observe commands in one place. |
| AD-4 | `ViewSync` pulls: it reads the model every frame. | Push: the model announces changes and the view reacts. | Flame redraws the whole screen every frame, so change notifications would save no drawing work. Most state (enemy positions) changes every tick, so push would flood the view with messages. The view is rebuilt from the model each frame, so it cannot drift out of sync, and the engine never needs to know the view exists. Costs: the model is read even when nothing changed, and `ViewSync` needs stable IDs to match model objects to components. Discrete events that must not be missed (telemetry, score, logs) are still pushed as events: pull for what is displayed, push for what is counted. Pull alone does not stop frame stalls when the engine is slow (see open questions). |
| AD-5 | The state-to-view reader is called `ViewSync`, and input is a separate `InputHandler`. | "Presenter" (implies it also handles input), "Renderer" (clashes with Flame's `render()`). | The name shows that it is one-way. |

## Open architecture questions

- **Engine timing.** Dart runs the engine and Flame on one thread, so a slow
  `engine.tick()` or sandbox call delays the frame even with pull-based
  rendering. To decide: should the engine tick at a fixed rate separate from
  the frame rate, and should sandbox calls have a time budget or run off the
  main thread?
- **Sandbox call frequency** (Meeting 6): every frame, every attack cooldown,
  or once per batch? Should it receive all enemies or only those in range? An
  early benchmark on the retired prototype found about 3.4 ms per `eval()`
  call compared with about 4.5 µs per call on a compiled `Runtime` that is
  reused, which suggests compiling modules once. These numbers are only
  indicative: the benchmarks will be repeated on the new `CombatLogic`
  implementation, including batched calls with several enemies.
- **Events.** FR-S1, FR-S2 and FR-C2 need a record of what happened (enemy
  defeated, tower placed, game ended). To decide: how does the engine publish
  these events, and who listens?

## Next design steps

1. Domain model: the fields of tower, enemy, cell, wave and game state
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
