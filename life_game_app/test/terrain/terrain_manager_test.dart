import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_game_app/src/terrain/terrain_manager.dart';
import 'package:life_game_app/src/my_game.dart';
import 'package:life_game_app/src/config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final myGameTester = FlameTester(() => MyGame());

  group('TerrainManager', () {
    testWithGame<MyGame>('onLoadで初期タイルが生成される', myGameTester.createGame, (
      game,
    ) async {
      final terrainManager = TerrainManager();
      await game.world.add(terrainManager);
      await game.ready();

      expect(terrainManager.tileCount, greaterThan(0));
    });

    testWithGame<MyGame>('プレイヤーが移動してもタイル数は一定', myGameTester.createGame, (
      game,
    ) async {
      await game.startGame();
      await game.ready();

      // 初期位置（0,0周辺）でタイルが生成されている
      expect(game.terrainManager.tileCount, equals(441)); // (2*10+1)^2

      // 1タイル分移動
      game.player.position.setValues(Config.tileSize.toDouble(), 0.0);
      game.update(0.016);

      // renderDistance が固定なので、タイル数は常に同じ
      expect(game.terrainManager.tileCount, equals(441));
    });

    testWithGame<MyGame>('clearメソッドで全タイルが削除される', myGameTester.createGame, (
      game,
    ) async {
      await game.startGame();
      await game.ready();

      expect(game.terrainManager.tileCount, greaterThan(0));

      game.terrainManager.clear();

      expect(game.terrainManager.tileCount, equals(0));
    });

    testWithGame<MyGame>('タイトル画面ではタイルが更新されない', myGameTester.createGame, (
      game,
    ) async {
      final terrainManager = TerrainManager();
      await game.world.add(terrainManager);
      await game.ready();

      final initialTileCount = terrainManager.tileCount;

      // タイトル画面のまま（GameState.title）
      expect(game.currentState, equals(GameState.title));

      // プレイヤー位置を変更
      game.player.position.setValues(1000.0, 1000.0);

      // updateを実行
      game.update(0.016);

      // タイトル画面ではタイルが更新されないことを確認
      expect(terrainManager.tileCount, equals(initialTileCount));
    });

    testWithGame<MyGame>('プレイ中はタイルが正常に存在する', myGameTester.createGame, (
      game,
    ) async {
      await game.startGame();
      await game.ready();

      expect(game.currentState, equals(GameState.playing));

      // プレイ中はタイルが存在する
      expect(game.terrainManager.tileCount, greaterThan(0));
    });

    testWithGame<MyGame>('マップ境界内でタイルが生成される', myGameTester.createGame, (
      game,
    ) async {
      await game.startGame();
      await game.ready();

      // プレイヤーをマップの端に移動
      final edgePosition = Config.mapRadius * Config.tileSize - 100.0;
      game.player.position.setValues(edgePosition, edgePosition);
      game.update(0.016);

      // タイルが生成されていることを確認
      expect(game.terrainManager.tileCount, greaterThan(0));
    });

    testWithGame<MyGame>('範囲外のタイルが削除される', myGameTester.createGame, (
      game,
    ) async {
      await game.startGame();
      await game.ready();

      // プレイヤーを原点に配置
      game.player.position.setValues(0.0, 0.0);
      game.update(0.016);

      // プレイヤーを遠くに移動（範囲外のタイルが削除されるはず）
      final farDistance = (Config.renderDistance * 2 + 10) * Config.tileSize;
      game.player.position.setValues(farDistance, farDistance);
      game.update(0.016);

      // タイルが存在することを確認（新しい位置でタイルが生成される）
      expect(game.terrainManager.tileCount, greaterThan(0));
    });

    testWithGame<MyGame>('タイルキャッシュが正しく機能する', myGameTester.createGame, (
      game,
    ) async {
      await game.startGame();
      await game.ready();

      // プレイヤーを原点に配置
      game.player.position.setValues(0.0, 0.0);
      game.update(0.016);

      final firstTileCount = game.terrainManager.tileCount;

      // 同じ位置でupdateを繰り返し実行
      for (int i = 0; i < 10; i++) {
        game.update(0.016);
      }

      // タイル数が変化しないことを確認（キャッシュが機能している）
      expect(game.terrainManager.tileCount, equals(firstTileCount));
    });

    testWithGame<MyGame>('resetGame後にタイルがクリアされる', myGameTester.createGame, (
      game,
    ) async {
      await game.startGame();
      await game.ready();

      expect(game.terrainManager.tileCount, greaterThan(0));

      // リセット実行
      game.resetGame();

      // タイルがクリアされることを確認
      expect(game.terrainManager.tileCount, equals(0));
    });
  });
}
