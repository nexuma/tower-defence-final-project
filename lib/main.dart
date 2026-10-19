import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/tower_defence_game.dart';

void main() {
  runApp(const TowerDefenceApp());
}

class TowerDefenceApp extends StatelessWidget {
  const TowerDefenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tower Defence Sandbox POC',
      theme: ThemeData.dark(),
      home: GameWidget(game: TowerDefenceGame()),
    );
  }
}
