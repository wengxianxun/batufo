import 'dart:ui';

import 'package:batufo/engine/game.dart';
import 'package:batufo/game/grid.dart';
import 'package:batufo/game/player.dart';
import 'package:batufo/game_props.dart';
import 'package:batufo/inputs/keyboard.dart';
import 'package:batufo/models/game_model.dart';
import 'package:flutter/cupertino.dart';

class BatufoGame extends Game {
  final GameModel _game;
  final Player _player;
  final Grid _grid;
  Size _size;

  BatufoGame(this._game)
      : _player = Player(
          GameProps.assets.player,
          tileSize: GameProps.tileSize,
          keyboardRotationFactor: GameProps.keyboardPlayerRotationFactor,
          keyboardThrustForce: GameProps.keyboardPlayerThrustForce,
        ),
        _grid = Grid(GameProps.tileSize);

  void update(double dt, double ts) {
    final pressedKeys = GameKeyboard.pressedKeys;
    final playerModel = _player.update(dt, pressedKeys, _game.player);
    _game.player = playerModel;
  }

  void render(Canvas canvas) {
    _lowerLeftCanvas(canvas, _size.height);
    _grid.render(canvas, _size);
    _player.render(canvas, _game.player);
  }

  void resize(Size size) {
    _size = size;
  }

  void _lowerLeftCanvas(Canvas canvas, double height) {
    canvas.translate(0, height);
    canvas.scale(1, -1);
  }
}