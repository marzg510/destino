import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ArrivalEffect extends Component {
  final Vector2 effectPosition;
  double _elapsedTime = 0.0;
  final double _duration = 0.6; // 演出の発生時間
  late List<CircleComponent> _circles;

  ArrivalEffect({required this.effectPosition});

  @override
  Future<void> onLoad() async {
    // 複数の円を作成（3つの同心円）
    _circles = [];

    for (int i = 0; i < 3; i++) {
      final circle = CircleComponent(
        radius: 5.0,
        position: effectPosition,
        anchor: Anchor.center,
        paint: Paint()
          ..color = Colors.amber.withValues(alpha: 0.9 - i * 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0,
      );
      _circles.add(circle);
      add(circle);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _elapsedTime += dt;

    // 演出の進行度（0.0から1.0）
    final progress = (_elapsedTime / _duration).clamp(0.0, 1.0);

    // 各円のサイズと透明度をアニメーション
    for (int i = 0; i < _circles.length; i++) {
      final circle = _circles[i];
      final delay = i * 0.1; // 円ごとに少し遅延
      final adjustedProgress = ((progress - delay) / (1.0 - delay)).clamp(
        0.0,
        1.0,
      );

      // 円のサイズを拡大（より大きく）
      circle.radius = 5.0 + adjustedProgress * 60.0;

      // 透明度を減少
      final baseOpacity = 0.9 - i * 0.15;
      final currentOpacity = baseOpacity * (1.0 - adjustedProgress);
      circle.paint.color = Colors.amber.withValues(
        alpha: currentOpacity.clamp(0.0, 1.0),
      );
    }

    // 演出終了時に削除
    if (_elapsedTime >= _duration) {
      removeFromParent();
    }
  }
}
