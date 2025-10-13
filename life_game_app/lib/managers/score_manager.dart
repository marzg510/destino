import 'package:flutter/foundation.dart';

/// 軽量なスコア管理クラス
/// 将来的に到達時間や重み付きスコア等を追加するための拡張ポイント
class ScoreManager {
  final ValueNotifier<int> _arrivalCount = ValueNotifier<int>(0);

  /// 到達回数の読み取り専用 Listenable
  ValueListenable<int> get arrivalCountListenable => _arrivalCount;

  /// 現在の到達回数
  int get arrivalCount => _arrivalCount.value;

  /// 到達回数を増やす（将来的に重みや時間をパラメータ化可能）
  void incrementArrivalCount([int delta = 1]) {
    _arrivalCount.value = _arrivalCount.value + delta;
  }

  /// 到達回数をリセット
  void resetArrivalCount() {
    _arrivalCount.value = 0;
  }
}
