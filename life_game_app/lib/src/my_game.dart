import 'package:flame/components.dart';
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
import 'managers/audio_manager.dart';

class MyGame extends FlameGame with KeyboardEvents, TapDetector {
  late MyWorld myWorld;
  late TitleScreen titleScreen;
  final GameStateManager stateManager = GameStateManager();
  final ValueNotifier<int> arrivalCount = ValueNotifier<int>(0);
  final AudioManager _audioManager = AudioManager();

  @override
  Future<void> onLoad() async {
    debugMode = true;
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

    await add(FpsTextComponent(position: Vector2(10, 100)));
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // タイトル画面またはpaused状態ではキーボード入力を無効化
    if (stateManager.currentState != GameState.title &&
        !stateManager.isPaused) {
      final players = world.children.query<Player>();
      if (players.isNotEmpty) {
        players.first.handleInput(keysPressed);
      }
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
    final players = world.children.query<Player>();
    if (players.isNotEmpty) {
      camera.follow(players.first);
    }

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
    arrivalCount.value = 0;
    stateManager.setState(GameState.playing);
  }

  void onPlayerArrival(Vector2 arrivalPosition) {
    debugPrint('Player arrived at $arrivalPosition');
    // 効果音を再生
    _audioManager.playArrivalSound();
    // 演出を表示
    myWorld.showArrivalEffect(arrivalPosition);
    // 到達回数を増やす
    arrivalCount.value = arrivalCount.value + 1;
    // 目的地をクリア
    myWorld.clearDestination();
    // 新しい目的地を設定
    myWorld.setRandomDestination();
  }
}
