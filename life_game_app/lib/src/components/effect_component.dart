import 'package:flame/components.dart';

abstract class EffectComponent extends Component {
  final Vector2 effectPosition;
  final double duration;
  double _elapsedTime = 0.0;

  EffectComponent({
    required this.effectPosition,
    required this.duration,
  });

  @override
  Future<void> onLoad() async {
    await initializeEffect();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _elapsedTime += dt;
    final progress = (_elapsedTime / duration).clamp(0.0, 1.0);
    
    updateEffect(progress);

    if (_elapsedTime >= duration) {
      removeFromParent();
    }
  }

  double get progress => (_elapsedTime / duration).clamp(0.0, 1.0);
  double get elapsedTime => _elapsedTime;
  bool get isCompleted => _elapsedTime >= duration;

  Future<void> initializeEffect();
  void updateEffect(double progress);
}