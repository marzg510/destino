import 'package:flame/components.dart';

/// プレイヤーイベントのコールバックインターフェース
abstract class PlayerEventCallbacks {
  /// プレイヤーが目的地に到達したときに呼ばれる
  /// 到達位置で演出を表示し、次の目的地設定も含む
  void onPlayerArrival(Vector2 arrivalPosition);
}