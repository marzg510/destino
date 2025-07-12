import 'package:flame/components.dart';
import '../components/player.dart';
import '../components/background_tile.dart';
import '../components/destination_marker.dart';
import '../constants/game_constants.dart';

class MyWorld extends World {
  late Player player;
  DestinationMarker? destinationMarker;

  // タイルキャッシュ
  final Map<String, BackgroundTile> _tiles = {};

  // 最適化: 前回のプレイヤーのタイル位置を記録
  int _lastPlayerTileX = 0;
  int _lastPlayerTileY = 0;

  @override
  Future<void> onLoad() async {
    player = Player(position: Vector2.zero());
    add(player);

    // 初期タイルを生成
    _updateVisibleTiles();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // プレイヤーの現在のタイル座標を計算
    final currentTileX = (player.position.x / GameConstants.tileSize).floor();
    final currentTileY = (player.position.y / GameConstants.tileSize).floor();

    // タイル位置が変化した場合のみ可視タイルを更新
    if (currentTileX != _lastPlayerTileX || currentTileY != _lastPlayerTileY) {
      _lastPlayerTileX = currentTileX;
      _lastPlayerTileY = currentTileY;
      _updateVisibleTiles();
    }
  }

  void _updateVisibleTiles() {
    // プレイヤーの現在位置からタイル座標を計算
    final playerTileX = (player.position.x / GameConstants.tileSize).round();
    final playerTileY = (player.position.y / GameConstants.tileSize).round();

    // 現在表示すべきタイルの範囲
    final minX = (playerTileX - GameConstants.renderDistance).clamp(-GameConstants.mapRadius, GameConstants.mapRadius);
    final maxX = (playerTileX + GameConstants.renderDistance).clamp(-GameConstants.mapRadius, GameConstants.mapRadius);
    final minY = (playerTileY - GameConstants.renderDistance).clamp(-GameConstants.mapRadius, GameConstants.mapRadius);
    final maxY = (playerTileY + GameConstants.renderDistance).clamp(-GameConstants.mapRadius, GameConstants.mapRadius);

    // 現在表示すべきタイルのセット
    final visibleTiles = <String>{};

    // 必要なタイルを生成・追加
    for (int i = minX; i <= maxX; i++) {
      for (int j = minY; j <= maxY; j++) {
        final key = '$i,$j';
        visibleTiles.add(key);

        if (!_tiles.containsKey(key)) {
          final tile = BackgroundTile(
            position: Vector2(i * GameConstants.tileSize, j * GameConstants.tileSize),
            gridX: i,
            gridY: j,
          );
          _tiles[key] = tile;
          add(tile);
        }
      }
    }

    // 範囲外のタイルを削除
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

  void setPlayerDestination(Vector2 target) {
    player.setDestination(target);
    
    // 既存のマーカーを削除
    if (destinationMarker != null) {
      destinationMarker!.removeFromParent();
    }
    
    // 新しいマーカーを作成
    destinationMarker = DestinationMarker(position: target);
    add(destinationMarker!);
  }

  void clearDestination() {
    player.stopAutoMovement();
    
    // マーカーを削除
    if (destinationMarker != null) {
      destinationMarker!.removeFromParent();
      destinationMarker = null;
    }
  }
}