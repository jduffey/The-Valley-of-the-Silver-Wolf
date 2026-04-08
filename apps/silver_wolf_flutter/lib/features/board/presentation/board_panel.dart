import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/core/services/asset_catalog.dart';
import 'package:silver_wolf_flutter/core/widgets/app_panel.dart';
import 'package:silver_wolf_flutter/features/board/presentation/board_node_widget.dart';
import 'package:silver_wolf_flutter/features/board/presentation/silver_wolf_button.dart';
import 'package:silver_wolf_flutter/features/game_session/application/game_session_view_state.dart';

class BoardPanel extends StatelessWidget {
  static const double _designBoardSize = 560;

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
          final double viewportSize = math.min(
            constraints.maxWidth,
            constraints.maxWidth < 420 ? 400 : _designBoardSize,
          );

          return Center(
            child: SizedBox(
              width: viewportSize,
              height: viewportSize,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _designBoardSize,
                  height: _designBoardSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: const DecorationImage(
                              image: AssetImage(AssetCatalog.boardMap),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: const Color(0xFFD6A04B),
                              width: 2.4,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: <Color>[
                                  Colors.white.withValues(alpha: 0.78),
                                  const Color(
                                    0xFFF6EAD8,
                                  ).withValues(alpha: 0.28),
                                  const Color(
                                    0xFFD6A04B,
                                  ).withValues(alpha: 0.08),
                                ],
                                stops: const <double>[0.18, 0.72, 1],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Center(
                            child: Container(
                              width: 184,
                              height: 184,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.34),
                                border: Border.all(
                                  color: const Color(
                                    0xFFD6A04B,
                                  ).withValues(alpha: 0.38),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      for (
                        int index = 0;
                        index < trackDetails.length;
                        index += 1
                      )
                        _buildNode(
                          _designBoardSize,
                          trackDetails[index],
                          index,
                        ),
                      Align(
                        child: SilverWolfButton(
                          enabled: viewState.canChallengeSilverWolfNow,
                          onPressed: onChallengeSilverWolf,
                        ),
                      ),
                    ],
                  ),
                ),
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
