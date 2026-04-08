import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/app/app.dart';
import 'package:silver_wolf_flutter/app/providers.dart';
import 'package:silver_wolf_flutter/core/services/app_randomizer.dart';
import 'package:silver_wolf_flutter/features/game_session/application/game_session_view_state.dart';
import 'package:silver_wolf_flutter/features/game_session/presentation/game_shell_page.dart';
import '../test/support/game_session_test_support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('plays through a deterministic local combat resolution', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1600, 1200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final FixedRandomizer randomizer = FixedRandomizer(List<int>.filled(32, 0));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRandomizerProvider.overrideWithValue(randomizer),
          gameSessionControllerProvider.overrideWith(
            () => PreparedGameSessionController(
              buildViewState(
                createChallengeDialogGameState(lethalHitPoints: true),
              ),
            ),
          ),
        ],
        child: const SilverWolfApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Combat Challenge'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('challenge-target-p2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accept Challenge'));
    await tester.pumpAndSettle();

    expect(find.text('Combat Encounter'), findsOneWidget);

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(GameShellPage)),
    );
    final CombatState combatState = container
        .read(gameSessionControllerProvider)
        .gameState
        .combatState!;
    final CombatChoice choice = chooseLethalCombatChoice(combatState);

    await tester.tap(
      find.byKey(ValueKey<String>('combat-card-p1-${choice.attackerCard.id}')),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(
        ValueKey<String>('combat-mode-p1-${choice.attackerMode.name}'),
      ),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        ValueKey<String>('combat-mode-p1-${choice.attackerMode.name}'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(ValueKey<String>('combat-card-p2-${choice.defenderCard.id}')),
      260,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(ValueKey<String>('combat-card-p2-${choice.defenderCard.id}')),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(
        ValueKey<String>('combat-mode-p2-${choice.defenderMode.name}'),
      ),
      220,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        ValueKey<String>('combat-mode-p2-${choice.defenderMode.name}'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next Phase'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next Phase'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next Phase'));
    await tester.pumpAndSettle();

    expect(find.text('Resolve Combat'), findsOneWidget);

    await tester.tap(find.text('Resolve Combat'));
    await tester.pumpAndSettle();

    final GameSessionViewState finalViewState = container.read(
      gameSessionControllerProvider,
    );

    expect(finalViewState.gameState.combatState, isNull);
    expect(
      finalViewState.gameState.eventLog.first.message,
      contains('defeats'),
    );
    expect(
      finalViewState.gameState.players
          .firstWhere((Player player) => player.id == 'p1')
          .bonusActionsNextTurn,
      greaterThanOrEqualTo(1),
    );
  });
}
