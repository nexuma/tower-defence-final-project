## What can be changed dynamically?
- tower damage;
- firing range;
- firing cooldown;
- targeting priorities;
- enemy movement;
- enemy attack behaviour;
- enemy health and armour;
- wave composition;
- spawn timing;
- tower upgrade rules;
- gold rewards;
- incubator/genetic algorithms;
- temporary events;
- balancing experiments;
- new data-driven monster types.
## What remains native?
- Flame rendering;
- the main game lifecycle;
- input handling;
- collision infrastructure;
- save data;
- networking;
- module verification;
- permissions;
- platform integration;
- the bridge and validation layer.

Flame game loop
    ↓
Create CombatState
    ↓
Pass tower/enemy values to dart_eval
    ↓
dart_eval runs calculateDamage()
    ↓
Return damage value
    ↓
Validate the result
    ↓
Flame applies damage to the enemy

# How far do games go
- Playstation 2 crash bandicoot, would reprogram a full compiler that can dynamically compile certain parts of the game (circumvents the small memory but requires exactly the same hardware because coupling is very high)
- DLL hot reloading, challenge is persistent memory.
- Binary Patching highly integrated with system and compiler, only used for testing
- Game engine might ship with a VM or use a plugin architecture with a scripting language
- Games with big modding communities often have a specialised solution (skyrim, roblox)
- 