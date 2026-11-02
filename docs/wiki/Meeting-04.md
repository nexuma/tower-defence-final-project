# Achieved in Previous Week

*Previous week: 13–20 October 2026*

- Defined the game parameters that could be modified dynamically and separated them from functionality that should remain native and static.

- Considered how the dynamic execution model could be relevant beyond the game itself.

# Issues Discussed & Solutions Agreed

- **Dynamic parameters:** Candidate values include tower damage, range, cooldown, targeting, enemy health, armour and behaviour, wave composition, gold rewards, incubator rules, and temporary balancing events.

- **Native parameters:** Flame rendering, lifecycle, input, collision detection, storage, permissions, and the validation bridge should remain native.

- **Execution flow:** The Flame loop passes combat state to a `CombatState` bridge, which sends data to `dart_eval`. The sandbox runs `calculateDamage()`, returns the result, and Flame validates and applies the damage.

- **Industry benchmarks:** Relevant examples include the dynamic compiler used by the PS2 version of Crash Bandicoot, DLL hot reloading, binary patching, and scripting VMs in games such as Skyrim and Roblox.

- **Broader relevance:** The project can be framed around dynamic loading in backend systems, plugin ecosystems, browser extensions, and recommender systems, rather than games alone.

- **Recommendation concept:** Telemetry recommendations could dynamically load UI widgets or features that help players discover effective configurations.

# Objectives for This Week

*Upcoming week: 20–27 October 2026*

- Conduct a background survey of dynamic loading use cases.

- Design the initial game structure and telemetry recommendation framework.

# AI-use Disclaimer

The meeting content and source notes for these minutes are genuine. Artificial intelligence was used only to organise and summarise the notes into a more digestible format; it was not used to invent the meeting content.
