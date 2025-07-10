import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: GameWidget<LifeGame>.controlled(
        gameFactory: LifeGame.new,
      ),
    );
  }
}
