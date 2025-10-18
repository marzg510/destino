import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config.dart';

class TitleScreen extends PositionComponent {
  TitleScreen({super.position, super.size});

  @override
  Future<void> onLoad() async {
    // タイトルテキスト
    final titleText = TextComponent(
      text: Config.gameTitle,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 - 50),
    );
    add(titleText);

    // 指示テキスト
    final instructionText = TextComponent(
      text: 'Tap Screen',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 24, color: Colors.white70),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 + 50),
    );
    add(instructionText);
  }

  @override
  void render(Canvas canvas) {
    // 背景を黒にする
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Colors.black,
    );
    super.render(canvas);
  }
}
