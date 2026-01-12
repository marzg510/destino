import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_game_app/src/actors/garbage.dart';
import 'package:life_game_app/src/my_game.dart';
import 'package:life_game_app/src/config.dart';

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
        expect(garbage.radius, Config.garbageSize);
      },
    );

    testWithGame<MyGame>(
      'Garbageが衝突判定を持つ',
      () => MyGame(),
      (game) async {
        final garbage = Garbage(position: Vector2.zero());
        await game.ensureAdd(garbage);

        final hitboxes = garbage.children.whereType<CircleHitbox>();
        expect(hitboxes.length, 1);
        expect(hitboxes.first.collisionType, CollisionType.passive);
      },
    );

    testWithGame<MyGame>(
      'getKeyが正しいグリッドキーを返す',
      () => MyGame(),
      (game) async {
        // minGarbageSpacing = 50.0 の場合の基本テスト
        final testCases = [
          (Vector2(0, 0), (0, 0)),
          (Vector2(50, 50), (1, 1)),
          (Vector2(100, 150), (2, 3)),
          (Vector2(-50, -50), (-1, -1)),
          (Vector2(-100, -200), (-2, -4)),
        ];

        for (final (position, expectedKey) in testCases) {
          final garbage = Garbage(position: position);
          await game.ensureAdd(garbage);

          expect(
            garbage.getKey(),
            expectedKey,
            reason: '位置$positionのキーが$expectedKeyであるべき',
          );

          garbage.removeFromParent();
        }
      },
    );

    testWithGame<MyGame>(
      'getKeyが四捨五入で正しく計算される',
      () => MyGame(),
      (game) async {
        final testCases = [
          // 境界値のテスト (minGarbageSpacing = 50.0)
          (Vector2(24, 24), (0, 0)), // 24/50 = 0.48 → 0
          (Vector2(25, 25), (1, 1)), // 25/50 = 0.5 → 1 (四捨五入)
          (Vector2(26, 26), (1, 1)), // 26/50 = 0.52 → 1
          (Vector2(74, 74), (1, 1)), // 74/50 = 1.48 → 1
          (Vector2(75, 75), (2, 2)), // 75/50 = 1.5 → 2
          (Vector2(-24, -24), (0, 0)), // -24/50 = -0.48 → 0
          (Vector2(-25, -25), (-1, -1)), // -25/50 = -0.5 → -1
        ];

        for (final (position, expectedKey) in testCases) {
          final garbage = Garbage(position: position);
          await game.ensureAdd(garbage);

          expect(
            garbage.getKey(),
            expectedKey,
            reason: '位置$positionのキーが$expectedKeyであるべき（四捨五入）',
          );

          garbage.removeFromParent();
        }
      },
    );

    testWithGame<MyGame>(
      '同じグリッド内の位置は同じキーを持つ',
      () => MyGame(),
      (game) async {
        // グリッド(0,0)内の異なる位置
        final positions = [
          Vector2(0, 0),
          Vector2(10, 15),
          Vector2(20, 20),
          Vector2(24, 24), // 境界ギリギリ
        ];

        for (final position in positions) {
          final garbage = Garbage(position: position);
          await game.ensureAdd(garbage);

          expect(
            garbage.getKey(),
            (0, 0),
            reason: 'グリッド内の位置$positionは同じキー(0,0)を持つべき',
          );

          garbage.removeFromParent();
        }
      },
    );

    testWithGame<MyGame>(
      '異なるグリッドの位置は異なるキーを持つ',
      () => MyGame(),
      (game) async {
        final testCases = [
          (Vector2(0, 0), (0, 0)),
          (Vector2(50, 50), (1, 1)),
          (Vector2(100, 100), (2, 2)),
          (Vector2(150, 150), (3, 3)),
        ];

        final keys = <(int, int)>[];
        for (final (position, _) in testCases) {
          final garbage = Garbage(position: position);
          await game.ensureAdd(garbage);
          keys.add(garbage.getKey());
          garbage.removeFromParent();
        }

        // すべてのキーが異なることを確認
        expect(keys.toSet().length, testCases.length);
      },
    );

    testWithGame<MyGame>(
      '小数点を含む座標でも正しくキーを計算する',
      () => MyGame(),
      (game) async {
        final testCases = [
          (Vector2(123.456, 234.567), (2, 5)), // 123.456/50≈2.47→2, 234.567/50≈4.69→5
          (Vector2(99.9, 199.9), (2, 4)), // 99.9/50≈2.0→2, 199.9/50≈4.0→4
          (Vector2(0.1, 0.1), (0, 0)),
          (Vector2(49.9, 49.9), (1, 1)),
        ];

        for (final (position, expectedKey) in testCases) {
          final garbage = Garbage(position: position);
          await game.ensureAdd(garbage);

          expect(
            garbage.getKey(),
            expectedKey,
            reason: '小数点含む位置$positionのキーが$expectedKeyであるべき',
          );

          garbage.removeFromParent();
        }
      },
    );
  });
}
