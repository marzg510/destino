import 'dart:math';
import 'package:flame/components.dart';
import '../my_game.dart';
import '../config.dart';
import 'garbage.dart';

class GarbageManager extends Component with HasGameReference<MyGame> {
  final Map<String, Garbage> _garbages = {};
  final Random _random = Random();
  double _timeSinceLastCheck = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _updateGarbageCount();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!game.isPlaying || game.paused) return;

    _timeSinceLastCheck += dt;
    if (_timeSinceLastCheck >= Config.garbageUpdateInterval) {
      _updateGarbageCount();
      _timeSinceLastCheck = 0;
    }
  }

  void _updateGarbageCount() {
    _removeDistantGarbage();

    while (_garbages.length < Config.targetGarbageCount) {
      _spawnRandomGarbage();
    }
  }

  void _spawnRandomGarbage() {
    final playerPos = game.player.position;
    final angle = _random.nextDouble() * 2 * pi;
    final distance = _random.nextDouble() * Config.garbageSpawnRadius;

    final garbagePos = Vector2(
      playerPos.x + cos(angle) * distance,
      playerPos.y + sin(angle) * distance,
    );

    final clampedPos = _clampToMapBounds(garbagePos);

    final garbage = Garbage(position: clampedPos);
    final key = '${garbage.position.x.toInt()}_${garbage.position.y.toInt()}';
    _garbages[key] = garbage;
    game.world.add(garbage);
  }

  void _removeDistantGarbage() {
    final playerPos = game.player.position;
    final garbagesToRemove = <String>[];

    for (final entry in _garbages.entries) {
      final distance = entry.value.position.distanceTo(playerPos);

      // 現在の目的地のゴミは削除しない
      final isCurrentTarget = game.player.destination != null &&
          entry.value.position.distanceTo(game.player.destination!) < 10;

      if (distance > Config.garbageDespawnRadius && !isCurrentTarget) {
        garbagesToRemove.add(entry.key);
      }
    }

    for (final key in garbagesToRemove) {
      final garbage = _garbages.remove(key);
      if (garbage != null) {
        garbage.removeFromParent();
      }
    }
  }

  Vector2 _clampToMapBounds(Vector2 position) {
    final mapBounds = Config.mapRadius * Config.tileSize;
    return Vector2(
      position.x.clamp(
        -mapBounds + Config.garbageSize,
        mapBounds - Config.garbageSize,
      ),
      position.y.clamp(
        -mapBounds + Config.garbageSize,
        mapBounds - Config.garbageSize,
      ),
    );
  }

  List<Garbage> getAllGarbages() {
    return _garbages.values.toList();
  }

  Garbage? removeGarbageAt(Vector2 position) {
    for (final entry in _garbages.entries) {
      final distance = entry.value.position.distanceTo(position);
      if (distance <= Config.arrivalThreshold) {
        final garbage = _garbages.remove(entry.key);
        if (garbage != null) {
          garbage.removeFromParent();
        }
        return garbage;
      }
    }
    return null;
  }

  void clear() {
    for (final garbage in _garbages.values) {
      garbage.removeFromParent();
    }
    _garbages.clear();
  }
}
