enum TerrainType {
  ocean,
  grassland,
  mountain,
}

extension TerrainTypeExtension on TerrainType {
  String get spritePath {
    switch (this) {
      case TerrainType.ocean:
        return 'terrain/ocean.png';
      case TerrainType.grassland:
        return 'terrain/grassland.png';
      case TerrainType.mountain:
        return 'terrain/mountain.png';
    }
  }

  String get displayName {
    switch (this) {
      case TerrainType.ocean:
        return '海';
      case TerrainType.grassland:
        return '草原';
      case TerrainType.mountain:
        return '山';
    }
  }
}