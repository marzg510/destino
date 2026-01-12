class Config {
  // ゲームの名前
  static const String gameTitle = 'DESTINO';

  // デバッグモード
  static const bool debugMode = false; // デバッグ情報の表示有無

  // マップサイズの設定
  static const int mapSize = 100; // マップサイズ（タイル数）
  static const double tileSize = 128.0; // 1タイルのサイズ（ピクセル）
  static const int mapRadius = mapSize ~/ 2; // マップ半径（中心からの距離）
  static const int renderDistance = 10; // 画面周辺のタイル描画距離

  // プレイヤーの設定
  static const double playerSpeed = 200.0;
  static const double playerSize = 64.0;

  // 目的地到達判定の閾値（この距離以内で到達とみなす）
  static const double arrivalThreshold = 30.0;

  // ゴミ関連の設定
  static const double garbageSpawnRadius = 1000.0; // プレイヤー周辺のゴミ生成範囲
  static const double garbageDespawnRadius =
      garbageSpawnRadius * 1.2; // ゴミの削除範囲
  static const int targetGarbageCount = 50; // 維持するゴミの数
  static const double garbageSize = 8.0; // ゴミの半径
  static const double garbageUpdateInterval = 0.5; // ゴミの更新間隔（秒）
}
