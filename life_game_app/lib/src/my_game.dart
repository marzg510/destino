import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'game/my_world.dart';
import 'components/debug_overlay.dart';
import 'components/title_screen.dart';
import 'components/player.dart';
import 'managers/audio_manager.dart';

enum GameState {
  loading, // ローディング
  title, // タイトル
  playing, // プレイ中
  paused, // 一時停止
}

class MyGame extends FlameGame with KeyboardEvents, TapDetector {
  late MyWorld myWorld;
  late TitleScreen titleScreen;
  GameState _currentState = GameState.loading;
  final ValueNotifier<int> arrivalCount = ValueNotifier<int>(0);
  final AudioManager _audioManager = AudioManager();

  // GameState管理
  GameState get currentState => _currentState;
  bool get isPlaying => _currentState == GameState.playing;
  bool get isPaused => _currentState == GameState.paused;

  void setState(GameState newState) {
    _currentState = newState;
    _notifyStateChange(newState);
  }

  void pause() => setState(GameState.paused);
  void resume() => setState(GameState.playing);

  void _notifyStateChange(GameState newState) {
    // MyWorldが存在する場合のみ通知
    if (world is MyWorld) {
      (world as MyWorld).onGameStateChanged(newState);
    }
  }

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
    setState(GameState.title);

    await add(FpsTextComponent(position: Vector2(10, 100)));
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // タイトル画面またはpaused状態ではキーボード入力を無効化
    if (currentState != GameState.title && !isPaused) {
      final MyWorld myWorld = world as MyWorld;
      myWorld.player.handleInput(keysPressed);
    }
    super.onKeyEvent(event, keysPressed);
    return KeyEventResult.handled;
  }

  @override
  void onTap() {
    super.onTap();

    debugPrint('Tap detected');
    // タイトル画面でタップしたらゲーム開始
    if (currentState == GameState.title) {
      startGame();
    }

    // ゲーム中の一時停止/再開の切り替え
    if (isPlaying) {
      debugPrint('pause');
      pause();
    } else if (isPaused) {
      debugPrint('resume');
      resume();
    }
  }

  Future<void> startGame() async {
    if (currentState == GameState.playing) return;

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

    // ゲーム開始（playing状態にする）
    setState(GameState.playing);
  }

  void resetGame() {
    myWorld.reset();
    arrivalCount.value = 0;
    setState(GameState.playing);
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
