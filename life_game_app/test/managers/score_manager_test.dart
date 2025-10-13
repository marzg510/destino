import 'package:flutter_test/flutter_test.dart';
import 'package:life_game_app/managers/score_manager.dart';

void main() {
  late ScoreManager scoreManager;

  setUp(() {
    scoreManager = ScoreManager();
  });

  test('initial arrivalCount is zero', () {
    expect(scoreManager.arrivalCount, 0);
  });

  test('incrementArrivalCount increments and notifies once', () {
    var notifiedCount = 0;
    void listener() => notifiedCount++;

    scoreManager.arrivalCountListenable.addListener(listener);
    scoreManager.incrementArrivalCount(); // default +1
    expect(scoreManager.arrivalCount, 1);
    expect(notifiedCount, 1);

    // cleanup
    scoreManager.arrivalCountListenable.removeListener(listener);
  });

  test('incrementArrivalCount with delta works', () {
    scoreManager.incrementArrivalCount(3);
    expect(scoreManager.arrivalCount, 3);
  });

  test('resetArrivalCount resets to zero and notifies', () {
    var notified = 0;
    void listener() => notified++;

    scoreManager.arrivalCountListenable.addListener(listener);
    scoreManager.incrementArrivalCount(2);
    expect(scoreManager.arrivalCount, 2);
    expect(notified, 1);

    scoreManager.resetArrivalCount();
    expect(scoreManager.arrivalCount, 0);
    // 実装により通知回数が変わる可能性があるため >= 2 を許容
    expect(notified, greaterThanOrEqualTo(2));

    scoreManager.arrivalCountListenable.removeListener(listener);
  });
}
