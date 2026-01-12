import 'dart:math';
import 'package:flame/components.dart';
import '../my_game.dart';
import '../config.dart';
import 'garbage.dart';

class GarbageManager extends Component with HasGameReference<MyGame> {
  final Map<(int, int), Garbage> _garbages = {};
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

    const maxAttemptsPerUpdate = 100; // 1回の更新での最大試行回数
    int attempts = 0;

    while (_garbages.length < Config.targetGarbageCount &&
        attempts < maxAttemptsPerUpdate) {
      final success = _spawnRandomGarbage();
      if (!success) {
        attempts++;
      }
    }
  }

  /// ゴミを1つ生成する
  ///
  /// Returns: 生成に成功した場合true、重複などで失敗した場合false
  bool _spawnRandomGarbage() {
    final playerPos = game.player.position;
    final angle = _random.nextDouble() * 2 * pi;
    final distance = _random.nextDouble() * Config.garbageSpawnRadius;

    final garbagePos = Vector2(
      playerPos.x + cos(angle) * distance,
      playerPos.y + sin(angle) * distance,
    );

    final clampedPos = _clampToMapBounds(garbagePos);

    // 仮のGarbageオブジェクトを作成してキーを取得
    final tempGarbage = Garbage(position: clampedPos);
    final key = tempGarbage.getKey();

    // キーの重複チェック（minGarbageSpacing単位のグリッドで管理しているため、
    // キーが重複 = 近すぎる位置 となり、距離チェックは不要）
    if (_garbages.containsKey(key)) {
      return false; // 同じグリッドに既にゴミが存在する場合は失敗
    }

    // ゴミを生成
    _garbages[key] = tempGarbage;
    game.world.add(tempGarbage);
    return true;
  }

  void _removeDistantGarbage() {
    final playerPos = game.player.position;
    final garbagesToRemove = <(int, int)>[];

    for (final entry in _garbages.entries) {
      final distance = entry.value.position.distanceTo(playerPos);

      // 現在の目的地のゴミは削除しない
      final isCurrentTarget =
          game.player.destination != null &&
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

  void removeGarbage(Garbage garbage) {
    final key = garbage.getKey();
    _garbages.remove(key);
    garbage.removeFromParent();
  }

  void clear() {
    for (final garbage in _garbages.values) {
      garbage.removeFromParent();
    }
    _garbages.clear();
  }
}
