import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DestinationMarker extends CircleComponent {
  DestinationMarker({super.position})
    : super(
        radius: 10,
        anchor: Anchor.center,
        paint: Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

  @override
  bool get debugMode => true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void render(Canvas canvas) {
    // 外側の円（親クラスで描画）
    // super.render(canvas);

    // 内側の円
    canvas.drawCircle(
      Offset(radius, radius),
      radius * 0.3,
      Paint()..color = Colors.red,
    );
  }
}
