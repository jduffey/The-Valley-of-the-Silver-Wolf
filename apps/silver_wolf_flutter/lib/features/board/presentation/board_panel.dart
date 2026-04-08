import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/core/widgets/app_panel.dart';
import 'package:silver_wolf_flutter/features/board/presentation/board_node_widget.dart';
import 'package:silver_wolf_flutter/features/board/presentation/silver_wolf_button.dart';
import 'package:silver_wolf_flutter/features/game_session/application/game_session_view_state.dart';

class BoardPanel extends StatelessWidget {
  const BoardPanel({
    required this.viewState,
    required this.onChallengeSilverWolf,
    required this.onSelectPlayer,
    super.key,
  });

  final GameSessionViewState viewState;
  final VoidCallback onChallengeSilverWolf;
  final ValueChanged<String> onSelectPlayer;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: 'Board',
      subtitle:
          'A Flutter-native board rebuild driven entirely by engine state.',
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double boardSize = math.min(constraints.maxWidth, 560);

          return Center(
            child: SizedBox(
              width: boardSize,
              height: boardSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: <Color>[
                            Colors.white.withValues(alpha: 0.95),
                            const Color(0xFFE5D5BE),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFD6A04B),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  for (int index = 0; index < trackDetails.length; index += 1)
                    _buildNode(boardSize, trackDetails[index], index),
                  Align(
                    child: SilverWolfButton(
                      enabled: viewState.canChallengeSilverWolfNow,
                      onPressed: onChallengeSilverWolf,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNode(double boardSize, Location location, int index) {
    final double radius = boardSize * 0.36;
    final double angle =
        (-math.pi / 2) + ((math.pi * 2) / trackDetails.length) * index;
    final double nodeSize = location.type == LocationType.town ? 124 : 92;
    final double centerOffset = boardSize / 2;
    final double left =
        centerOffset + (radius * math.cos(angle)) - (nodeSize / 2);
    final double top =
        centerOffset + (radius * math.sin(angle)) - (nodeSize / 2);
    final List<Player> occupants = viewState.gameState.players
        .where((Player player) => player.position == index)
        .toList(growable: false);
    final int schoolIndex = viewState.gameState.schools.indexWhere(
      (School townSchool) => townSchool.id == location.id,
    );
    final School? school = schoolIndex == -1
        ? null
        : viewState.gameState.schools[schoolIndex];

    return Positioned(
      left: left,
      top: top,
      width: nodeSize,
      child: BoardNodeWidget(
        location: location,
        occupants: occupants,
        school: school,
        isCurrentLocation: viewState.currentPlayer.position == index,
        currentPlayerId: viewState.currentPlayer.id,
        onSelectPlayer: onSelectPlayer,
      ),
    );
  }
}
