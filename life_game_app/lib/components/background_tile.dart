import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../constants/game_constants.dart';

class BackgroundTile extends RectangleComponent with HasGameReference {
  final int gridX;
  final int gridY;

  BackgroundTile({super.position, required this.gridX, required this.gridY})
      : super(size: Vector2.all(GameConstants.tileSize), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // チェッカーボード状の色分け
    final isEven = (gridX + gridY) % 2 == 0;
    final color = isEven
        ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
        : const Color(0xFF81C784).withValues(alpha: 0.3);

    paint = Paint()..color = color;

    // 境界線を追加
    final borderPaint = Paint()
      ..color = const Color(0xFF388E3C).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    add(
      RectangleComponent(size: size, paint: borderPaint, anchor: Anchor.center),
    );

    // 座標をテキストで表示
    if (gridX % 2 == 0 && gridY % 2 == 0) {
      add(
        TextComponent(
          text: '($gridX,$gridY)',
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 12),
          ),
        ),
      );
    }
  }
}