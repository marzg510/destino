import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import '../constants/game_constants.dart';

class Player extends SpriteComponent {
  Vector2 velocity = Vector2.zero();
  Vector2? destination;
  bool isMovingToDestination = false;

  Player({super.position})
      : super(size: Vector2.all(GameConstants.playerSize), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('walk_boy_walk.png');
  }

  void setDestination(Vector2 target) {
    destination = target.clone();
    isMovingToDestination = true;
  }

  void stopAutoMovement() {
    isMovingToDestination = false;
    destination = null;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 目的地への自動移動が有効な場合
    if (isMovingToDestination && destination != null) {
      Vector2 direction = destination! - position;
      double distance = direction.length;
      
      if (distance > GameConstants.movementThreshold) {
        direction.normalize();
        velocity = direction * GameConstants.playerSpeed;
      } else {
        position = destination!.clone();
        isMovingToDestination = false;
        destination = null;
        velocity = Vector2.zero();
      }
    }

    // 移動処理
    final newPosition = position + velocity * dt;

    // マップ境界チェック
    final mapBounds = GameConstants.mapRadius * GameConstants.tileSize;
    final clampedPosition = Vector2(
      newPosition.x.clamp(-mapBounds + size.x / 2, mapBounds - size.x / 2),
      newPosition.y.clamp(-mapBounds + size.y / 2, mapBounds - size.y / 2),
    );

    position = clampedPosition;
  }

  void handleInput(Set<LogicalKeyboardKey> keysPressed) {
    // 手動操作中は自動移動を停止
    if (keysPressed.isNotEmpty) {
      stopAutoMovement();
    }

    velocity = Vector2.zero();

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      velocity.x = -GameConstants.playerSpeed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      velocity.x = GameConstants.playerSpeed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW)) {
      velocity.y = -GameConstants.playerSpeed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS)) {
      velocity.y = GameConstants.playerSpeed;
    }
  }
}