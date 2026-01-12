import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config.dart';

class Garbage extends CircleComponent {
  Garbage({super.position})
    : super(
        radius: Config.garbageSize,
        anchor: Anchor.center,
        paint: Paint()
          ..color = Colors.yellow.withValues(alpha: 0.8)
          ..style = PaintingStyle.fill,
      );

  @override
  bool get debugMode => Config.debugMode;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 外枠を追加
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      Paint()
        ..color = Colors.green.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  /// ゴミの位置をキーとして取得
  ///
  /// Config.minGarbageSpacing単位でグリッド化することで、
  /// 同じキーを持つゴミは必然的に最小距離以内に収まる
  (int, int) getKey() {
    return (
      (position.x / Config.minGarbageSpacing).round(),
      (position.y / Config.minGarbageSpacing).round(),
    );
  }
}
