import 'package:flutter/material.dart';
import '../constants/game_constants.dart';

class GameMenuDrawer extends StatelessWidget {
  const GameMenuDrawer({super.key});

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
                  GameConstants.gameTitle,
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
          // メニュー項目はここに追加してください
          // 例:
          // ListTile(
          //   leading: Icon(Icons.home),
          //   title: Text('タイトルに戻る'),
          //   onTap: () {
          //     // 処理を追加
          //   },
          // ),
        ],
      ),
    );
  }
}
