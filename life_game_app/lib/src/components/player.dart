import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import '../my_game.dart';
import '../config.dart';
import 'destination_marker.dart';

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameReference<MyGame> {
  Vector2 velocity = Vector2.zero();
  Vector2? destination;
  bool isAutoMovementActive = true;

  @override
  bool get debugMode => true;

  Player({super.position})
    : super(size: Vector2.all(Config.playerSize), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('walk_boy_walk.png');
    add(CircleHitbox());
  }

  void setDestination(Vector2 target) {
    destination = target.clone();
    // 正規化された方向ベクトルを計算
    Vector2 direction = destination! - position;
    direction.normalize();
    velocity = direction * Config.playerSpeed;
    startAutoMovement();
  }

  void stopAutoMovement() {
    isAutoMovementActive = false;
  }

  void startAutoMovement() {
    isAutoMovementActive = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isAutoMovementActive || destination == null) {
      velocity = Vector2.zero();
      return;
    }

    // 移動処理
    final newPosition = position + velocity * dt;

    // マップ境界チェック
    final mapBounds = Config.mapRadius * Config.tileSize;
    final clampedPosition = Vector2(
      newPosition.x.clamp(-mapBounds + size.x / 2, mapBounds - size.x / 2),
      newPosition.y.clamp(-mapBounds + size.y / 2, mapBounds - size.y / 2),
    );

    position = clampedPosition;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is DestinationMarker) {
      // 目的地の到達判定
      Vector2 direction = other.position - position;
      double distance = direction.length;
      if (distance <= Config.arrivalThreshold) {
        // 目的地に到達
        stopAutoMovement();
        velocity = Vector2.zero();
        // 到達イベントを通知
        if (isMounted) game.onPlayerArrival(position.clone());
      }
    }
  }

  // @override
  // void handleInput(Set<LogicalKeyboardKey> keysPressed) {
  // velocity = Vector2.zero();

  // if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
  //     keysPressed.contains(LogicalKeyboardKey.keyA)) {
  //   velocity.x = -GameConstants.playerSpeed;
  // }
  // if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
  //     keysPressed.contains(LogicalKeyboardKey.keyD)) {
  //   velocity.x = GameConstants.playerSpeed;
  // }
  // if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
  //     keysPressed.contains(LogicalKeyboardKey.keyW)) {
  //   velocity.y = -GameConstants.playerSpeed;
  // }
  // if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
  //     keysPressed.contains(LogicalKeyboardKey.keyS)) {
  //   velocity.y = GameConstants.playerSpeed;
  // }
  // }
}
