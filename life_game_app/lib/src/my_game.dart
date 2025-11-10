import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'game/my_world.dart';
import 'components/debug_overlay.dart';
import 'game/game_state_manager.dart';
import 'game/game_state.dart';
import 'components/title_screen.dart';
import 'components/player.dart';

class MyGame extends FlameGame with KeyboardEvents, TapDetector {
  late MyWorld myWorld;
  late TitleScreen titleScreen;
  final GameStateManager stateManager = GameStateManager();
  final ValueNotifier<int> arrivalCount = ValueNotifier<int>(0);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // タイトル画面を作成
    titleScreen = TitleScreen(
      position: Vector2.zero(),
      size: camera.viewport.size,
    );

    // タイトル画面を追加（カメラのHUDとして追加）
    camera.viewport.add(titleScreen);

    // 初期状態はtitle
    stateManager.setState(GameState.title);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // タイトル画面またはpaused状態ではキーボード入力を無効化
    if (stateManager.currentState != GameState.title &&
        !stateManager.isPaused) {
      world.children.query<Player>().first.handleInput(keysPressed);
      // world.player.handleInput(keysPressed);
    }
    super.onKeyEvent(event, keysPressed);
    return KeyEventResult.handled;
  }

  @override
  void onTap() {
    super.onTap();

    debugPrint('Tap detected');
    // タイトル画面でタップしたらゲーム開始
    if (stateManager.currentState == GameState.title) {
      startGame();
    }

    // ゲーム中の一時停止/再開の切り替え
    if (stateManager.isPlaying) {
      debugPrint('StateManager pause');
      stateManager.pause();
    } else if (stateManager.isPaused) {
      debugPrint('StateManager resume');
      stateManager.resume();
    }
  }

  Future<void> startGame() async {
    if (stateManager.currentState == GameState.playing) return;

    // タイトル画面を非表示にする
    titleScreen.removeFromParent();

    // MyWorldを作成して表示
    myWorld = MyWorld();
    world = myWorld;
    await world.loaded;
    camera.follow(world.children.query<Player>().first);

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
