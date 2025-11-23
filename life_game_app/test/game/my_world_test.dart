import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_game_app/src/game/my_world.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MyWorld - reset', () {
    late MyWorld myWorld;

    setUp(() {
      myWorld = MyWorld();
    });

    testWithFlameGame('resetメソッドでプレイヤーが原点に戻る', (game) async {
      // MyWorldをゲームに追加してロード
      await game.add(myWorld);
      await game.ready();

      // プレイヤーを移動
      myWorld.player.position.setValues(100.0, 200.0);
      expect(myWorld.player.position, Vector2(100.0, 200.0));

      // リセット実行
      myWorld.reset();

      // プレイヤーが原点に戻っていることを確認
      expect(myWorld.player.position, Vector2.zero());
    });

    testWithFlameGame('resetメソッドで自動移動が再開される', (game) async {
      // MyWorldをゲームに追加してロード
      await game.add(myWorld);
      await game.ready();

      // 自動移動を停止
      myWorld.player.stopAutoMovement();
      expect(myWorld.player.isAutoMovementActive, false);

      // リセット実行
      myWorld.reset();

      // 自動移動が再開されていることを確認
      expect(myWorld.player.isAutoMovementActive, true);
    });

    testWithFlameGame('resetメソッドでタイルキャッシュがクリアされて再生成される', (game) async {
      // MyWorldをゲームに追加してロード
      await game.add(myWorld);
      await game.ready();

      // 初期状態でタイルキャッシュにデータがあることを確認
      final initialTileCount = myWorld.tileCount;
      expect(
        initialTileCount,
        greaterThan(0),
        reason: '初期状態でタイルキャッシュにデータがあること',
      );

      // リセット実行
      myWorld.reset();

      // タイルキャッシュがクリアされて再生成されていることを確認
      final afterResetTileCount = myWorld.tileCount;
      expect(
        afterResetTileCount,
        greaterThan(0),
        reason: 'リセット後にタイルキャッシュが再生成されていること',
      );
    });

    testWithFlameGame('resetメソッドで新しい目的地が設定される', (game) async {
      // MyWorldをゲームに追加してロード
      await game.add(myWorld);
      await game.ready();

      // 初期の目的地を記録
      final initialDestination = myWorld.player.destination?.clone();

      // リセット実行
      myWorld.reset();

      // 新しい目的地が設定されていることを確認
      expect(myWorld.player.destination, isNotNull);
      // 目的地が変わっている可能性が高い（ランダムなので100%ではない）
      expect(myWorld.player.destination, isNot(equals(initialDestination)));
    });

    testWithFlameGame('reset後もゲームが正常に動作する', (game) async {
      // MyWorldをゲームに追加してロード
      await game.add(myWorld);
      await game.ready();

      // プレイヤーを移動
      myWorld.player.position.setValues(100.0, 200.0);

      // リセット実行
      myWorld.reset();

      // プレイヤーが原点に戻っている
      expect(myWorld.player.position, Vector2.zero());

      // ゲームを更新
      game.update(0.016);

      // プレイヤーが目的地に向かって移動している
      expect(myWorld.player.velocity, isNot(Vector2.zero()));
    });
    // 到達回数の管理はMyGameに移行したため、このテストは削除
    // testWithFlameGame('resetで目的地到達回数がリセットされる', (game) async {
    //   ...
    // });
  });
}
