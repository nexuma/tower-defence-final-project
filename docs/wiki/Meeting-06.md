# Achieved in Previous Week

*Previous week: 27 October–3 November 2026*

- Updated the supervisor on the current state of the project repository, its documentation, and its planning artefacts.

- Continued refining the user stories and the possible direction of the project.

# Issues Discussed & Solutions Agreed

- **Repository and submission:** The repository structure and current project work were discussed. The final submission is expected to include a source-code ZIP, with the exact submission and repository-access requirements to be confirmed from the module guidance.

- **User stories:** The current user stories were reviewed as the basis for the game, research direction, and future implementation work.

- **Social aspect:** The previously implied multi-user and social dimension of the project was discussed explicitly. This includes learning from other users’ towers, modules, configurations, and outcomes rather than necessarily making the game a direct player-versus-player game. Continuing with this social aspect was formally approved as part of the project direction.

- **Sources of shared content:** The discussion identified open questions about where modules or towers originate and how users can discover which options may be useful for them. Possible future mechanisms include shared modules, comparisons of successful configurations, and recommendations.

- **Sandbox communication frequency:** The next technical investigation is to determine when the `dart_eval` sandbox should receive information from the game. Options include once per game loop, once whenever an enemy is present, once per relevant combat event, or only when an enemy enters a tower’s range.

- **Sandbox input scope:** The experiment should compare passing information about one enemy, all enemies within a tower’s range, or all enemies currently in the game. The choice should balance the information required by the dynamic logic against performance and implementation feasibility.

- **Evaluation value:** Measuring the communication frequency and input scope can provide evidence for the dissertation, including a comparison of the technical cost and practicality of alternative designs.

# Objectives for This Week

*Upcoming week: 3–10 November 2026*

- Create an initial experiment for passing combat information from the Flame game to the `dart_eval` sandbox.

- Compare candidate invocation frequencies, including per-game-loop, per-event, and range-triggered execution.

- Compare candidate input scopes, including individual enemies, enemies within range, and all active enemies.

- Record measurable observations about feasibility, execution cost, and the information available to the dynamic damage calculation.

# AI-use Disclaimer

The meeting content and source notes for these minutes are genuine. Artificial intelligence was used only to organise and summarise the notes and transcript into a more digestible format; it was not used to invent the meeting content or decisions.
