import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import '../my_game.dart';
import '../components/terrain_tile.dart';
import '../config.dart';
import '../terrain/terrain_generator.dart';

class TerrainManager extends Component with HasGameReference<MyGame> {
  final Map<String, TerrainTile> _tiles = {};
  final TerrainGenerator _terrainGenerator = TerrainGenerator();

  int _lastPlayerTileX = 0;
  int _lastPlayerTileY = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _updateVisibleTiles();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!game.isPlaying) return;

    final player = game.player;
    final currentTileX = (player.position.x / Config.tileSize).floor();
    final currentTileY = (player.position.y / Config.tileSize).floor();

    if (currentTileX != _lastPlayerTileX || currentTileY != _lastPlayerTileY) {
      _lastPlayerTileX = currentTileX;
      _lastPlayerTileY = currentTileY;
      _updateVisibleTiles();
    }
  }

  void _updateVisibleTiles() {
    final player = game.player;
    final playerTileX = (player.position.x / Config.tileSize).round();
    final playerTileY = (player.position.y / Config.tileSize).round();

    final minX = (playerTileX - Config.renderDistance).clamp(
      -Config.mapRadius,
      Config.mapRadius,
    );
    final maxX = (playerTileX + Config.renderDistance).clamp(
      -Config.mapRadius,
      Config.mapRadius,
    );
    final minY = (playerTileY - Config.renderDistance).clamp(
      -Config.mapRadius,
      Config.mapRadius,
    );
    final maxY = (playerTileY + Config.renderDistance).clamp(
      -Config.mapRadius,
      Config.mapRadius,
    );

    final visibleTiles = <String>{};

    for (int i = minX; i <= maxX; i++) {
      for (int j = minY; j <= maxY; j++) {
        final key = '$i,$j';
        visibleTiles.add(key);

        if (!_tiles.containsKey(key)) {
          final terrainType = _terrainGenerator.terrainMap.hasTerrain(i, j)
              ? _terrainGenerator.terrainMap.getTerrain(i, j)
              : _terrainGenerator.generateTerrainAt(i, j);

          _terrainGenerator.terrainMap.setTerrain(i, j, terrainType);

          final tile = TerrainTile(
            position: Vector2(i * Config.tileSize, j * Config.tileSize),
            gridX: i,
            gridY: j,
            terrainType: terrainType,
          );
          _tiles[key] = tile;
          game.world.add(tile);
        }
      }
    }

    final tilesToRemove = <String>[];
    for (final key in _tiles.keys) {
      if (!visibleTiles.contains(key)) {
        tilesToRemove.add(key);
      }
    }

    for (final key in tilesToRemove) {
      final tile = _tiles.remove(key);
      if (tile != null) {
        tile.removeFromParent();
      }
    }
  }

  void clear() {
    for (final tile in _tiles.values) {
      tile.removeFromParent();
    }
    _tiles.clear();
    _lastPlayerTileX = 0;
    _lastPlayerTileY = 0;
  }

  @visibleForTesting
  int get tileCount => _tiles.length;
}
