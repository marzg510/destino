import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/my_game.dart';
import '../widgets/game_menu_drawer.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ハンバーガーメニューボタンを自動的に表示
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // ハンバーガーメニュー（Drawer）
      drawer: const GameMenuDrawer(),
      // ゲーム本体
      body: GameWidget(game: MyGame()),
    );
  }
}
