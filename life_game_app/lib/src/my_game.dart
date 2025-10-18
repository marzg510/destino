import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'game/my_world.dart';
import 'components/arrival_counter.dart';
import 'components/debug_overlay.dart';
import 'game/game_state_manager.dart';
import 'game/game_state.dart';
import 'components/title_screen.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents, TapCallbacks {
  late MyWorld myWorld;
  late TitleScreen titleScreen;
  final GameStateManager stateManager = GameStateManager();

  @override
  Future<void> onLoad() async {
    // タイトル画面を作成
    titleScreen = TitleScreen(
      position: Vector2.zero(),
      size: camera.viewport.size,
    );

    // タイトル画面を追加（カメラのHUDとして追加）
    camera.viewport.add(titleScreen);

    // 初期状態はtitle
    stateManager.setState(GameState.title);

    return super.onLoad();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // タイトル画面またはpaused状態ではキーボード入力を無効化
    if (stateManager.currentState != GameState.title &&
        !stateManager.isPaused) {
      myWorld.player.handleInput(keysPressed);
    }
    super.onKeyEvent(event, keysPressed);
    return KeyEventResult.handled;
  }

  @override
  bool onTapDown(TapDownEvent event) {
    // タイトル画面でタップしたらゲーム開始
    if (stateManager.currentState == GameState.title) {
      _startGame();
      return true;
    }

    // ゲーム中の一時停止/再開の切り替え
    if (stateManager.isPlaying) {
      stateManager.pause();
    } else if (stateManager.isPaused) {
      stateManager.resume();
    }

    return true;
  }

  Future<void> _startGame() async {
    // タイトル画面を非表示にする
    titleScreen.removeFromParent();

    // MyWorldを作成して表示
    myWorld = MyWorld();
    world = myWorld;
    await myWorld.loaded;
    camera.follow(myWorld.player);

    // 到達回数オーバーレイを追加
    final arrivalCounter = ArrivalCounter(scoreManager: myWorld.scoreManager);
    camera.viewport.add(arrivalCounter);

    // デバッグオーバーレイを追加
    final debugOverlay = DebugOverlay(player: myWorld.player);
    camera.viewport.add(debugOverlay);

    // MyWorldをリスナーとして登録
    stateManager.addListener(myWorld);

    // ゲーム開始（playing状態にする）
    stateManager.setState(GameState.playing);
  }

  void resetGame() {
    myWorld.reset();
    stateManager.setState(GameState.playing);
  }
}
