# Achieved in Previous Week

*Previous week: 6–13 October 2026*

- Re-evaluated the constraints affecting dynamic code loading in production.

- Investigated the distinction between over-the-air patching and true runtime code loading.

# Issues Discussed & Solutions Agreed

- **Shorebird limitation:** Shorebird can deliver code patches over the air, but the application must restart. It does not load new code dynamically inside an active game session.

- **True dynamic loading:** Runtime scripting through Lua or JavaScript, or the `dart_eval` Dart bytecode interpreter, is required for code to execute dynamically during a session.

- **`dart_eval` architecture:** `dart_eval` is sandboxed. An internal bridge is required to pass Flame game state into the sandbox, calculate values such as combat damage, and return validated results to Flame.

- **Research scope:** The project should compare plugin architectures with runtime dynamic code loading approaches used in commercial games.

# Objectives for This Week

*Upcoming week: 13–20 October 2026*

- Test communication between the Flame Engine and the `dart_eval` sandbox.

- Research memory optimisation and dynamic loading practices in commercial game development.

# AI-use Disclaimer

The meeting content and source notes for these minutes are genuine. Artificial intelligence was used only to organise and summarise the notes into a more digestible format; it was not used to invent the meeting content.
