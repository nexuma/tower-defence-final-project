# Project Plan

## AI-use disclaimer

This file was generated and structured with the assistance of artificial intelligence. The underlying project sources, including the GitHub Issues and the [Project Decision
Log](docs/roadmap/decision-log.md), were created and maintained separately from this generated plan. AI was used as a convenience tool to organise information from those sources into a readable project schedule; it was not
used as a substitute for the underlying decisions, evidence, or task records. The GitHub Issues, decision log, meeting records, and technical experiments remain the authoritative sources.

## Purpose

This is the high-level plan for the Level 4 individual project. It records the intended sequence of work without replacing the detailed GitHub Issues, the project roadmap, or the decision log.

## How this plan is maintained

- **GitHub Issues** record individual tasks, acceptance criteria, and
  completion status.
- The [project board](https://github.com/nexuma/tower-defence-final-project)
  records the current workflow status.
- The [Project Direction and Exploration Roadmap](docs/roadmap/project-direction.md)
  records possible research directions and scope decisions.
- The [Project Decision Log](docs/roadmap/decision-log.md) records important
  decisions and their reasoning.
- The [Project Time Log](timelog.md) records actual hours spent.
- This file records the planned sequence, milestones, and broad weekly focus.

The plan should be updated when new evidence changes the order or scope of
work. Do not treat an uncompleted plan item as a failure if the direction was
deliberately changed and the decision was recorded.

## Current project direction

The current working direction is to:

1. build a small Flutter and Flame tower-defence host;
2. use the existing prototype evidence to develop a constrained
   Flame-to-`dart_eval` runtime bridge;
3. evaluate replaceability, validation, reliability, and performance;
4. collect lightweight, structured telemetry; and
5. select one focused application, such as dynamic balancing, configuration
   search, recommendations, dynamic telemetry, or multi-user comparison.

The possible applications remain under investigation. The project should not
attempt to implement all of them.

## Game architecture

The game is built from scratch in `tower_defence_code/`. The `prototype`
branch was a proof of concept that has already been demonstrated. It is
retired and its code is not reused; only its findings carry forward.

### Structure

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

### Architecture decisions (9 November 2026)

| # | Decision | Alternatives considered | Reasoning |
| --- | --- | --- | --- |
| AD-1 | Game state lives in a plain Dart model; Flame only displays it. | State stored inside Flame components (the usual Flame style). | Every requirement (FR-M1 to FR-C2) is about state, rules or events rather than drawing. Rules can be unit-tested without starting Flame. The FR-M2 combat state is already plain data, so extracting it is simple. Graphics can change without touching the model. |
| AD-2 | The model and the engine are separate. The engine reaches combat logic only through a `CombatLogic` interface. | The model calls the `dart_eval` sandbox directly. | The model stays dependency-free. The engine can be tested without `dart_eval`. A native implementation gives a baseline for comparing dynamically loaded logic (performance, correctness) and a fallback if a loaded module fails. |
| AD-3 | Flame passes input to the engine as commands; the view never changes the model. | The view changes the model directly, or the reader also handles input. | There is one place where rules are applied, so FR-M1 cannot be bypassed from the UI. Telemetry (FR-S2) and logging (FR-C2) can observe commands in one place. |
| AD-4 | `ViewSync` pulls: it reads the model every frame. | Push: the model announces changes and the view reacts. | Simpler wiring. The view always shows the latest finished state, and the frame rate is independent of how often the model changes. Pull alone does not stop frame stalls when the engine is slow (see open questions). |
| AD-5 | The state-to-view reader is called `ViewSync`, and input is a separate `InputHandler`. | "Presenter" (implies it also handles input), "Renderer" (clashes with Flame's `render()`). | The name shows that it is one-way. |

### Open architecture questions

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

### Next design steps

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

## Week-by-week plan

| Period                          | Planned focus                                                                                                                                                        | Main references                                                                                                                                                                                                                                                                                                                                                                                                                      | Status                  |
| ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------- |
| Before implementation           | Establish the requirements baseline, project direction, decision log, time log, and reference-management workflow.                                                   | [#18](https://github.com/nexuma/tower-defence-final-project/issues/18), [#24](https://github.com/nexuma/tower-defence-final-project/issues/24), [#26](https://github.com/nexuma/tower-defence-final-project/issues/26)                                                                                                                                                                                                                  | In progress             |
| 2–8 November 2026              | Review and clean up meeting minutes, backfill the time log, and confirm the current architecture and prototype evidence.                                             | [#29](https://github.com/nexuma/tower-defence-final-project/issues/29), [#30](https://github.com/nexuma/tower-defence-final-project/issues/30), [#19](https://github.com/nexuma/tower-defence-final-project/issues/19), [#21](https://github.com/nexuma/tower-defence-final-project/issues/21)                                                                                                                                           | Planned                 |
| November 2026                   | Replace the default Flutter application with the minimal game host and establish the Flame, game-state, board, and component foundations.                            | [#7](https://github.com/nexuma/tower-defence-final-project/issues/7), [#8](https://github.com/nexuma/tower-defence-final-project/issues/8), [#10](https://github.com/nexuma/tower-defence-final-project/issues/10), [#11](https://github.com/nexuma/tower-defence-final-project/issues/11), [#12](https://github.com/nexuma/tower-defence-final-project/issues/12), [#13](https://github.com/nexuma/tower-defence-final-project/issues/13) | Planned                 |
| November–early December 2026   | Prepare the status report, define the testing approach, and implement or adapt the core tower-placement and dynamic-damage experiments.                              | [#20](https://github.com/nexuma/tower-defence-final-project/issues/20), [#1](https://github.com/nexuma/tower-defence-final-project/issues/1), [#2](https://github.com/nexuma/tower-defence-final-project/issues/2), [#22](https://github.com/nexuma/tower-defence-final-project/issues/22)                                                                                                                                               | Planned                 |
| 15 December 2026                | Submit the Semester 1 status report by 17:00 through Moodle and email it to the supervisor.                                                                          | [#22](https://github.com/nexuma/tower-defence-final-project/issues/22)                                                                                                                                                                                                                                                                                                                                                                | Deadline                |
| December 2026–January 2027     | Consolidate the core implementation, testing evidence, telemetry structure, and technical measurements.                                                              | [#2](https://github.com/nexuma/tower-defence-final-project/issues/2), [#4](https://github.com/nexuma/tower-defence-final-project/issues/4), [#15](https://github.com/nexuma/tower-defence-final-project/issues/15), [#16](https://github.com/nexuma/tower-defence-final-project/issues/16)                                                                                                                                               | Planned                 |
| January–February 2027          | Select and evaluate one focused application of the runtime architecture, such as recommendations, configuration search, dynamic telemetry, or multi-user comparison. | [Project Direction and Exploration Roadmap](docs/roadmap/project-direction.md), [#3](https://github.com/nexuma/tower-defence-final-project/issues/3), [#4](https://github.com/nexuma/tower-defence-final-project/issues/4), [#5](https://github.com/nexuma/tower-defence-final-project/issues/5), [#6](https://github.com/nexuma/tower-defence-final-project/issues/6)                                                                    | To decide from evidence |
| Late February–early March 2027 | Complete ethics approval before any participant evaluation, if human participants or personal data are involved.                                                     | [#25](https://github.com/nexuma/tower-defence-final-project/issues/25)                                                                                                                                                                                                                                                                                                                                                                | Conditional             |
| Week beginning 15 March 2027    | Prepare and deliver the 10–15 minute project presentation.                                                                                                          | [#27](https://github.com/nexuma/tower-defence-final-project/issues/27)                                                                                                                                                                                                                                                                                                                                                                | Deadline                |
| 26 March 2027                   | Submit the final dissertation PDF and source-code ZIP by 17:00.                                                                                                      | [#28](https://github.com/nexuma/tower-defence-final-project/issues/28)                                                                                                                                                                                                                                                                                                                                                                | Deadline                |

## Recurring weekly work

These activities continue throughout the project and should not be treated as
one-time tasks:

- Prepare progress updates, questions, and the weekly plan by Monday at 14:00.
- Attend the Tuesday supervisor meeting.
- Review and upload the meeting minutes.
- Record time in [timelog.md](timelog.md).
- Update the relevant GitHub Issue status.
- Record important changes in the [decision log](docs/roadmap/decision-log.md).
- Back up or version project evidence appropriately.

References: [#23](https://github.com/nexuma/tower-defence-final-project/issues/23)
and [#24](https://github.com/nexuma/tower-defence-final-project/issues/24).

## Scope control

The implementation order should remain:

```text
Requirements and evidence
  -> architecture and compatibility
  -> minimal game host
  -> dynamic runtime experiment
  -> technical evaluation
  -> one focused application
  -> dissertation and presentation
```

The following are candidate extensions rather than simultaneous commitments:

- genetic-algorithm tower generation;
- recommender settings;
- dynamic telemetry collection;
- multi-user scoreboards;
- tower sharing or trading;
- cryptographic uniqueness or provenance; and
- A/B-style configuration experiments.

If one of these becomes the selected application, record the decision and
update the relevant GitHub Issues before expanding the implementation scope.

## Review points

Review this plan:

- after each supervisor meeting;
- when a prototype or experiment produces new evidence;
- before starting a new major feature;
- before the status report; and
- after selecting the final dissertation evaluation.
