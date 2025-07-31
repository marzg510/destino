import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'effect_component.dart';

class ArrivalEffect extends EffectComponent {
  late List<CircleComponent> _circles;

  ArrivalEffect({required super.effectPosition}) 
      : super(duration: 0.6);

  @override
  Future<void> initializeEffect() async {
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
  void updateEffect(double progress) {
    for (int i = 0; i < _circles.length; i++) {
      final circle = _circles[i];
      final delay = i * 0.1;
      final adjustedProgress = ((progress - delay) / (1.0 - delay)).clamp(
        0.0,
        1.0,
      );

      circle.radius = 5.0 + adjustedProgress * 60.0;

      final baseOpacity = 0.9 - i * 0.15;
      final currentOpacity = baseOpacity * (1.0 - adjustedProgress);
      circle.paint.color = Colors.amber.withValues(
        alpha: currentOpacity.clamp(0.0, 1.0),
      );
    }
  }
}
