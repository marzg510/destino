import 'package:flutter/material.dart';
import 'package:life_game_app/src/my_game.dart';
import '../config.dart';

class GameMenuDrawer extends StatelessWidget {
  final MyGame game;

  const GameMenuDrawer({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ドロワーのヘッダー
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  Config.gameTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Menu',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          // メニュー項目
          ListTile(
            leading: Icon(Icons.home),
            title: Text('ゲームリセット'),
            onTap: () {
              game.resetGame();
              Navigator.of(context).pop(); // メニューを閉じる
            },
          ),
        ],
      ),
    );
  }
}
