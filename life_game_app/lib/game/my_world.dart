import 'dart:math';
import 'package:flame/components.dart';
import '../components/player.dart';
import '../components/background_tile.dart';
import '../components/destination_marker.dart';
import '../components/arrival_effect.dart';
import '../components/bloom_effect.dart';
import '../interfaces/player_events.dart';
import '../constants/game_constants.dart';
import '../managers/audio_manager.dart';

class MyWorld extends World implements PlayerEventCallbacks {
  late Player player;
  DestinationMarker? destinationMarker;
  final Random _random = Random();
  bool _isPaused = false;
  final AudioManager _audioManager = AudioManager();

  // タイルキャッシュ
  final Map<String, BackgroundTile> _tiles = {};

  // 最適化: 前回のプレイヤーのタイル位置を記録
  int _lastPlayerTileX = 0;
  int _lastPlayerTileY = 0;

  @override
  Future<void> onLoad() async {
    player = Player(position: Vector2.zero());
    player.eventCallbacks = this; // コールバックを設定
    add(player);

    // 初期タイルを生成
    _updateVisibleTiles();

    // ゲーム開始時にランダムな目的地を設定
    setRandomDestination();
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
    final minX = (playerTileX - GameConstants.renderDistance).clamp(
      -GameConstants.mapRadius,
      GameConstants.mapRadius,
    );
    final maxX = (playerTileX + GameConstants.renderDistance).clamp(
      -GameConstants.mapRadius,
      GameConstants.mapRadius,
    );
    final minY = (playerTileY - GameConstants.renderDistance).clamp(
      -GameConstants.mapRadius,
      GameConstants.mapRadius,
    );
    final maxY = (playerTileY + GameConstants.renderDistance).clamp(
      -GameConstants.mapRadius,
      GameConstants.mapRadius,
    );

    // 現在表示すべきタイルのセット
    final visibleTiles = <String>{};

    // 必要なタイルを生成・追加
    for (int i = minX; i <= maxX; i++) {
      for (int j = minY; j <= maxY; j++) {
        final key = '$i,$j';
        visibleTiles.add(key);

        if (!_tiles.containsKey(key)) {
          final tile = BackgroundTile(
            position: Vector2(
              i * GameConstants.tileSize,
              j * GameConstants.tileSize,
            ),
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

  void setRandomDestination() {
    // プレイヤーの現在位置から300～500の距離範囲のランダムな位置を生成
    final playerPos = player.position;
    final minDistance = 300.0;
    final maxDistance = 500.0;

    // ランダムな角度と距離を生成
    final angle = _random.nextDouble() * 2 * pi;
    final distance =
        minDistance + _random.nextDouble() * (maxDistance - minDistance);

    // 極座標から直交座標に変換
    final randomTarget = Vector2(
      playerPos.x + cos(angle) * distance,
      playerPos.y + sin(angle) * distance,
    );

    // マップ境界内にクランプ
    final mapBounds = GameConstants.mapRadius * GameConstants.tileSize;
    final clampedTarget = Vector2(
      randomTarget.x.clamp(-mapBounds, mapBounds),
      randomTarget.y.clamp(-mapBounds, mapBounds),
    );

    setPlayerDestination(clampedTarget);
  }

  void clearDestination() {
    player.stopAutoMovement();

    // マーカーを削除
    if (destinationMarker != null) {
      destinationMarker!.removeFromParent();
      destinationMarker = null;
    }
  }

  void showArrivalEffect(Vector2 position) {
    final effect = ArrivalEffect(effectPosition: position);
    add(effect);
    // 目的地到達時に花エフェクトを追加
    final offset = Vector2(20, 10);
    final bloomPosition = position + offset;
    final bloomEffect = BloomEffect(effectPosition: bloomPosition);
    add(bloomEffect);
  }

  void togglePause() {
    _isPaused = !_isPaused;
    if (_isPaused) {
      // 一時停止時は移動を停止
      player.stopAutoMovement();
    } else {
      // 再開時は既存の目的地があれば再開、なければ新しい目的地を設定
      if (destinationMarker != null) {
        player.startAutoMovement();
      } else {
        setRandomDestination();
      }
    }
  }

  @override
  void onPlayerArrival(Vector2 arrivalPosition) {
    // 効果音を再生
    _audioManager.playArrivalSound();
    // 演出を表示
    showArrivalEffect(arrivalPosition);
    // 目的地をクリア
    clearDestination();
    // 新しい目的地を設定
    setRandomDestination();
  }
}
