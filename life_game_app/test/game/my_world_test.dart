import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_game_app/game/my_world.dart';
import 'package:life_game_app/enums/game_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MyWorld - onGameStateChanged', () {
    late MyWorld myWorld;

    setUp(() {
      myWorld = MyWorld();
    });

    testWithFlameGame('paused状態に遷移するとゲームがが停止する', (game) async {
      // MyWorldをゲームに追加してロード
      await game.add(myWorld);
      await game.ready();

      // プレイヤーが自動移動している状態にする
      // myWorld.setRandomDestination();
      myWorld.player.startAutoMovement();
      expect(myWorld.player.isAutoMovementActive, true);

      // paused状態に変更
      myWorld.onGameStateChanged(GameState.paused);

      // プレイヤーの自動移動が停止していることを確認
      expect(myWorld.player.isAutoMovementActive, false);
    });

    testWithFlameGame('playing状態に遷移するとゲームが再開する', (game) async {
      // MyWorldをゲームに追加してロード
      await game.add(myWorld);
      await game.ready();

      expect(myWorld.player.isAutoMovementActive, true);

      // paused状態にして移動を停止
      myWorld.onGameStateChanged(GameState.paused);
      expect(myWorld.player.isAutoMovementActive, false);

      // playing状態に戻す
      myWorld.onGameStateChanged(GameState.playing);

      // プレイヤーの自動移動が再開されていることを確認
      expect(myWorld.player.isAutoMovementActive, true);
    });

    testWithFlameGame('paused→playing→pausedの繰り返しが正しく動作する', (game) async {
      // MyWorldをゲームに追加してロード
      await game.add(myWorld);
      await game.ready();

      // 目的地を設定
      // myWorld.setRandomDestination();
      expect(myWorld.player.isAutoMovementActive, true);

      // 1回目: paused
      myWorld.onGameStateChanged(GameState.paused);
      expect(myWorld.player.isAutoMovementActive, false);

      // 1回目: playing
      myWorld.onGameStateChanged(GameState.playing);
      expect(myWorld.player.isAutoMovementActive, true);

      // 2回目: paused
      myWorld.onGameStateChanged(GameState.paused);
      expect(myWorld.player.isAutoMovementActive, false);

      // 2回目: playing
      myWorld.onGameStateChanged(GameState.playing);
      expect(myWorld.player.isAutoMovementActive, true);
    });

    testWithFlameGame('loading状態やtitle状態ではプレイヤーの状態が変わらない', (game) async {
      // MyWorldをゲームに追加してロード
      await game.add(myWorld);
      await game.ready();

      // プレイヤーが自動移動している状態にする
      // myWorld.setRandomDestination();
      expect(myWorld.player.isAutoMovementActive, true);

      // loading状態に変更
      myWorld.onGameStateChanged(GameState.loading);

      // プレイヤーの状態が変わっていないことを確認
      expect(myWorld.player.isAutoMovementActive, true);

      // title状態に変更
      myWorld.onGameStateChanged(GameState.title);

      // プレイヤーの状態が変わっていないことを確認
      expect(myWorld.player.isAutoMovementActive, true);
    });
  });

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
      expect(initialTileCount, greaterThan(0), reason: '初期状態でタイルキャッシュにデータがあること');

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
  });
}
