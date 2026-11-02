# Achieved in Previous Week

*Previous week: 22–29 September 2026*

- Investigated Flutter and Dart compilation modes, Hot Reload security, VM protocols, and equivalent dynamic capabilities in other languages and hardware.

- Documented the technical actions, constraints, and justifications relevant to dynamic code execution in the proposed project.

# Issues Discussed & Solutions Agreed

- **Flutter Hot Reload and debugging:** Hot Reload injects updated source code into a running Dart VM in Debug mode without losing application state. It is limited to debug builds and cannot modify `main()` or native code.

- **Production code updates:** Shorebird was explored as a tool for remotely patching Dart logic in release mode using production over-the-air updates.

- **Deferred components:** Flutter’s `deferred as` mechanism and Android Dynamic Feature Modules can split compiled binaries and reduce initial memory usage.

- **Server-driven UI:** The `rfw` package can render declarative UI dynamically from binary `.rfw` or text `.rfwtxt` definitions sent by a server.

- **Modular game architecture:** Flame was identified for the game loop, with modular asset loading and possible embedded scripting through `lua_dardo` or `flutter_js`.

- **JIT and AOT constraints:** JIT is used in Debug mode and supports dynamic execution at a memory and performance cost. AOT is used in Release mode and produces statically compiled native code without the JIT compiler.

- **Academic bypasses:** Potential approaches included retaining JIT in Debug or Profile mode with `vm_service`, loading dynamic native libraries through `dart:ffi`, and forking the Flutter C++ engine to re-enable `Isolate.spawnUri()`.

# Objectives for This Week

*Upcoming week: 29 September–6 October 2026*

- Interview users regarding potential game directions and use cases.

- Explore the capabilities and constraints of the Flame Engine.

# AI-use Disclaimer

The meeting content and source notes for these minutes are genuine. Artificial intelligence was used only to organise and summarise the notes into a more digestible format; it was not used to invent the meeting content.
