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
    // 衝突判定を視覚的なサイズより大きくして、確実にゴミを取得できるようにする
    add(CircleHitbox(
      radius: Config.arrivalThreshold,
      collisionType: CollisionType.passive,
    ));
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

}
