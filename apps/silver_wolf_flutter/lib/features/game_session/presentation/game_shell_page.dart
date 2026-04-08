import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/app/providers.dart';
import 'package:silver_wolf_flutter/core/widgets/app_panel.dart';
import 'package:silver_wolf_flutter/core/widgets/section_header.dart';
import 'package:silver_wolf_flutter/features/board/presentation/board_panel.dart';
import 'package:silver_wolf_flutter/features/event_log/presentation/event_log_panel.dart';
import 'package:silver_wolf_flutter/features/game_session/application/game_session_controller.dart';
import 'package:silver_wolf_flutter/features/game_session/application/game_session_view_state.dart';
import 'package:silver_wolf_flutter/features/profile/presentation/fighter_profile_panel.dart';
import 'package:silver_wolf_flutter/features/roster/presentation/roster_sidebar.dart';

class GameShellPage extends ConsumerWidget {
  const GameShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameSessionViewState viewState = ref.watch(
      gameSessionControllerProvider,
    );
    final GameSessionController controller = ref.read(
      gameSessionControllerProvider.notifier,
    );
    final bool isCompact = MediaQuery.sizeOf(context).width < 980;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Valley of the Silver Wolf'),
        actions: <Widget>[
          TextButton(
            onPressed: controller.resetSession,
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFF7F0E5), Color(0xFFE8DDCD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Widget statusPanel = _StatusPanel(viewState: viewState);
              final Widget boardPanel = BoardPanel(
                viewState: viewState,
                onChallengeSilverWolf: () =>
                    controller.dispatch(GameCommandFactory.challengeSilverWolf),
                onSelectPlayer: controller.selectProfilePlayer,
              );
              final Widget rosterPanel = RosterSidebar(
                viewState: viewState,
                controller: controller,
              );
              final Widget profilePanel = FighterProfilePanel(
                viewState: viewState,
              );
              final Widget eventLogPanel = EventLogPanel(
                eventLog: viewState.gameState.eventLog,
              );

              return ListView(
                padding: const EdgeInsets.all(20),
                children: <Widget>[
                  const SectionHeader(
                    title: 'Game Shell',
                    subtitle:
                        'The main non-combat Flutter interface now mirrors the prototype layout with engine-backed widgets.',
                  ),
                  const SizedBox(height: 18),
                  statusPanel,
                  const SizedBox(height: 18),
                  if (isCompact) ...<Widget>[
                    boardPanel,
                    const SizedBox(height: 16),
                    rosterPanel,
                    const SizedBox(height: 16),
                    profilePanel,
                    const SizedBox(height: 16),
                    eventLogPanel,
                  ] else ...<Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(flex: 3, child: boardPanel),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: rosterPanel),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(flex: 2, child: profilePanel),
                        const SizedBox(width: 16),
                        Expanded(flex: 3, child: eventLogPanel),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.viewState});

  final GameSessionViewState viewState;

  @override
  Widget build(BuildContext context) {
    final GameState gameState = viewState.gameState;
    final School? currentSchool = viewState.currentSchool;

    return AppPanel(
      title: 'Turn Status',
      subtitle:
          gameState.gameOverReason ??
          (gameState.winnerId == null
              ? 'The valley still stands.'
              : '${gameState.winnerId!.toUpperCase()} has won.'),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          Chip(
            label: Text('Current: ${viewState.currentPlayer.id.toUpperCase()}'),
          ),
          Chip(label: Text('Location: ${viewState.currentLocation.name}')),
          Chip(label: Text('Actions: ${gameState.actionsRemaining}')),
          Chip(
            label: Text('Rivals Here: ${viewState.currentPlayerRivals.length}'),
          ),
          Chip(
            label: Text(
              currentSchool == null
                  ? 'No school at this node'
                  : 'School: ${currentSchool.status.name}',
            ),
          ),
          if (viewState.openDialog != null)
            Chip(label: Text('Open Dialog: ${viewState.openDialog!.name}')),
        ],
      ),
    );
  }
}
