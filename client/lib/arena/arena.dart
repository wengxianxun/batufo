import 'package:batufo/arena/tilemap.dart';
import 'package:batufo/engine/tile_position.dart';
import 'package:batufo/rpc/generated/message_bus.pb.dart' show PackedArena;
import 'package:flutter/foundation.dart';

class Arena {
  final List<TilePosition> floorTiles;
  final List<TilePosition> walls;
  final List<TilePosition> players;
  final int nrows;
  final int ncols;
  final int tileSize;

  Arena({
    @required this.floorTiles,
    @required this.walls,
    @required this.players,
    @required this.nrows,
    @required this.ncols,
    @required this.tileSize,
  });

  bool isFull(int registeredPlayers) => players.length == registeredPlayers;
  TilePosition playerPosition(int idx) => players[idx];
  bool isCoveredAt(int col, int row) {
    final wall = walls.firstWhere((tp) => tp.col == col && tp.row == row,
        orElse: () => null);
    if (wall != null) return true;
    final floorTile = floorTiles
        .firstWhere((tp) => tp.col == col && tp.row == row, orElse: () => null);
    if (floorTile != null) return true;
    return false;
  }

  factory Arena.fromTilemap(Tilemap tilemap, int tileSize) {
    final nrows = tilemap.nrows;
    final ncols = tilemap.ncols;
    final center = tileSize / 2;
    final floorTiles = <TilePosition>[];
    final walls = <TilePosition>[];
    final initialPlayers = <TilePosition>[];

    for (int row = 0; row < nrows; row++) {
      for (int col = 0; col < ncols; col++) {
        final tile = tilemap.tiles[row * ncols + col];
        if (!Tilemap.coversBackground(tile)) {
          floorTiles.add(TilePosition(col, row, center, center));
        }
        if (tile == Tile.Wall || tile == Tile.Boundary) {
          walls.add(TilePosition(col, row, center, center));
        }
        if (tile == Tile.Player) {
          initialPlayers.add(
            TilePosition(col, row, center, center),
          );
        }
      }
    }
    return Arena(
      floorTiles: floorTiles,
      walls: walls,
      players: initialPlayers,
      nrows: nrows,
      ncols: ncols,
      tileSize: tileSize,
    );
  }

  PackedArena pack() {
    final packedFloorTiles = floorTiles.map((x) => x.pack());
    final packedWalls = walls.map((x) => x.pack());
    final packedPlayerPositions = players.map((x) => x.pack());
    final packedArena = PackedArena()
      ..nrows = nrows
      ..ncols = ncols
      ..tileSize = tileSize;
    packedFloorTiles.forEach((x) => packedArena.floorTiles.add(x));
    packedWalls.forEach((x) => packedArena.walls.add(x));
    packedPlayerPositions.forEach((x) => packedArena.playerPositions.add(x));

    return packedArena;
  }

  factory Arena.unpack(PackedArena data) {
    final floorTiles =
        data.floorTiles.map((x) => TilePosition.unpack(x)).toList();
    final walls = data.walls.map((x) => TilePosition.unpack(x)).toList();
    final playerPositions =
        data.playerPositions.map((x) => TilePosition.unpack(x)).toList();

    return Arena(
      floorTiles: floorTiles,
      walls: walls,
      players: playerPositions,
      nrows: data.nrows,
      ncols: data.ncols,
      tileSize: data.tileSize,
    );
  }

  String toString() {
    return '''
    Arena: ${nrows}x$ncols {
      players: $players
      walls: $walls
    }
''';
  }
}
