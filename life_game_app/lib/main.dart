import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(home: GameWidget(game: MyGame())));
}

class MyGame extends FlameGame with HasKeyboardHandlerComponents {
  late MyWorld myWorld;

  @override
  Future<void> onLoad() async {
    myWorld = MyWorld();
    world = myWorld;
    await myWorld.loaded;
    camera.follow(myWorld.player);

    return super.onLoad();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    myWorld.player.handleInput(keysPressed);
    super.onKeyEvent(event, keysPressed);
    return KeyEventResult.handled;
  }
}

class MyWorld extends World {
  late Player player;

  // マップサイズの設定
  static const int mapSize = 100; // 100x100タイル = 10,000タイル
  static const double tileSize = 100.0;
  static const int mapRadius = mapSize ~/ 2; // -50 to +50
  static const int renderDistance = 10; // 画面周辺のタイル描画距離

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
    final currentTileX = (player.position.x / tileSize).floor();
    final currentTileY = (player.position.y / tileSize).floor();

    // タイル位置が変化した場合のみ可視タイルを更新
    if (currentTileX != _lastPlayerTileX || currentTileY != _lastPlayerTileY) {
      _lastPlayerTileX = currentTileX;
      _lastPlayerTileY = currentTileY;
      _updateVisibleTiles();
    }
  }

  void _updateVisibleTiles() {
    // プレイヤーの現在位置からタイル座標を計算
    final playerTileX = (player.position.x / tileSize).round();
    final playerTileY = (player.position.y / tileSize).round();

    // 現在表示すべきタイルの範囲
    final minX = (playerTileX - renderDistance).clamp(-mapRadius, mapRadius);
    final maxX = (playerTileX + renderDistance).clamp(-mapRadius, mapRadius);
    final minY = (playerTileY - renderDistance).clamp(-mapRadius, mapRadius);
    final maxY = (playerTileY + renderDistance).clamp(-mapRadius, mapRadius);

    // 現在表示すべきタイルのセット
    final visibleTiles = <String>{};

    // 必要なタイルを生成・追加
    for (int i = minX; i <= maxX; i++) {
      for (int j = minY; j <= maxY; j++) {
        final key = '$i,$j';
        visibleTiles.add(key);

        if (!_tiles.containsKey(key)) {
          final tile = BackgroundTile(
            position: Vector2(i * tileSize, j * tileSize),
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
}

class Player extends SpriteComponent {
  static const double speed = 200.0;
  Vector2 velocity = Vector2.zero();

  Player({super.position})
    : super(size: Vector2.all(64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('walk_boy_walk.png');
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 移動処理
    final newPosition = position + velocity * dt;

    // マップ境界チェック
    final mapBounds = MyWorld.mapRadius * MyWorld.tileSize;
    final clampedPosition = Vector2(
      newPosition.x.clamp(-mapBounds + size.x / 2, mapBounds - size.x / 2),
      newPosition.y.clamp(-mapBounds + size.y / 2, mapBounds - size.y / 2),
    );

    position = clampedPosition;
  }

  void handleInput(Set<LogicalKeyboardKey> keysPressed) {
    velocity = Vector2.zero();

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      velocity.x = -speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      velocity.x = speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW)) {
      velocity.y = -speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS)) {
      velocity.y = speed;
    }
  }
}

class BackgroundTile extends RectangleComponent with HasGameReference {
  final int gridX;
  final int gridY;

  BackgroundTile({super.position, required this.gridX, required this.gridY})
    : super(size: Vector2.all(100), anchor: Anchor.center);

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
