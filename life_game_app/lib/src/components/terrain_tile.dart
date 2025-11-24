import 'package:flame/components.dart';
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
    final image = game.images.fromCache(terrainType.spritePath);
    sprite = Sprite(image);
  }
}
