import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import '../game/my_world.dart';

/// シンプルな到達回数表示コンポーネント
/// Camera.viewport に追加して画面に固定表示する想定
class ArrivalCounter extends TextComponent {
  final MyWorld world;

  ArrivalCounter({required this.world})
    : super(
        position: Vector2(10, 10),
        anchor: Anchor.topLeft,
        priority: 200,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  @override
  void update(double dt) {
    // 毎フレーム最新のカウントを表示
    text = '到達: ${world.arrivalCount}';
    super.update(dt);
  }
}
