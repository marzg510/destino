import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../my_game.dart';
import '../config.dart';
import 'garbage.dart';

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameReference<MyGame> {
  Vector2 velocity = Vector2.zero();
  Vector2? destination;
  bool isManualMovement = false;
  double _idleTime = 0.0; // 手動モード時のアイドル経過時間

  @override
  bool get debugMode => Config.debugMode;

  // デバッグ用のアイドルタイムゲッター
  double get idleTime => _idleTime;

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
    _idleTime = 0.0; // アイドルタイマーをリセット
    // 正規化された方向ベクトルを計算
    Vector2 direction = destination! - position;
    direction.normalize();
    velocity = direction * Config.playerSpeed;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (destination == null) {
      velocity = Vector2.zero();

      // アイドルタイムアウトロジック
      if (isManualMovement) {
        _idleTime += dt;

        if (_idleTime >= Config.manualModeIdleTimeout) {
          // タイムアウト到達 - 自動モードに切り替え
          isManualMovement = false;
          _idleTime = 0.0;

          // ゲームに次のゴミを選択するよう通知
          (game as MyGame).onPlayerIdleTimeout();
        }
      }

      return;
    }

    // 目的地がある場合はアイドルタイマーをリセット
    _idleTime = 0.0;

    // 移動処理
    final newPosition = position + velocity * dt;

    // マップ境界チェック
    final mapBounds = Config.mapRadius * Config.tileSize;
    final clampedPosition = Vector2(
      newPosition.x.clamp(-mapBounds + size.x / 2, mapBounds - size.x / 2),
      newPosition.y.clamp(-mapBounds + size.y / 2, mapBounds - size.y / 2),
    );

    position = clampedPosition;

    // 目的地到着チェック
    final distanceToDestination = (destination! - position).length;
    if (distanceToDestination <= Config.arrivalThreshold) {
      // 到着処理
      velocity = Vector2.zero();
      destination = null;
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
