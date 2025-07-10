import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class LifeGame extends FlameGame with HasCollisionDetection {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(MovingSquare());
  }
}

class MovingSquare extends RectangleComponent with HasGameReference<LifeGame> {
  static const double speed = 100;
  late Vector2 velocity;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    size = Vector2(50, 50);
    position = Vector2(100, 100);
    paint.color = Colors.blue;

    velocity = Vector2(speed, speed);
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += velocity * dt;

    if (position.x <= 0 || position.x >= game.size.x - size.x) {
      velocity.x *= -1;
    }

    if (position.y <= 0 || position.y >= game.size.y - size.y) {
      velocity.y *= -1;
    }
  }
}
