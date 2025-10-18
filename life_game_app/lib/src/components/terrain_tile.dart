import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config.dart';
import '../terrain/terrain_type.dart';

class TerrainTile extends SpriteComponent with HasGameReference {
  final int gridX;
  final int gridY;
  final TerrainType terrainType;

  TerrainTile({
    super.position,
    required this.gridX,
    required this.gridY,
    required this.terrainType,
  }) : super(size: Vector2.all(Config.tileSize), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    try {
      sprite = await Sprite.load(terrainType.spritePath);
      // sprite = await Sprite.load('ocean.png');
      // sprite = await Sprite.load('walk_boy_walk.png');
      // sprite = await Sprite.load('terrain/mountain.png');
      // sprite = await Sprite.load('o.bmp');
    } catch (e) {
      // 画像が見つからない場合はフォールバック色を使用
      sprite = null;
      _addColorFallback();
    }

    // デバッグ用の座標表示
    if (gridX % 4 == 0 && gridY % 4 == 0) {
      add(
        TextComponent(
          text: '($gridX,$gridY)\n${terrainType.displayName}',
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _addColorFallback() {
    Color color;
    switch (terrainType) {
      case TerrainType.ocean:
        color = const Color(0xFF2196F3);
        break;
      case TerrainType.grassland:
        color = const Color(0xFF4CAF50);
        break;
      case TerrainType.mountain:
        color = const Color(0xFF795548);
        break;
    }

    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = color,
        anchor: Anchor.center,
      ),
    );
  }
}
