# Project Plan

## AI-use disclaimer

This file was generated and structured with the assistance of artificial intelligence. The underlying project sources, including the GitHub Issues and the [Project Decision
Log](decision-log.md), were created and maintained separately from this generated plan. AI was used as a convenience tool to organise information from those sources into a readable project schedule; it was not
used as a substitute for the underlying decisions, evidence, or task records. The GitHub Issues, decision log, meeting records, and technical experiments remain the authoritative sources.

## Purpose

This is the high-level plan for the Level 4 individual project. It records the intended sequence of work without replacing the detailed GitHub Issues, the project roadmap, or the decision log.

## How this plan is maintained

- **GitHub Issues** record individual tasks, acceptance criteria, and
  completion status.
- The [project board](https://github.com/nexuma/tower-defence-final-project)
  records the current workflow status.
- The [Project Direction and Exploration Roadmap](project-direction.md)
  records possible research directions and scope decisions.
- The [Project Decision Log](decision-log.md) records important
  decisions and their reasoning.
- The [Game Architecture](architecture.md) records the game structure and
  architecture decisions.
- The [Project Time Log](timelog.md) records actual hours spent.
- This file records the planned sequence, milestones, and broad weekly focus.

The plan should be updated when new evidence changes the order or scope of
work. Do not treat an uncompleted plan item as a failure if the direction was
deliberately changed and the decision was recorded.

## Current project direction

The research direction, the options considered and the decision gates are in
the [Project Direction and Exploration Roadmap](project-direction.md).

## Game architecture

The game structure, architecture decisions (AD-1 to AD-5), and open
architecture questions are documented in [architecture.md](architecture.md).

## Week-by-week plan

| Period                          | Planned focus                                                                                                                                                        | Main references                                                                                                                                                                                                                                                                                                                                                                                                                      | Status                  |
| ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------- |
| Before implementation           | Establish the requirements baseline, project direction, decision log, time log, and reference-management workflow.                                                   | [#18](https://github.com/nexuma/tower-defence-final-project/issues/18), [#24](https://github.com/nexuma/tower-defence-final-project/issues/24), [#26](https://github.com/nexuma/tower-defence-final-project/issues/26)                                                                                                                                                                                                                  | In progress             |
| 2–8 November 2026              | Review and clean up meeting minutes, backfill the time log, and confirm the current architecture and prototype evidence.                                             | [#29](https://github.com/nexuma/tower-defence-final-project/issues/29), [#30](https://github.com/nexuma/tower-defence-final-project/issues/30), [#19](https://github.com/nexuma/tower-defence-final-project/issues/19), [#21](https://github.com/nexuma/tower-defence-final-project/issues/21)                                                                                                                                           | Planned                 |
| November 2026                   | Replace the default Flutter application with the minimal game host and establish the Flame, game-state, board, and component foundations.                            | [#7](https://github.com/nexuma/tower-defence-final-project/issues/7), [#8](https://github.com/nexuma/tower-defence-final-project/issues/8), [#10](https://github.com/nexuma/tower-defence-final-project/issues/10), [#11](https://github.com/nexuma/tower-defence-final-project/issues/11), [#12](https://github.com/nexuma/tower-defence-final-project/issues/12), [#13](https://github.com/nexuma/tower-defence-final-project/issues/13) | Planned                 |
| November–early December 2026   | Prepare the status report, define the testing approach, and implement or adapt the core tower-placement and dynamic-damage experiments.                              | [#20](https://github.com/nexuma/tower-defence-final-project/issues/20), [#1](https://github.com/nexuma/tower-defence-final-project/issues/1), [#2](https://github.com/nexuma/tower-defence-final-project/issues/2), [#22](https://github.com/nexuma/tower-defence-final-project/issues/22)                                                                                                                                               | Planned                 |
| 15 December 2026                | Submit the Semester 1 status report by 17:00 through Moodle and email it to the supervisor.                                                                          | [#22](https://github.com/nexuma/tower-defence-final-project/issues/22)                                                                                                                                                                                                                                                                                                                                                                | Deadline                |
| December 2026–January 2027     | Consolidate the core implementation, testing evidence, telemetry structure, and technical measurements.                                                              | [#2](https://github.com/nexuma/tower-defence-final-project/issues/2), [#4](https://github.com/nexuma/tower-defence-final-project/issues/4), [#15](https://github.com/nexuma/tower-defence-final-project/issues/15), [#16](https://github.com/nexuma/tower-defence-final-project/issues/16)                                                                                                                                               | Planned                 |
| January–February 2027          | Select and evaluate one focused application of the runtime architecture, such as recommendations, configuration search, dynamic telemetry, or multi-user comparison. | [Project Direction and Exploration Roadmap](project-direction.md), [#3](https://github.com/nexuma/tower-defence-final-project/issues/3), [#4](https://github.com/nexuma/tower-defence-final-project/issues/4), [#5](https://github.com/nexuma/tower-defence-final-project/issues/5), [#6](https://github.com/nexuma/tower-defence-final-project/issues/6)                                                                    | To decide from evidence |
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
- Record important changes in the [decision log](decision-log.md).
- Back up or version project evidence appropriately.

References: [#23](https://github.com/nexuma/tower-defence-final-project/issues/23)
and [#24](https://github.com/nexuma/tower-defence-final-project/issues/24).

## Phases

### Near term: establish evidence

- freeze the functional-requirement baseline;
- document the architecture and dynamic boundary;
- reproduce a dynamic damage calculation in the new code with a focused
  automated test;
- make the dynamic rule replaceable without restarting the application;
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

### Candidate extensions

Candidate extensions (genetic algorithms, recommender settings, multi-user
comparison and others) are described in the
[Project Direction and Exploration Roadmap](project-direction.md). They are
not simultaneous commitments: if one becomes the selected application, record
the decision and update the relevant GitHub Issues before expanding the scope.

## Review points

Review this plan:

- after each supervisor meeting;
- when a prototype or experiment produces new evidence;
- before starting a new major feature;
- before the status report; and
- after selecting the final dissertation evaluation.
