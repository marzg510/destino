import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_game_app/src/actors/garbage.dart';
import 'package:life_game_app/src/my_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Garbage Component', () {
    testWithGame<MyGame>(
      'Garbageが正しく生成される',
      () => MyGame(),
      (game) async {
        final garbage = Garbage(position: Vector2.zero());
        await game.ensureAdd(garbage);

        expect(garbage.position, Vector2.zero());
        expect(garbage.isMounted, isTrue);
      },
    );

    testWithGame<MyGame>(
      'Garbageが衝突判定を持つ',
      () => MyGame(),
      (game) async {
        final garbage = Garbage(position: Vector2.zero());
        await game.ensureAdd(garbage);

        expect(garbage.children.whereType<CircleHitbox>().length, 1);
      },
    );
  });
}
