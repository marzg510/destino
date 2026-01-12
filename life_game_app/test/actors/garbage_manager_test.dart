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

    testWithGame<MyGame>('removeGarbageAtで指定位置のゴミが削除される', () => MyGame(), (
      game,
    ) async {
      await game.ready();
      game.startGame();
      await game.ready();

      final garbages = game.garbageManager.getAllGarbages();
      if (garbages.isNotEmpty) {
        final targetGarbage = garbages.first;
        final removed = game.garbageManager.removeGarbageAt(
          targetGarbage.position,
        );

        expect(removed, isNotNull);
        expect(removed, targetGarbage);
      }
    });
  });
}
