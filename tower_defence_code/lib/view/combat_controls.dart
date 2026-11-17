/// What the view may do with combat scripts.
///
/// These are plain functions filled in by `main.dart`, so the view can switch
/// scripts and show which one is running without importing `combat_logic/`
/// (AD-12).
class CombatControls {
  const CombatControls({
    required this.scriptNames,
    required this.load,
    required this.status,
  });

  /// The scripts that can be loaded, in the order the button cycles through.
  final List<String> scriptNames;

  /// Loads, compiles and swaps in the script called [name].
  final Future<void> Function(String name) load;

  /// A short description of the combat logic in use, for the HUD.
  final String Function() status;
}
