import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_game_app/src/my_game.dart';
import 'package:life_game_app/src/config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GarbageManager', () {
    testWithGame<MyGame>('onLoadで初期ゴミが生成される', () => MyGame(), (game) async {
      await game.ready();
      game.startGame();
      await game.ready();

      final garbageCount = game.garbageManager.getAllGarbages().length;
      expect(garbageCount, Config.targetGarbageCount);
    });

    testWithGame<MyGame>('getAllGarbagesが正しいリストを返す', () => MyGame(), (
      game,
    ) async {
      await game.ready();
      game.startGame();
      await game.ready();

      final garbages = game.garbageManager.getAllGarbages();
      expect(garbages, isNotEmpty);
      expect(garbages.length, lessThanOrEqualTo(Config.targetGarbageCount));
    });

    testWithGame<MyGame>('clearメソッドで全ゴミが削除される', () => MyGame(), (game) async {
      await game.ready();
      game.startGame();
      await game.ready();

      game.garbageManager.clear();
      await game.ready();

      final garbageCount = game.garbageManager.getAllGarbages().length;
      expect(garbageCount, 0);
    });

    testWithGame<MyGame>('removeGarbageでゴミが削除される', () => MyGame(), (
      game,
    ) async {
      await game.ready();
      game.startGame();
      await game.ready();

      final garbagesBefore = game.garbageManager.getAllGarbages();
      if (garbagesBefore.isNotEmpty) {
        final targetGarbage = garbagesBefore.first;
        final countBefore = garbagesBefore.length;

        game.garbageManager.removeGarbage(targetGarbage);
        await game.ready();

        final countAfter = game.garbageManager.getAllGarbages().length;
        expect(countAfter, lessThan(countBefore));
      }
    });

    testWithGame<MyGame>('ゴミが十分に離れて生成される', () => MyGame(), (
      game,
    ) async {
      await game.ready();
      game.startGame();
      await game.ready();

      final garbages = game.garbageManager.getAllGarbages();

      // グリッドベースで管理しているため、同じグリッドに複数配置されない
      // ここでは物理的な距離が異常に近くないことをチェック
      for (int i = 0; i < garbages.length; i++) {
        for (int j = i + 1; j < garbages.length; j++) {
          final distance = garbages[i].position.distanceTo(garbages[j].position);
          expect(
            distance,
            greaterThan(0),
            reason: 'ゴミが完全に重複しています',
          );
        }
      }
    });
  });
}
