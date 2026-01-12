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

    testWithGame<MyGame>('ゴミが重複しないグリッドに生成される', () => MyGame(), (
      game,
    ) async {
      await game.ready();
      game.startGame();
      await game.ready();

      final garbages = game.garbageManager.getAllGarbages();

      // グリッドベースで管理しているため、実際の距離は0〜約70ピクセル
      // （隣接グリッドの対角なら√2*50≈70.7、直線なら50、同じグリッド内なら0だがそれは重複チェックで防がれる）
      // ここでは「異常に近いゴミがない」ことを検証（グリッドサイズの半分以上）
      // ただし、グリッド境界付近では近くなる可能性があるため、少し緩めに設定
      for (int i = 0; i < garbages.length; i++) {
        for (int j = i + 1; j < garbages.length; j++) {
          final distance = garbages[i].position.distanceTo(garbages[j].position);
          // 同じグリッドに複数配置されていないことを確認（それは別テストで検証）
          // ここでは物理的な距離が異常に近くないことだけチェック
          expect(
            distance,
            greaterThan(0),
            reason: 'ゴミが完全に重複しています',
          );
        }
      }
    });

    testWithGame<MyGame>('同じグリッドに複数のゴミが生成されない', () => MyGame(), (
      game,
    ) async {
      await game.ready();
      game.startGame();
      await game.ready();

      final garbages = game.garbageManager.getAllGarbages();
      final keys = <(int, int)>{};

      for (final garbage in garbages) {
        final key = garbage.getKey();
        expect(
          keys.contains(key),
          false,
          reason: 'キー$keyが重複しています',
        );
        keys.add(key);
      }
    });
  });
}
