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
}
