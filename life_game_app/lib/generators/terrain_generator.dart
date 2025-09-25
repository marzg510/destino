import 'dart:math';
import '../enums/terrain_type.dart';
import '../data/terrain_data.dart';

class TerrainGenerator {
  final TerrainMap _terrainMap = TerrainMap();

  TerrainMap get terrainMap => _terrainMap;

  TerrainType generateTerrainAt(int x, int y) {
    // シンプルなルールベース生成
    final distanceFromCenter = sqrt(x * x + y * y);
    final noise = _generateNoise(x, y);

    // 中心から遠いほど海になりやすい
    if (distanceFromCenter > 30 && noise > 0.3) {
      return TerrainType.ocean;
    }

    // 高い標高（ノイズ値）は山
    if (noise > 0.6) {
      return TerrainType.mountain;
    }

    // デフォルトは草原
    return TerrainType.grassland;
  }

  double _generateNoise(int x, int y) {
    // シンプルなパーリンノイズもどき
    const double scale = 0.1;
    final dx = x * scale;
    final dy = y * scale;

    // 複数の周波数を重ね合わせ
    double noise = 0.0;
    noise += _smoothNoise(dx, dy) * 0.5;
    noise += _smoothNoise(dx * 2, dy * 2) * 0.25;
    noise += _smoothNoise(dx * 4, dy * 4) * 0.125;

    return (noise + 1.0) / 2.0; // 0-1の範囲に正規化
  }

  double _smoothNoise(double x, double y) {
    // 簡単なスムーズノイズ
    final intX = x.floor();
    final intY = y.floor();
    final fracX = x - intX;
    final fracY = y - intY;

    final a = _noise(intX, intY);
    final b = _noise(intX + 1, intY);
    final c = _noise(intX, intY + 1);
    final d = _noise(intX + 1, intY + 1);

    final i1 = _interpolate(a, b, fracX);
    final i2 = _interpolate(c, d, fracX);

    return _interpolate(i1, i2, fracY);
  }

  double _noise(int x, int y) {
    // 擬似ランダム値生成
    int n = x + y * 57;
    n = (n << 13) ^ n;
    return (1.0 -
        ((n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff) /
            1073741824.0);
  }

  double _interpolate(double a, double b, double x) {
    final ft = x * pi;
    final f = (1 - cos(ft)) * 0.5;
    return a * (1 - f) + b * f;
  }

  void generateChunk(int centerX, int centerY, int radius) {
    for (int x = centerX - radius; x <= centerX + radius; x++) {
      for (int y = centerY - radius; y <= centerY + radius; y++) {
        if (!_terrainMap.hasTerrain(x, y)) {
          final terrainType = generateTerrainAt(x, y);
          _terrainMap.setTerrain(x, y, terrainType);
        }
      }
    }
  }
}
