import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import '../components/player.dart';
import '../components/terrain_tile.dart';
import '../components/destination_marker.dart';
import '../components/arrival_effect.dart';
import '../components/bloom_effect.dart';
import '../interfaces/player_events.dart';
import 'game_state_listener.dart';
import '../config.dart';
import '../managers/audio_manager.dart';
import '../managers/score_manager.dart';
import 'game_state.dart';
import '../terrain/terrain_generator.dart';

class MyWorld extends World implements PlayerEventCallbacks, GameStateListener {
  late Player player;
  DestinationMarker? destinationMarker;
  final Random _random = Random();
  bool _isPaused = false;
  final AudioManager _audioManager = AudioManager();
  final TerrainGenerator _terrainGenerator = TerrainGenerator();
  // スコア管理（到達回数など）
  final ScoreManager scoreManager = ScoreManager();

  // 公開用 getter/proxy
  int get arrivalCount => scoreManager.arrivalCount;
  ValueListenable<int> get arrivalListenable =>
      scoreManager.arrivalCountListenable;

  // タイルキャッシュ
  final Map<String, TerrainTile> _tiles = {};

  // 最適化: 前回のプレイヤーのタイル位置を記録
  int _lastPlayerTileX = 0;
  int _lastPlayerTileY = 0;

  @override
  Future<void> onLoad() async {
    player = Player(position: Vector2.zero());
    player.eventCallbacks = this; // コールバックを設定
    player.priority = 100; // プレイヤーを最前面に表示
    add(player);

    // 初期タイルを生成
    _updateVisibleTiles();

    // ゲーム開始時にランダムな目的地を設定
    setRandomDestination();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // paused状態ではゲームロジックの更新をスキップ
    if (_isPaused) {
      return;
    }

    // プレイヤーの現在のタイル座標を計算
    final currentTileX = (player.position.x / Config.tileSize).floor();
    final currentTileY = (player.position.y / Config.tileSize).floor();

    // タイル位置が変化した場合のみ可視タイルを更新
    if (currentTileX != _lastPlayerTileX || currentTileY != _lastPlayerTileY) {
      _lastPlayerTileX = currentTileX;
      _lastPlayerTileY = currentTileY;
      _updateVisibleTiles();
    }
  }

  void _updateVisibleTiles() {
    // プレイヤーの現在位置からタイル座標を計算
    final playerTileX = (player.position.x / Config.tileSize).round();
    final playerTileY = (player.position.y / Config.tileSize).round();

    // 現在表示すべきタイルの範囲
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

    // 現在表示すべきタイルのセット
    final visibleTiles = <String>{};

    // 必要なタイルを生成・追加
    for (int i = minX; i <= maxX; i++) {
      for (int j = minY; j <= maxY; j++) {
        final key = '$i,$j';
        visibleTiles.add(key);

        if (!_tiles.containsKey(key)) {
          // 地形を生成または取得
          final terrainType = _terrainGenerator.terrainMap.hasTerrain(i, j)
              ? _terrainGenerator.terrainMap.getTerrain(i, j)
              : _terrainGenerator.generateTerrainAt(i, j);

          // 地形データを保存
          _terrainGenerator.terrainMap.setTerrain(i, j, terrainType);

          // final tile = BackgroundTile(
          //   position: Vector2(
          //     i * GameConstants.tileSize,
          //     j * GameConstants.tileSize,
          //   ),
          //   gridX: i,
          //   gridY: j,
          // );
          final tile = TerrainTile(
            position: Vector2(i * Config.tileSize, j * Config.tileSize),
            gridX: i,
            gridY: j,
            terrainType: terrainType,
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
    final mapBounds = Config.mapRadius * Config.tileSize;
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

  @override
  void onGameStateChanged(GameState newState) {
    switch (newState) {
      case GameState.paused:
        _onPause();
        break;
      case GameState.playing:
        _onResume();
        break;
      default:
        break;
    }
  }

  void _onPause() {
    _isPaused = true;
    // 一時停止時は移動を停止
    player.stopAutoMovement();
  }

  void _onResume() {
    _isPaused = false;
    player.startAutoMovement();
  }

  @override
  void onPlayerArrival(Vector2 arrivalPosition) {
    // 効果音を再生
    _audioManager.playArrivalSound();
    // 演出を表示
    showArrivalEffect(arrivalPosition);
    // 到達回数を増やす
    scoreManager.incrementArrivalCount();
    // 目的地をクリア
    clearDestination();
    // 新しい目的地を設定
    setRandomDestination();
  }

  void reset() {
    // プレイヤーを初期位置にリセット
    player.position = Vector2.zero();
    player.startAutoMovement();

    // タイルを画面から削除
    for (final tile in _tiles.values) {
      tile.removeFromParent();
    }
    // キャッシュをクリア
    _tiles.clear();

    // 初期タイルを再生成
    _updateVisibleTiles();

    // 新しい目的地を設定
    clearDestination();
    setRandomDestination();
    // 到達回数をリセット
    scoreManager.resetArrivalCount();
  }

  // テスト用getter
  @visibleForTesting
  int get tileCount => _tiles.length;
}
