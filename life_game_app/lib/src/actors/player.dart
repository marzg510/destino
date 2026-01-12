import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../my_game.dart';
import '../config.dart';
import 'garbage.dart';

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameReference<MyGame> {
  Vector2 velocity = Vector2.zero();
  Vector2? destination;
  bool isAutoMovementActive = true;
  bool _isProcessingArrival = false;
  bool isManualMovement = false;

  @override
  bool get debugMode => Config.debugMode;

  Player({super.position})
    : super(size: Vector2.all(Config.playerSize), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final image = game.images.fromCache('walk_boy_walk.png');
    sprite = Sprite(image);
    add(CircleHitbox());
  }

  void setDestination(Vector2 target, {bool manual = false}) {
    destination = target.clone();
    isManualMovement = manual;
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

    // 目的地への到着チェック
    if (destination != null && !_isProcessingArrival) {
      final distanceToDestination = (destination! - position).length;
      if (distanceToDestination <= Config.arrivalThreshold) {
        _isProcessingArrival = true;
        stopAutoMovement();
        velocity = Vector2.zero();
        if (isMounted) {
          game.onDestinationReached(position.clone(), isManualMovement);
          Future.delayed(Duration(milliseconds: 200), () {
            _isProcessingArrival = false;
          });
        }
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // Garbageとの衝突判定
    if (other is Garbage && isMounted) {
      game.onGarbageCollected(other);
    }
  }
}
