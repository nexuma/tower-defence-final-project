# Project Direction and Exploration Roadmap

Last reviewed: 2 November 2026

## AI-use disclaimer

This document was generated and structured with the assistance of artificial intelligence. It summarises ideas discussed in supervisor meetings and other project discussions and thoughts I had. AI was used to organise and present those ideas in a structured form, not to replace the underlying project decisions or evidence. Its value is primarily practical: it provides a single place to keep track of possible directions, questions,
alternatives. As new ideas occur, they may be added with AI assistance so that they are not forgotten and can be reviewed in an organised way. The meeting minutes, technical experiments, research sources, and confirmed decisions remain the authoritative evidence for the project.

## Purpose

This document records the direction of the project while it is still being
explored. It separates:

- ideas that were considered
- questions that still need evidence
- possible dissertation conclusions
- work that is deliberately outside the current minimum viable product.

It is not a promise that every possible extension will be
implemented. The supervisor meeting minutes remain the chronological record of what was discussed. This document consolidates those discussions into a
roadmap that can be updated as technical evidence is collected.

## Starting point: Flutter Hot Reload

The original idea was to investigate Flutter Hot Reload as a way to load new
game logic dynamically. This was a useful starting point because Hot Reload
demonstrates code replacement while a Dart application is running.

The investigation identified an important limitation:

- Hot Reload depends on the Dart VM and is intended for Debug development;
- it is not a production mechanism for loading arbitrary code into a release
  application this is not a problem for a research project bu the main problem is that it would only work on 1 device so it would be suitable for multiple people using the app.

This changed the research direction slightly. Hot Reload is dropped in favour of other methods

## Options considered

### Option A: Flutter Hot Reload or retained JIT

**Idea:** Keep the application in a VM/JIT-oriented mode and use Hot Reload or
related VM services to change logic while the game is running.

**Why it was attractive:**

- quick feedback during development
- state can often be preserved

**Why it is not the current direction:**

- it is restricted to development-oriented execution mode
- it would not be possible to have other users test the application

**Current decision:** Use only as background context and a baseline comparison.

### Option B: Shorebird or other over-the-air patching

**Idea:** Deliver updated Dart logic after release through an over-the-air
patching system.

**What it demonstrates:** Remote delivery of an application patch.

**Limitation:** A patch is not the same as loading new logic into an active
game session. It may require an application restart and therefore does not
demonstrate in-session runtime execution.

**Current decision:** Keep as a general updating during testing to make it easier for test-users,
not as the core dynamic execution experiment.

### Option C: Deferred components and dynamic feature modules

**Idea:** Split compiled application or asset modules so that selected content
can be delivered or loaded later.

**Strengths:**

- relevant to application size and staged delivery;
- can support modular assets or features;
- closer to a production deployment model than Hot Reload.

**Limitation:** Loading a compiled module is not necessarily the same as
interpreting new game logic inside an already-running session.

**Current decision:** Consider for asset or feature delivery if it supports the
game, but do not claim that it proves arbitrary runtime code execution.

### Option D: Server-driven UI or declarative configuration

**Idea:** Load data or UI definitions, such as a server-provided widget or
configuration description, rather than loading executable Dart code.

**Possible use:** Change recommendations, game parameters, or presentation
without shipping a new native application binary.

**Limitation:** Declarative configuration has a smaller capability than
arbitrary executable logic. It may be safer and easier to validate, but it
does not answer the same research question as a runtime scripting sandbox.

**Current decision:** Keep as a possible recommender implementation or for changing the UI

### Option E: Embedded scripting

**Idea:** Embed Lua, JavaScript, or another scripting runtime and execute
scripts during a game session.

**Strengths:**

- established pattern in games and plugin systems;
- clear separation between native host code and dynamic scripts;
- potentially suitable for balancing rules, enemy behaviour, or events.

**Risks:**

- introduces another language and runtime;
- requires a carefully designed host API;
- needs sandboxing, validation, error handling, and performance evaluation.

**Current decision:** The current option seems more feasible and interesting for research

### Option F: `dart_eval` runtime execution

**Idea:** Keep the Flame game loop and safety-critical host responsibilities
in native Dart, then pass a constrained combat-state representation to a
`dart_eval` sandbox. The sandbox executes selected game logic and returns a
validated result.

**Proposed boundary:**

```text
Flame game loop
  -> serialised CombatState
  -> dart_eval sandbox
  -> calculated result
  -> validation bridge
  -> Flame applies the result
```

**Potential dynamic logic:**

- damage calculations;
- tower range, cooldown, or targeting rules;
- enemy health, armour, or behaviour;
- wave composition;
- reward values;
- incubator or tower-combination rules;
- temporary balancing events.

**Logic that should remain native:**

- rendering and the Flame lifecycle;
- input handling;
- collision and spatial coordination where required;
- storage and permissions;
- the bridge, schema validation, and failure handling;
- limits on execution time and resource use.

**Current decision:** This is the leading implementation direction because it
directly tests the project's central requirement: executing replaceable logic
without restarting the application or producing a new AOT compilation.

## What the game is intended to demonstrate

The game should be treated as an experimental demonstrator, not as the whole
research contribution. Its purpose is to provide a concrete, observable host
environment in which dynamic logic can be loaded, executed, constrained, and
evaluated.

The current working thesis is:

> A small Flutter and Flame game can provide a practical testbed for evaluating
> sandboxed runtime logic loading, including its integration boundary,
> limitations, and possible uses for telemetry-informed adaptation.

This does **not** yet commit the project to building a complete recommender
system, a production A/B-testing platform, or a commercial game.

## Existing prototype evidence

The project already contains a separate [`prototype` branch](https://github.com/nexuma/tower-defence-final-project/tree/prototype)
with commit `26ae1e1` demonstrating a first Flame-to-`dart_eval` integration.
This is important evidence: the central idea is no longer only a planned
experiment.

The prototype currently:

- runs a Flame-based game prototype;
- loads a Dart damage script as an asset;
- represents the relevant combat inputs in a `CombatState`;
- passes tower position, enemy position, and enemy health into the
  `dart_eval` sandbox;
- executes `calculateDamage()` dynamically; and
- returns the damage amount so the game can apply a life hit.

The current dynamic rule is deliberately small: it checks whether the enemy
is alive and within range, then returns a fixed damage value. This proves the
basic host/sandbox call path, but it does not yet prove the complete
production-ready architecture or the usefulness of dynamic logic for
recommendations and experimentation.

The prototype changes the next question from:

> Can Flame communicate with `dart_eval` at all?

to:

> What is the smallest reliable and measurable architecture that makes this
> communication useful, safe, and relevant to the dissertation?

### What the prototype proves

- Flame and `dart_eval` can coexist in the project technology stack.
- A selected combat state can cross an explicit bridge.
- A dynamically evaluated function can calculate damage during gameplay.
- The result can be returned to the native game side and used to reduce enemy
  life.

### What remains to be demonstrated

- replacement of the script or rule without restarting the application;
- a stable and versionable state schema;
- validation of dynamic results before they affect the game;
- controlled behaviour for invalid, missing, or slow scripts;
- comparison with an equivalent statically compiled rule;
- measurements of latency, memory, and reliability;
- more than one meaningful dynamic rule, if this is justified by scope; and
- a clear relationship between runtime logic, telemetry, and any
  recommendation or configuration experiment.

## Potential research and dissertation directions

The following are legitimate directions that can be explored. They are
alternatives and layers of scope, not requirements that must all be completed.

### Direction 1: Feasibility and architecture of runtime dynamic loading

**Core question:** Can `dart_eval` execute selected game logic during an active
Flame session without an application restart or new AOT compilation?

**Evidence:**

- a working Flame-to-`dart_eval` bridge;
- a defined state schema;
- replaceable logic executed during a session;
- validation and fallback behaviour;
- measurements of latency, memory, and failure cases.

**Possible conclusion:** The approach is technically feasible for a bounded
class of game rules, but the boundary must remain narrow and explicitly
validated.

### Direction 2: Runtime loading as a game-balancing mechanism

**Core question:** Can balancing rules be changed dynamically without
rebuilding the host application?

**Examples:**

- tower damage or cooldown;
- enemy health or armour;
- wave composition;
- gold rewards;
- temporary events.

**Possible conclusion:** Runtime logic can reduce the cost of experimenting
with balancing changes, subject to execution overhead, safety restrictions,
and the need to preserve a stable host API.

### Direction 3: Telemetry-informed recommendations

**Core question:** Can locally collected player events be transformed into a
useful recommendation without requiring a fully trained machine-learning
system?

**Possible progression:**

1. record structured events such as tower placements, victories, and module
   selections;
2. calculate simple frequencies or rule-based recommendations;
3. load the recommendation rule or widget configuration dynamically;
4. display a recommendation to the player;
5. evaluate whether the recommendation is understandable and technically
   reliable.

**Possible conclusion:** A lightweight telemetry pipeline can support
rule-based recommendations, but demonstrating recommendation usefulness would
require a larger dataset and evaluation than the 20-credit scope may allow.

### Direction 4: Dynamic A/B testing or configuration experiments

**Core question:** Can runtime logic support controlled variations of game
rules without shipping a new application binary?

**Examples:**

- compare two tower cooldown values;
- compare two recommendation strategies;
- compare different wave compositions;
- assign players to rule variants and log outcomes.

**Possible conclusion:** The architecture may support small-scale,
configuration-driven experiments, but a statistically valid large-scale A/B
test is outside this project's likely scope. The dissertation could instead
present a technical proof of variant assignment and event logging.

### Direction 5: Plugin or module architecture

**Core question:** Is a sandboxed runtime module a useful alternative to
hard-coding every game rule into the host application?

**Comparison dimensions:**

- deployment flexibility;
- safety and trust boundary;
- performance;
- memory usage;
- debugging difficulty;
- version compatibility;
- failure recovery;
- ease of testing.

**Possible conclusion:** A plugin-style boundary can improve replaceability,
but it adds schema, validation, versioning, and debugging costs.

### Direction 6: Adaptive content and player discovery

**Core question:** Can telemetry be used to adapt what the player sees or
discovers, rather than only changing combat arithmetic?

**Examples:**

- recommend an underused tower;
- reveal a module or widget based on prior choices;
- show contextual guidance after a failed wave;
- load a temporary event or challenge.

**Possible conclusion:** Dynamic loading can support adaptive content, but the
project should distinguish technical adaptability from evidence that the
adaptation improves player experience.

### Direction 7: Multi-user interaction and social comparison

**Core question:** How can dynamic loading support interactions between
multiple users, and how can information from those interactions be used to
adapt the experience?

The social aspect does not require the project to become a full online game.
It can be represented by several users producing separate game sessions,
sharing selected results, and comparing strategies. The important research
question is how a dynamic runtime can use changing shared or user-specific
logic more efficiently than rebuilding and redistributing the entire
application.

**Possible social features:**

- a scoreboard comparing victories, scores, survival time, or other outcomes;
- comparison of tower combinations used by higher-performing players;
- sharing or trading unique towers between users;
- cryptographic signatures or provenance records to support claims that a
  tower is unique or has not been altered;
- user-specific rules or recommendations based on previous performance;
- dynamically loaded events, challenges, or ranking calculations; and
- anonymised aggregate telemetry showing which strategies are successful.

**Potential interaction model:**

```text
User sessions
  -> signed or validated tower/configuration records
  -> shared result and telemetry store
  -> comparison or recommendation policy
  -> user-specific dynamic behaviour
```

**Possible recommendation signal:** In the game, recommendations could be
based on victories, score, survival time, tower combinations, or success
against particular enemy waves. In a wider application, the signal could be
any measurable outcome, such as task completion, resource efficiency, user
preference, reliability, or accessibility.

**Important distinction:** A scoreboard can show that users achieved
different outcomes, but it does not by itself explain why one user performed
better. To investigate that, the system would need structured, privacy-aware
records of configurations, actions, outcomes, and relevant context.

**Possible conclusion:** Dynamic loading may support user-specific policies,
shared comparison logic, and evolving recommendations without changing the
whole application. However, multi-user networking, secure identity, trading,
cryptographic provenance, and statistically valid social evaluation could
quickly exceed the 20-credit scope.

### Direction 8: Genetic algorithms for configuration search

**Core question:** Can the incubator use a genetic algorithm to generate or
select new tower configurations, and can the same approach be understood as a
general optimisation mechanism rather than only a game mechanic?

In the game, a tower can be represented as a small genome. Genes might encode
attributes such as damage, range, cooldown, targeting behaviour, cost, or
special effects. The incubator can combine two parent towers through
crossover, apply mutation, and produce a candidate child tower. A fitness
function can then score candidates using criteria such as survival, damage
output, resource efficiency, victories, score, or player-selected
preferences.

**Potential game use:**

1. represent tower attributes as a genome;
2. select two existing towers as parents;
3. crossover and mutate their attributes;
4. validate the resulting tower against balance limits;
5. use the tower in a wave or simulated scenario;
6. record its performance and player adoption as telemetry.

**Broader applications:**

- recommender systems that generate or rank item combinations;
- configuration optimisation for software, networks, cloud services, or build
  pipelines;
- scheduling, delivery routes, task allocations, or resource assignments;
- personalised interfaces, content bundles, or difficulty settings;
- engineering design with competing constraints; and
- candidate variants for controlled experiments.

**Important limitation:** A genetic algorithm does not automatically produce
good recommendations. It needs a meaningful fitness function, sensible
constraints, sufficient evaluations, and a way to avoid converging on
uninteresting or unfair solutions.

**Possible conclusion:** A genetic algorithm can provide a useful generator
or search component for adaptive systems, but its value depends on how fitness
is defined and how generated results are validated and presented to users.

### Direction 9: Recommender settings and adaptive configuration

**Core question:** Can telemetry and generated configurations be used to
recommend settings or content while keeping the recommendation logic
replaceable?

The recommender does not need to begin as machine learning. A staged approach
could use:

- frequency-based recommendations;
- rule-based recommendations;
- a genetic algorithm to generate candidate configurations;
- a ranking function to select candidates; and
- a dynamically loaded recommendation policy.

In the game, the recommendation signal might be victories, score, survival
time, tower combinations, or performance against particular waves. In another
application, the signal could be task completion, resource efficiency, user
preferences, reliability, or accessibility outcomes.

**Possible conclusion:** Runtime-loaded recommendation policies can separate
the application shell from changing recommendation behaviour, but the project
must distinguish technical recommendation delivery from proving that
recommendations improve user outcomes.

### Direction 10: Dynamic loading as a telemetry collection mechanism

**Core question:** Can telemetry collection itself be added, changed, or
configured dynamically without rebuilding the host application?

Possible meanings of dynamic telemetry include:

- dynamically loading an event schema;
- enabling or disabling selected event types;
- changing sampling rates;
- adding a new measurement for an experiment;
- loading a telemetry transformation or aggregation rule; and
- choosing whether data remains local or is exported.

**Potential architecture:**

```text
Native game events
  -> stable event interface
  -> dynamically selected telemetry policy
  -> local validation and storage
  -> exportable structured records
```

**Risks and constraints:**

- telemetry must not access data outside its permitted scope;
- event schemas require versioning;
- dynamically loaded collectors must not silently lose required evidence;
- privacy and ethics requirements still apply; and
- collection overhead or sampling may bias the results.

**Possible conclusion:** Dynamic loading may be useful not only for game rules
but also for changing what the system observes. This could be evaluated as a
modular, local-first telemetry architecture.

### Direction 11: Security and trust boundaries

**Core question:** What can safely be exposed to dynamically executed logic?

**Topics:**

- restricting the bridge API;
- preventing access to storage, permissions, and native services;
- validating inputs and outputs;
- handling malformed or incompatible scripts;
- limiting execution time and resource use;
- deciding whether loaded logic is trusted, signed, or locally authored.

**Possible conclusion:** Sandboxing reduces the host surface exposed to dynamic
logic, but it does not remove the need for explicit validation and a defined
trust model.

## Current chosen direction

The project currently follows a layered direction:

1. **Build a small, playable tower-defence host** using Flutter and Flame.
2. **Demonstrate a narrow runtime-logic experiment** using `dart_eval`.
3. **Keep the host boundary stable and safe**, with serialised state,
   validation, and fallback behaviour.
4. **Capture lightweight local telemetry** about player choices and outcomes.
5. **Represent multiple users through separate sessions and shared,
   privacy-aware results** if the social direction is selected.
6. **Explore one application**, such as a rule-based recommendation,
   genetic-algorithm configuration search, dynamic telemetry, or a limited
   configuration variation, only if the core experiment is working.
7. **Evaluate technical behaviour first**, then consider limited player
   feedback or evaluation if ethics approval and time allow.

The project therefore does not need to decide today whether its final
dissertation title will emphasise recommender systems, A/B testing, or dynamic
game balancing. Those can remain candidate applications of the same
underlying runtime-loading architecture until feasibility evidence is
available.

## Decision gates

The following gates prevent the project from expanding before its central risk
is understood.

### Gate 1: Requirements and scope

**Proceed when:**

- the Must Have requirements are stable;
- the host game loop is small enough to finish;
- the dissertation question is phrased around a testable technical claim.

**Do not yet commit to:** a complete shop, monetisation, complex economy,
large-scale recommender, or statistically powered A/B experiment.

### Gate 2: Runtime feasibility and prototype validation

The basic feasibility part of this gate has already been partially passed by
the prototype. The remaining validation is:

**Proceed when:**

- a `CombatState` or equivalent schema is defined;
- the prototype path is reproduced or deliberately adapted in the main
  project;
- the application can load or select a different valid rule without a
  restart;
- dynamic logic returns a result during an active session;
- invalid logic produces a visible, controlled failure.

**If this fails:** narrow the dynamic boundary, use declarative
configuration, or compare the approach experimentally rather than expanding
gameplay.

### Gate 3: Evaluation choice

Select one primary evaluation emphasis:

- runtime feasibility and overhead;
- dynamic balancing;
- genetic-algorithm configuration search;
- telemetry-driven recommendation proof of concept;
- dynamic telemetry collection; or
- configuration/A-B variant proof of concept.

The other directions can be discussed as future work or alternative
applications rather than implemented in full.

### Gate 4: Human evaluation

Only pursue player evaluation after confirming the ethics requirements. If
participant evaluation is not approved or cannot fit the schedule, use
technical tests, scripted scenarios, and low-fidelity feedback methods
instead.

## Roadmap

### Near term: establish evidence

- freeze the functional-requirement baseline;
- document the architecture and dynamic boundary;
- review the prototype branch and record what is already proven;
- reproduce the damage calculation with a focused automated test;
- identify the smallest changes needed to make the script replaceable;
- replace the default Flutter counter application with a minimal host;
- implement a basic game state, board, towers, enemies, and waves;
- start the structured event-log design;
- record technical limitations and failed approaches as evidence.

### Middle term: demonstrate the core experiment

- implement the Flame-to-`dart_eval` bridge;
- execute one small replaceable rule, such as damage calculation;
- validate results and handle errors;
- compare static and dynamic versions of the same rule;
- measure execution time, memory where practical, and observable reliability;
- implement only the minimum telemetry needed for the selected evaluation;
- record whether the incubator is treated as a game mechanic, an optimisation
  experiment, or both.

### Later term: select and evaluate one application

Choose the strongest evidence-supported application:

- dynamic balancing;
- genetic-algorithm configuration search;
- a rule-based recommendation;
- a limited configuration experiment; or
- adaptive player-facing content;
- dynamic telemetry collection;
- multi-user comparison or strategy sharing.

Do not implement several applications merely to make the project appear
larger. A well-evaluated narrow result is more appropriate for a 20-credit
project.

### Final term: dissertation and presentation

- report the original Hot Reload hypothesis and why it was rejected as the
  production mechanism;
- explain the alternatives and decision criteria;
- describe the selected architecture and its boundaries;
- evaluate the technical result against measurable criteria;
- state clearly what was demonstrated, what was not demonstrated, and what
  would be required for a larger recommender or A/B-testing system.

## Open questions

These questions should be answered through implementation, experiments, or
supervisor discussion rather than assumed in advance:

1. What subset of Dart logic can `dart_eval` execute reliably for the chosen
   game state?
2. What is the measurable overhead of crossing the host/sandbox boundary?
3. How should incompatible, invalid, or slow dynamic logic fail?
4. Which data representation makes the bridge stable and versionable?
5. Is a rule-based recommender sufficient to demonstrate the concept?
6. Can a genetic algorithm be given a meaningful and measurable fitness
   function within the project scope?
7. How can multiple users share results or configurations without making
   networking, identity, trading, and cryptographic verification the whole
   project?
8. Is the research contribution primarily feasibility, architecture,
   performance, optimisation, adaptability, or player-facing usefulness?
9. Can dynamic telemetry collection be useful without weakening the stability
   of the evidence being collected?
10. Can human evaluation be approved and completed within the project
    schedule?
11. Which single application provides the strongest dissertation evidence
    without exceeding the 20-credit scope?
