## Progress since last meeting
- rebuilt the game from scratch on master (prototype is archived)
- model, engine and view are separate; Flame only draws and passes input
- tower placement with the 5 tower limit (FR-M1)
- combat logic runs from a dart_eval script, with the native version as fallback (FR-M2)
- scripts can be swapped while the game runs, no restart
- score and game events (FR-S1)
- ~80 tests, CI runs on every push
- decisions AD-1 to AD-19 in the decision log

## Demo
- place towers, start a wave
- press "Next script": towers switch from first enemy to strongest enemy
- HUD shows which logic is running

## Known limitations
- dart_eval has no timeout, an endless loop in a script freezes the game
- compiling runs on the main thread, a big script can stutter
- scripts are bundled as assets for now, downloading comes later

## Possible directions
- A: technical cost, i.e. call frequency, input scope and data format (follows meeting 6)
- B: safety, i.e. how to stop loaded logic from breaking a running game
- C: shared content, i.e. players using towers/modules from other players (social aspect)
- D: live balancing, i.e. changing rules for running games without a new release

## Questions
1. Which direction should be the main research question?
2. Technical measurements, a user study, or both?
3. Interview developers, players, or both?

# Notes
- Research of genetic algs in existing in games, borrow from that ? Skylander, game of life, mutating game evolving world create species etc.
- Who will be my most common participants and gameplayer, do they like the way it goes? (research or creating their own towers) what design would be most attractive?
- Maybe do A and B, can do that at anypoint, concentrate on D,C
- Get ethic checklist and get participants to sign it?
- 