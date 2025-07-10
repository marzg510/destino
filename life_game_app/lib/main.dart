import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame with HasKeyboardHandlerComponents {
  late MyWorld myWorld;
  
  @override
  Future<void> onLoad() async {
    myWorld = MyWorld();
    world = myWorld;
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

  @override
  Future<void> onLoad() async {
    player = Player(position: Vector2.zero());
    add(player);

    // マップ背景要素を追加
    for (int i = -10; i <= 10; i++) {
      for (int j = -10; j <= 10; j++) {
        add(BackgroundTile(
          position: Vector2(i * 100.0, j * 100.0),
          gridX: i,
          gridY: j,
        ));
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
    position += velocity * dt;
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
    final color = isEven ? 
      const Color(0xFF4CAF50).withValues(alpha: 0.3) : 
      const Color(0xFF81C784).withValues(alpha: 0.3);
    
    paint = Paint()..color = color;
    
    // 境界線を追加
    final borderPaint = Paint()
      ..color = const Color(0xFF388E3C).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    add(RectangleComponent(
      size: size,
      paint: borderPaint,
      anchor: Anchor.center,
    ));
    
    // 座標をテキストで表示
    if (gridX % 2 == 0 && gridY % 2 == 0) {
      add(TextComponent(
        text: '($gridX,$gridY)',
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFF2E7D32),
            fontSize: 12,
          ),
        ),
      ));
    }
  }
}
