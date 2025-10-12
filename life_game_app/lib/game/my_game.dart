import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'my_world.dart';
import '../managers/game_state_manager.dart';
import '../enums/game_state.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents, TapCallbacks {
  late MyWorld myWorld;
  final GameStateManager stateManager = GameStateManager();

  @override
  Future<void> onLoad() async {
    myWorld = MyWorld();
    world = myWorld;
    await myWorld.loaded;
    camera.follow(myWorld.player);

    // MyWorldをリスナーとして登録
    stateManager.addListener(myWorld);

    // ゲーム開始時はplaying状態にする
    stateManager.setState(GameState.playing);

    return super.onLoad();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // paused状態ではキーボード入力を無効化
    if (!stateManager.isPaused) {
      myWorld.player.handleInput(keysPressed);
    }
    super.onKeyEvent(event, keysPressed);
    return KeyEventResult.handled;
  }

  @override
  bool onTapDown(TapDownEvent event) {
    // 一時停止/再開の切り替え
    // GameStateManagerが状態を変更し、リスナー経由でMyWorldに通知される
    if (stateManager.isPlaying) {
      stateManager.pause();
    } else if (stateManager.isPaused) {
      stateManager.resume();
    }

    return true;
  }
}
