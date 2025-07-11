import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'my_world.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents {
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
}
