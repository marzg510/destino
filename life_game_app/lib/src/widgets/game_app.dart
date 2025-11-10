import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../my_game.dart';
import 'game_menu_drawer.dart';
import 'arrival_counter_card.dart';

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final MyGame game;

  @override
  void initState() {
    super.initState();
    game = MyGame();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // ハンバーガーメニューボタンを自動的に表示
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        // ハンバーガーメニュー
        drawer: GameMenuDrawer(game: game),
        // ゲーム本体
        body: Stack(
          children: [
            GameWidget(game: game),
            // 到達回数をオーバーレイ表示（ゲーム中のみ）
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: ArrivalCounterCard(arrivalCount: game.arrivalCount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
