import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import '../actors/player.dart';

/// デバッグ情報を画面にオーバーレイ表示するコンポーネント
///
/// 現在の表示項目:
/// - プレイヤーの座標
/// - 目的地の座標（設定されている場合）
///
/// 将来的に表示項目を拡張可能な設計
class DebugOverlay extends PositionComponent {
  final Player player;
  late final TextComponent _playerPositionText;
  late final TextComponent _destinationText;

  // デバッグオーバーレイの表示/非表示を切り替えるフラグ
  bool _isVisible = true;

  DebugOverlay({required this.player})
    : super(
        position: Vector2(10, 40), // ArrivalCounterの下に配置
        anchor: Anchor.topLeft,
        priority: 200, // HUD層に表示
      );

  @override
  Future<void> onLoad() async {
    // プレイヤー座標のテキスト
    _playerPositionText = TextComponent(
      position: Vector2.zero(),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_playerPositionText);

    // 目的地座標のテキスト
    _destinationText = TextComponent(
      position: Vector2(0, 20), // 1行下に配置
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_destinationText);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isVisible) {
      return;
    }

    // プレイヤー座標を更新
    _updatePlayerPosition();

    // 目的地座標を更新
    _updateDestination();
  }

  void _updatePlayerPosition() {
    final x = player.position.x.toStringAsFixed(1);
    final y = player.position.y.toStringAsFixed(1);
    _playerPositionText.text = 'Player: ($x, $y)';
  }

  void _updateDestination() {
    if (player.destination != null) {
      final x = player.destination!.x.toStringAsFixed(1);
      final y = player.destination!.y.toStringAsFixed(1);
      _destinationText.text = 'Dest: ($x, $y)';
    } else {
      _destinationText.text = 'Dest: None';
    }
  }

  /// デバッグオーバーレイの表示/非表示を切り替え
  void toggleVisibility() {
    _isVisible = !_isVisible;
    _playerPositionText.text = _isVisible ? _playerPositionText.text : '';
    _destinationText.text = _isVisible ? _destinationText.text : '';
  }

  /// デバッグオーバーレイを表示
  void show() {
    _isVisible = true;
  }

  /// デバッグオーバーレイを非表示
  void hide() {
    _isVisible = false;
    _playerPositionText.text = '';
    _destinationText.text = '';
  }

  /// 将来的にデバッグ項目を追加するためのメソッド例
  ///
  /// 使用例:
  /// ```dart
  /// void addDebugItem(String label, String Function() valueGetter) {
  ///   final textComponent = TextComponent(
  ///     position: Vector2(0, children.length * 20.0),
  ///     anchor: Anchor.topLeft,
  ///     textRenderer: TextPaint(...),
  ///   );
  ///   add(textComponent);
  /// }
  /// ```
}
