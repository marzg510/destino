import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'effect_component.dart';

class BloomEffect extends EffectComponent {
  late List<_Petal> _petals;
  late CircleComponent _center;

  BloomEffect({required super.effectPosition}) : super(duration: 1.5);

  @override
  Future<void> initializeEffect() async {
    _petals = [];

    // 中心の花芯を作成
    _center = CircleComponent(
      radius: 3.0,
      position: effectPosition,
      anchor: Anchor.center,
      paint: Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.fill,
    );
    add(_center);

    // 花びらを8枚作成
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi) / 8;
      final petal = _Petal(
        angle: angle,
        centerPosition: effectPosition,
        delay: i * 0.1,
      );
      _petals.add(petal);
      add(petal);
    }
  }

  @override
  void updateEffect(double progress) {
    // 花芯のサイズアニメーション
    final centerProgress = (progress * 2).clamp(0.0, 1.0);
    _center.radius = 3.0 + centerProgress * 5.0;

    // 花びらのアニメーション更新
    for (final petal in _petals) {
      petal.updatePetal(progress);
    }
  }
}

class _Petal extends Component {
  final double angle;
  final Vector2 centerPosition;
  final double delay;
  late List<CircleComponent> _petalParts;

  _Petal({
    required this.angle,
    required this.centerPosition,
    required this.delay,
  });

  @override
  Future<void> onLoad() async {
    _petalParts = [];

    // 花びらを3つの円で構成
    for (int i = 0; i < 3; i++) {
      final part = CircleComponent(
        radius: 2.0,
        anchor: Anchor.center,
        paint: Paint()
          ..color = Colors.pink.withValues(alpha: 0.8 - i * 0.1)
          ..style = PaintingStyle.fill,
      );
      _petalParts.add(part);
      add(part);
    }
  }

  void updatePetal(double globalProgress) {
    final adjustedProgress = ((globalProgress - delay) / (1.0 - delay)).clamp(
      0.0,
      1.0,
    );

    if (adjustedProgress <= 0.0) return;

    // 花びらの成長アニメーション（0.0 ~ 0.7で成長、0.7 ~ 1.0で散る）
    final growthPhase = (adjustedProgress / 0.7).clamp(0.0, 1.0);
    final scatterPhase = ((adjustedProgress - 0.7) / 0.3).clamp(0.0, 1.0);

    for (int i = 0; i < _petalParts.length; i++) {
      final part = _petalParts[i];
      final partDistance = 8.0 + i * 6.0;

      // 成長フェーズ：中心から外に向かって伸びる
      final growthDistance = partDistance * growthPhase;

      // 散るフェーズ：さらに外に飛んでいく
      final scatterDistance = growthDistance + scatterPhase * 30.0;

      // 位置計算
      final x = centerPosition.x + math.cos(angle) * scatterDistance;
      final y = centerPosition.y + math.sin(angle) * scatterDistance;
      part.position = Vector2(x, y);

      // サイズアニメーション
      final size = 2.0 + growthPhase * 4.0;
      part.radius = size * (1.0 - scatterPhase);

      // 透明度アニメーション
      final baseAlpha = 0.8 - i * 0.1;
      final currentAlpha = baseAlpha * (1.0 - scatterPhase);
      part.paint.color = Colors.pink.withValues(
        alpha: currentAlpha.clamp(0.0, 1.0),
      );
    }
  }
}
