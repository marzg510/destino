import 'terrain_type.dart';

class TerrainData {
  final int gridX;
  final int gridY;
  final TerrainType terrainType;

  const TerrainData({
    required this.gridX,
    required this.gridY,
    required this.terrainType,
  });

  String get key => '$gridX,$gridY';
}

class TerrainMap {
  final Map<String, TerrainData> _terrainData = {};

  void setTerrain(int x, int y, TerrainType terrainType) {
    final key = '$x,$y';
    _terrainData[key] = TerrainData(
      gridX: x,
      gridY: y,
      terrainType: terrainType,
    );
  }

  TerrainType getTerrain(int x, int y) {
    final key = '$x,$y';
    return _terrainData[key]?.terrainType ?? TerrainType.grassland;
  }

  bool hasTerrain(int x, int y) {
    final key = '$x,$y';
    return _terrainData.containsKey(key);
  }

  void removeTerrain(int x, int y) {
    final key = '$x,$y';
    _terrainData.remove(key);
  }

  Map<String, TerrainData> get allTerrain => Map.unmodifiable(_terrainData);
}
