class GameConstants {
  // マップサイズの設定
  static const int mapSize = 100; // 100x100タイル = 10,000タイル
  static const double tileSize = 100.0;
  static const int mapRadius = mapSize ~/ 2; // -50 to +50
  static const int renderDistance = 10; // 画面周辺のタイル描画距離
  
  // プレイヤーの設定
  static const double playerSpeed = 200.0;
  static const double playerSize = 64.0;
  
  // 移動の精度
  static const double movementThreshold = 2.0;
}