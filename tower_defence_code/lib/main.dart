import 'package:flutter/material.dart';

void main() {
  runApp(const TowerDefenceApp());
}

class TowerDefenceApp extends StatelessWidget {
  const TowerDefenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home:Scaffold(body:Center(child: Text('Tower Defence'))),
    );
  }
}
