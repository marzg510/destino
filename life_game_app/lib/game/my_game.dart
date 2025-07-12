import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'my_world.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents, TapCallbacks {
  late MyWorld myWorld;

  @override
  Future<void> onLoad() async {
    myWorld = MyWorld();
    world = myWorld;
    await myWorld.loaded;
    camera.follow(myWorld.player);

    return super.onLoad();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    myWorld.player.handleInput(keysPressed);
    super.onKeyEvent(event, keysPressed);
    return KeyEventResult.handled;
  }

  @override
  bool onTapDown(TapDownEvent event) {
    // タップした位置をワールド座標に変換
    final tapPosition = event.localPosition;
    
    // カメラのオフセットを考慮してワールド座標を計算
    final worldTapPosition = Vector2(
      tapPosition.x - size.x / 2 + camera.viewfinder.position.x,
      tapPosition.y - size.y / 2 + camera.viewfinder.position.y,
    );
    
    // プレイヤーの目的地を設定
    myWorld.setPlayerDestination(worldTapPosition);
    
    return true;
  }
}
