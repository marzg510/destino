import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

/// シンプルな到達回数表示コンポーネント
/// `ValueNotifier<int>` を受け取り到達回数の変化時のみ表示を更新する
class ArrivalCounter extends TextComponent {
  final ValueNotifier<int> arrivalCount;
  late final VoidCallback _listener;

  ArrivalCounter({required this.arrivalCount})
    : super(
        position: Vector2(10, 10),
        anchor: Anchor.topLeft,
        priority: 200,
        text: '到達: 0',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ) {
    // 通知のコールバック
    _listener = () {
      text = '到達: ${arrivalCount.value}';
    };
    arrivalCount.addListener(_listener);
    // 初期表示
    text = '到達: ${arrivalCount.value}';
  }

  @override
  void onRemove() {
    // リスナーを解除
    arrivalCount.removeListener(_listener);
    super.onRemove();
  }
}
