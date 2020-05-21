import 'package:batufo/engine/game_widget.dart';
import 'package:batufo/game/client_game.dart';
import 'package:batufo/game/inputs/gestures.dart';
import 'package:batufo/models/game_model.dart';
import 'package:batufo/widgets/game_over/game_over_widget.dart';
import 'package:batufo/widgets/hud/hud_widget.dart';
import 'package:flutter/material.dart';

class RunningGame extends StatelessWidget {
  final ClientGame game;
  final VoidCallback newGameRequested;
  final int numberOfPlayers;
  const RunningGame({
    @required this.game,
    @required this.newGameRequested,
    @required this.numberOfPlayers,
  });

  Widget build(BuildContext context) {
    return Stack(children: [
      GestureDetector(
        onPanUpdate: GameGestures.instance.onPanUpdate,
        onTap: GameGestures.instance.onTap,
        child: GameWidget(
          game,
          background: Colors.tealAccent,
        ),
      ),
      StreamBuilder(
        stream: game.gameState.stats$,
        builder: (_, AsyncSnapshot<Stats> snapshot) => snapshot.data.health > 0
            ? HudWidget(stats: snapshot.data)
            : GameOverWidget(newGameRequested: onNewGameRequested, won: false),
        initialData: Stats.initial(numberOfPlayers),
      ),
    ]);
  }

  void onNewGameRequested() {
    newGameRequested();
  }
}