import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import '../constants/game_constants.dart';

class Player extends SpriteComponent {
  Vector2 velocity = Vector2.zero();
  Vector2? destination;
  bool isAutoMovementActive = true;

  Player({super.position})
    : super(size: Vector2.all(GameConstants.playerSize), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('walk_boy_walk.png');
  }

  void setDestination(Vector2 target) {
    destination = target.clone();
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

    if (!isAutoMovementActive || destination == null) return;

    Vector2 direction = destination! - position;
    double distance = direction.length;

    // 目的地の到達判定
    if (distance > GameConstants.arrivalThreshold) {
      // 正規化された方向ベクトルを計算
      direction.normalize();
      velocity = direction * GameConstants.playerSpeed;
    } else {
      // 目的地に到達
      final arrivalPosition = position.clone();
      stopAutoMovement();
      velocity = Vector2.zero();
      // MyWorldに到達を通知（プレイヤーの現在位置で演出）
      if (parent != null) {
        (parent as dynamic).showArrivalEffect?.call(arrivalPosition);
        (parent as dynamic).clearDestination?.call();
        (parent as dynamic).setRandomDestination?.call();
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
  }
}
