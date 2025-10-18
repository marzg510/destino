import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:life_game_app/src/my_game.dart';

void main() {
  testWidgets('Game widget renders without crashing', (
    WidgetTester tester,
  ) async {
    final game = MyGame();
    await tester.pumpWidget(
      MaterialApp(home: GameWidget<MyGame>.controlled(gameFactory: () => game)),
    );

    // 初期レンダリングを実行
    await tester.pump(const Duration(milliseconds: 100));

    // MaterialAppが存在することを確認
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
