import 'package:flutter/material.dart';
// import 'screens/game_screen.dart';
import 'package:flame/game.dart';
import 'src/my_game.dart';
import 'src/game/game_menu_drawer.dart';

void main() {
  runApp(const MaterialApp(home: GameScreen()));
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GameScreenState();
  }
}

class _GameScreenState extends State<GameScreen> {
  late final MyGame game;

  @override
  void initState() {
    super.initState();
    game = MyGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ハンバーガーメニューボタンを自動的に表示
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // ハンバーガーメニュー
      drawer: GameMenuDrawer(game: game),
      // ゲーム本体
      body: GameWidget(game: game),
    );
  }
}
