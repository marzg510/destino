import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:life_game_app/src/terrain/terrain_type.dart';

import 'actors/garbage.dart';
import 'actors/player.dart';
import 'actors/garbage_manager.dart';
import 'components/debug_overlay.dart';
import 'components/title_screen.dart';
import 'components/destination_marker.dart';
import 'components/arrival_effect.dart';
import 'components/bloom_effect.dart';
import 'managers/audio_manager.dart';
import 'terrain/terrain_manager.dart';

enum GameState { loading, title, playing }

class MyGame extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapCallbacks {
  MyGame();

  late Player player;
  late TerrainManager terrainManager;
  late GarbageManager garbageManager;
  late TitleScreen titleScreen;
  DestinationMarker? _destinationMarker;
  final Random _random = Random();

  GameState _currentState = GameState.loading;
  final ValueNotifier<int> arrivalCount = ValueNotifier<int>(0);
  final AudioManager _audioManager = AudioManager();

  GameState get currentState => _currentState;
  bool get isPlaying => _currentState == GameState.playing;

  void setState(GameState newState) {
    _currentState = newState;
  }

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'walk_boy_walk.png',
      TerrainType.grassland.spritePath,
      TerrainType.mountain.spritePath,
      TerrainType.ocean.spritePath,
    ]);
    super.onLoad();

    player = Player(position: Vector2.zero());
    player.priority = 100;

    terrainManager = TerrainManager();
    garbageManager = GarbageManager();

    titleScreen = TitleScreen(
      position: Vector2.zero(),
      size: camera.viewport.size,
    );

    camera.viewport.add(titleScreen);

    setState(GameState.title);

    await add(FpsTextComponent(position: Vector2(10, 100)));
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    return KeyEventResult.handled;
  }

  @override
  void onTapDown(TapDownEvent event) {
    debugPrint('Tap detected at ${event.canvasPosition}');

    if (currentState == GameState.title) {
      startGame();
      return;
    }

    if (isPlaying) {
      // タップ位置をワールド座標に変換
      final worldPosition = camera.globalToLocal(event.canvasPosition);
      debugPrint('Setting destination to $worldPosition');
      setPlayerDestination(worldPosition, manual: true);
    }
  }

  Future<void> startGame() async {
    if (currentState == GameState.playing) return;

    titleScreen.removeFromParent();

    setState(GameState.playing);

    world.add(player);
    world.add(terrainManager);
    world.add(garbageManager);

    camera.follow(player);

    final debugOverlay = DebugOverlay(player: player);
    camera.viewport.add(debugOverlay);

    selectNextGarbage();
  }

  void setRandomDestination() {
    final playerPos = player.position;
    final minDistance = 300.0;
    final maxDistance = 500.0;

    final angle = _random.nextDouble() * 2 * pi;
    final distance =
        minDistance + _random.nextDouble() * (maxDistance - minDistance);

    final randomTarget = Vector2(
      playerPos.x + cos(angle) * distance,
      playerPos.y + sin(angle) * distance,
    );

    final mapBounds = 100 * 64.0;
    final clampedTarget = Vector2(
      randomTarget.x.clamp(-mapBounds, mapBounds),
      randomTarget.y.clamp(-mapBounds, mapBounds),
    );

    setPlayerDestination(clampedTarget);
  }

  void selectNextGarbage() {
    final availableGarbages = garbageManager.getAllGarbages();

    if (availableGarbages.isEmpty) {
      debugPrint('No garbage available, waiting for respawn...');
      Future.delayed(Duration(milliseconds: 100), () {
        selectNextGarbage();
      });
      return;
    }

    // 一番近いゴミを探す
    final playerPos = player.position;
    var closestGarbage = availableGarbages[0];
    var closestDistance = (closestGarbage.position - playerPos).length;

    for (final garbage in availableGarbages.skip(1)) {
      final distance = (garbage.position - playerPos).length;
      if (distance < closestDistance) {
        closestDistance = distance;
        closestGarbage = garbage;
      }
    }

    setPlayerDestination(closestGarbage.position);
  }

  void setPlayerDestination(Vector2 target, {bool manual = false}) {
    player.setDestination(target, manual: manual);

    if (_destinationMarker != null) {
      _destinationMarker!.removeFromParent();
    }

    _destinationMarker = DestinationMarker(position: target);
    world.add(_destinationMarker!);
  }

  void clearDestination() {
    player.destination = null;

    if (_destinationMarker != null) {
      _destinationMarker!.removeFromParent();
      _destinationMarker = null;
    }
  }

  void showArrivalEffect(Vector2 position) {
    final effect = ArrivalEffect(effectPosition: position);
    world.add(effect);
    final offset = Vector2(20, 10);
    final bloomPosition = position + offset;
    final bloomEffect = BloomEffect(effectPosition: bloomPosition);
    world.add(bloomEffect);
  }

  void resetGame() {
    player.position = Vector2.zero();
    terrainManager.clear();
    garbageManager.clear();
    clearDestination();
    setRandomDestination();
    arrivalCount.value = 0;
    setState(GameState.playing);
  }

  void _collectGarbage(Garbage? garbage) {
    if (garbage != null) {
      garbageManager.removeGarbage(garbage);
      _audioManager.playArrivalSound();
      showArrivalEffect(garbage.position);
      arrivalCount.value = arrivalCount.value + 1;
    }
  }

  void onGarbageCollected(Garbage garbage) {
    debugPrint('Garbage collected at ${garbage.position}');

    _collectGarbage(garbage);

    // 手動移動中の場合は目的地を変更しない
    // 自動移動中の場合は次のゴミを選択
    if (!player.isManualMovement) {
      clearDestination();
      Future.delayed(Duration(milliseconds: 100), () {
        selectNextGarbage();
      });
    }
  }
}
