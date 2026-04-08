import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/app/providers.dart';
import 'package:silver_wolf_flutter/core/widgets/app_panel.dart';
import 'package:silver_wolf_flutter/features/game_session/application/game_session_controller.dart';
import 'package:silver_wolf_flutter/features/game_session/application/game_session_view_state.dart';

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
    final ThemeData theme = Theme.of(context);
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
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Color(0xFFF6EFE5), Color(0xFFEDE3D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              Text('Game Shell', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Phase 5 wiring: engine state is live, commands dispatch through the controller, and the final feature surfaces can now layer on top of this shell.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              _SessionBanner(viewState: viewState),
              const SizedBox(height: 20),
              _DebugActions(controller: controller),
              const SizedBox(height: 20),
              if (isCompact) ...<Widget>[
                _BoardPanel(viewState: viewState),
                const SizedBox(height: 16),
                _RosterPanel(
                  viewState: viewState,
                  onSelectPlayer: controller.selectProfilePlayer,
                ),
                const SizedBox(height: 16),
                _ProfilePanel(viewState: viewState),
                const SizedBox(height: 16),
                _EventLogPanel(viewState: viewState),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: <Widget>[
                          _BoardPanel(viewState: viewState),
                          const SizedBox(height: 16),
                          _EventLogPanel(viewState: viewState),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: <Widget>[
                          _RosterPanel(
                            viewState: viewState,
                            onSelectPlayer: controller.selectProfilePlayer,
                          ),
                          const SizedBox(height: 16),
                          _ProfilePanel(viewState: viewState),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionBanner extends StatelessWidget {
  const _SessionBanner({required this.viewState});

  final GameSessionViewState viewState;

  @override
  Widget build(BuildContext context) {
    final GameState gameState = viewState.gameState;

    return AppPanel(
      title: 'Current Turn',
      subtitle: gameState.winnerId != null
          ? 'The match has been won.'
          : gameState.gameOverReason ??
                'The valley still hangs in the balance.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          Chip(
            label: Text(
              'Current Player: ${viewState.currentPlayer.id.toUpperCase()}',
            ),
          ),
          Chip(label: Text('Actions Remaining: ${gameState.actionsRemaining}')),
          Chip(label: Text('Dialog: ${viewState.openDialog?.name ?? 'none'}')),
          Chip(
            label: Text(
              'Schools Standing: ${gameState.schools.where((School school) => school.status != SchoolStatus.destroyed).length}',
            ),
          ),
        ],
      ),
    );
  }
}

class _DebugActions extends StatelessWidget {
  const _DebugActions({required this.controller});

  final GameSessionController controller;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: 'Connected Actions',
      subtitle: 'These buttons already dispatch real engine commands.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          FilledButton(
            onPressed: () =>
                controller.dispatch(GameCommandFactory.travelClockwise),
            child: const Text('Travel Clockwise'),
          ),
          OutlinedButton(
            onPressed: () =>
                controller.dispatch(GameCommandFactory.travelCounterClockwise),
            child: const Text('Travel Counter'),
          ),
          OutlinedButton(
            onPressed: () => controller.dispatch(GameCommandFactory.passTurn),
            child: const Text('Pass Turn'),
          ),
          OutlinedButton(
            onPressed: () =>
                controller.dispatch(GameCommandFactory.healCurrentPlayer),
            child: const Text('Heal'),
          ),
          OutlinedButton(
            onPressed: () =>
                controller.dispatch(GameCommandFactory.saveCurrentSchool),
            child: const Text('Save School'),
          ),
          OutlinedButton(
            onPressed: () =>
                controller.dispatch(GameCommandFactory.openChallenge),
            child: const Text('Challenge Rival'),
          ),
          OutlinedButton(
            onPressed: () =>
                controller.dispatch(GameCommandFactory.challengeSilverWolf),
            child: const Text('Challenge Silver Wolf'),
          ),
          OutlinedButton(
            onPressed: () =>
                controller.dispatch(GameCommandFactory.undoLastAction),
            child: const Text('Undo'),
          ),
        ],
      ),
    );
  }
}

class _BoardPanel extends StatelessWidget {
  const _BoardPanel({required this.viewState});

  final GameSessionViewState viewState;

  @override
  Widget build(BuildContext context) {
    final GameState gameState = viewState.gameState;
    final Player currentPlayer = viewState.currentPlayer;
    final Location currentLocation = trackDetails[currentPlayer.position];

    return AppPanel(
      title: 'Board Area',
      subtitle: 'Placeholder board region wired to engine state.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Current location: ${currentLocation.name}'),
          const SizedBox(height: 8),
          Text('Position index: ${currentPlayer.position}'),
          const SizedBox(height: 8),
          Text(
            'Standing schools: ${gameState.schools.where((School school) => school.status == SchoolStatus.whole).length}',
          ),
        ],
      ),
    );
  }
}

class _RosterPanel extends StatelessWidget {
  const _RosterPanel({required this.viewState, required this.onSelectPlayer});

  final GameSessionViewState viewState;
  final ValueChanged<String> onSelectPlayer;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: 'Roster Area',
      subtitle: 'Players are already live from the engine state.',
      child: Column(
        children: viewState.playersInArrivalOrder
            .map((Player player) {
              final bool isSelected =
                  player.id == viewState.selectedProfilePlayer.id;
              final bool isCurrent = player.id == viewState.currentPlayer.id;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${player.id.toUpperCase()} • ${player.name}'),
                subtitle: Text(
                  'Rep ${player.reputation} • HP ${player.hitPoints} • FP ${player.formPoints}',
                ),
                trailing: isCurrent ? const Icon(Icons.bolt) : null,
                selected: isSelected,
                onTap: () => onSelectPlayer(player.id),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({required this.viewState});

  final GameSessionViewState viewState;

  @override
  Widget build(BuildContext context) {
    final Player player = viewState.selectedProfilePlayer;

    return AppPanel(
      title: 'Profile Area',
      subtitle: 'UI-only selected profile state lives in the controller.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${player.id.toUpperCase()} studies at ${player.name}.'),
          const SizedBox(height: 8),
          Text(
            'Power ${player.power} • Stamina ${player.stamina} • Agility ${player.agility}',
          ),
          const SizedBox(height: 4),
          Text('Chi ${player.chi} • Wit ${player.wit}'),
          const SizedBox(height: 4),
          Text('Injured: ${player.injured ? 'yes' : 'no'}'),
        ],
      ),
    );
  }
}

class _EventLogPanel extends StatelessWidget {
  const _EventLogPanel({required this.viewState});

  final GameSessionViewState viewState;

  @override
  Widget build(BuildContext context) {
    final List<GameLogEntry> eventLog = viewState.gameState.eventLog;

    return AppPanel(
      title: 'Event Log Area',
      subtitle: 'Reverse chronological log straight from the engine.',
      child: eventLog.isEmpty
          ? const Text('No events yet.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: eventLog
                  .take(6)
                  .map(
                    (GameLogEntry entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(entry.message),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}
